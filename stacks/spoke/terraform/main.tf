// ---------------------------------------------------------------------------------------------------------------------
// SPOKE Stack - spoke network, data lake and private Databricks workspace
// This Terraform configuration provisions resources for the spoke deployment.
//
// Notes:
// - Naming is centralised via the `naming` module to ensure consistent resource names across environments.
// - Only Azure Verified Modules (AVM) are used: no `resource` blocks and no custom modules.
// - The hub stack owns every private DNS zone (privatelink.azuredatabricks.net, privatelink.dfs.core.windows.net) and
//   the private DNS resolver. This stack takes their IDs as variables (see variables.tf) instead of reading the hub state.

// Module: naming
// Purpose: Centralised naming standards for resources (project, environment, location short code).
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.4"

  suffix = [var.project, var.environment, var.location_short]
}

// Module: resource_group
// Purpose: Creates the spoke resource group to contain all resources in this stack.
module "resource_group" {
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  enable_telemetry = var.enable_telemetry
  location         = var.location
  name             = module.naming.resource_group.name
  tags             = var.tags
}

// Module: network_security_group
// Purpose: NSG shared by both Databricks subnets. Databricks adds its own required rules through the
// Microsoft.Databricks/workspaces subnet delegation, so no rules are defined here.
module "network_security_group" {
  source           = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version          = "0.6.0"
  enable_telemetry = var.enable_telemetry
  location         = var.location
  parent_id        = module.resource_group.resource_id
  name             = "${module.naming.network_security_group.slug}-databricks-${local.name_suffix}"
  tags             = var.tags
}

// Module: virtual_network
// Purpose: Spoke virtual network (/22) with two /26 Databricks subnets (host and container) and a /26 subnet for
// private endpoints. Peered to the hub in both directions (the reverse peering is created in the hub VNet's group).
module "virtual_network" {
  source           = "Azure/avm-res-network-virtualnetwork/azurerm"
  version          = "0.23.0"
  enable_telemetry = var.enable_telemetry
  location         = var.location
  parent_id        = module.resource_group.resource_id
  name             = module.naming.virtual_network.name
  address_space    = [var.vnet_address_space]
  dns_servers = {
    dns_servers = ["10.10.0.132"]
  }
  tags = var.tags

  subnets = {
    databricks_host = {
      name             = local.subnet_names.databricks_host
      address_prefixes = [local.subnet_prefixes.databricks_host]
      network_security_group = {
        id = module.network_security_group.resource_id
      }
      delegations = [{
        name = "databricks"
        service_delegation = {
          name = "Microsoft.Databricks/workspaces"
        }
      }]
    }
    databricks_container = {
      name             = local.subnet_names.databricks_container
      address_prefixes = [local.subnet_prefixes.databricks_container]
      network_security_group = {
        id = module.network_security_group.resource_id
      }
      delegations = [{
        name = "databricks"
        service_delegation = {
          name = "Microsoft.Databricks/workspaces"
        }
      }]
    }
    private_endpoints = {
      name             = local.subnet_names.private_endpoints
      address_prefixes = [local.subnet_prefixes.private_endpoints]
    }
  }

  peerings = {
    spoke_to_hub = {
      name                                 = "peer-${local.name_suffix}-to-hub"
      remote_virtual_network_resource_id   = var.hub_virtual_network_id
      allow_forwarded_traffic              = true
      allow_virtual_network_access         = true
      create_reverse_peering               = true
      reverse_name                         = "peer-hub-to-${local.name_suffix}"
      reverse_allow_forwarded_traffic      = true
      reverse_allow_virtual_network_access = true
    }
  }
}

// Module: data_lake
// Purpose: Azure Data Lake Storage Gen2 account (hierarchical namespace) with public network access enabled, and a dfs
// private endpoint for private access, which registers in the hub-owned privatelink.dfs.core.windows.net zone.
module "data_lake" {
  source                        = "Azure/avm-res-storage-storageaccount/azurerm"
  version                       = "0.11.0"
  enable_telemetry              = var.enable_telemetry
  location                      = var.location
  parent_id                     = module.resource_group.resource_id
  name                          = module.naming.storage_account.name_unique
  account_kind                  = "StorageV2"
  account_tier                  = "Standard"
  account_replication_type      = var.data_lake_replication_type
  is_hns_enabled                = true
  public_network_access_enabled = true
  shared_access_key_enabled     = false

  # Public access stays on next to the dfs private endpoint: no firewall deny rule.
  network_rules = {
    default_action = "Allow"
  }
  tags = var.tags

  private_endpoints = {
    dfs = {
      name                            = "${module.naming.private_endpoint.slug}-dfs-${local.name_suffix}"
      private_service_connection_name = "psc-dfs-${local.name_suffix}"
      subresource_name                = "dfs"
      subnet_resource_id              = module.virtual_network.subnets["private_endpoints"].resource_id
      private_dns_zone_resource_ids   = [var.hub_private_dns_zone_dfs_id]
    }
  }
}

// Module: databricks_workspace
// Purpose: Premium Databricks workspace injected into the spoke VNet (secure cluster connectivity, no public IPs),
// with public network access enabled, and the databricks_ui_api private endpoint for private access
// (workspace UI/API and cluster-to-control-plane), registered in the hub-owned privatelink.azuredatabricks.net zone.
// Browser authentication already has a private endpoint in the hub, so it is not repeated here.
module "databricks_workspace" {
  source                      = "Azure/avm-res-databricks-workspace/azurerm"
  version                     = "0.6.0"
  enable_telemetry            = var.enable_telemetry
  location                    = var.location
  resource_group_name         = module.resource_group.name
  name                        = module.naming.databricks_workspace.name
  managed_resource_group_name = "${module.naming.resource_group.slug}-dbw-managed-${local.name_suffix}"
  sku                         = "premium"
  tags                        = var.tags

  # Subnets carry their NSG directly (azapi), so the subnet ID is the NSG association ID Databricks expects.
  custom_parameters = {
    no_public_ip                                         = true
    virtual_network_id                                   = module.virtual_network.resource_id
    public_subnet_name                                   = local.subnet_names.databricks_host
    public_subnet_network_security_group_association_id  = module.virtual_network.subnets["databricks_host"].resource_id
    private_subnet_name                                  = local.subnet_names.databricks_container
    private_subnet_network_security_group_association_id = module.virtual_network.subnets["databricks_container"].resource_id
  }

  # Public access stays on next to the private endpoints. With public access enabled, Databricks manages its own NSG rules.
  public_network_access_enabled         = true
  network_security_group_rules_required = "AllRules"

  private_endpoints = {
    databricks_ui_api = {
      name                            = "${module.naming.private_endpoint.slug}-dbw-ui-api-${local.name_suffix}"
      private_service_connection_name = "psc-dbw-ui-api-${local.name_suffix}"
      subresource_name                = "databricks_ui_api"
      subnet_resource_id              = module.virtual_network.subnets["private_endpoints"].resource_id
      private_dns_zone_resource_ids   = [var.hub_private_dns_zone_databricks_id]
    }
  }
  depends_on = [module.resource_group]
}
