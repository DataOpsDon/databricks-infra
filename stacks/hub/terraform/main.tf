// ---------------------------------------------------------------------------------------------------------------------
// HUB Stack - central networking
// This Terraform configuration provisions resources for the hub deployment.
//
// Notes:
// - Naming is centralised via the `naming` module to ensure consistent resource names across environments.
// - Only Azure Verified Modules (AVM) are used: no `resource` blocks and no custom modules.

// Module: naming
// Purpose: Centralised naming standards for resources (project, environment, location short code).
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.4"

  suffix = [var.project, var.environment, var.location_short]
}

// Module: resource_group
// Purpose: Creates the hub resource group to contain all resources in this stack.
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
// Purpose: Hub virtual network (/22) with two /26 Databricks subnets (host and container)
// a subnet for private endpoints and a small subnet for the private DNS resolver inbound endpoint.
module "virtual_network" {
  source           = "Azure/avm-res-network-virtualnetwork/azurerm"
  version          = "0.23.0"
  enable_telemetry = var.enable_telemetry
  location         = var.location
  parent_id        = module.resource_group.resource_id
  name             = module.naming.virtual_network.name
  address_space    = [var.vnet_address_space]
  tags             = var.tags
  dns_servers      = ["10.10.0.132"]
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
    dns_resolver_inbound = {
      name             = local.subnet_names.dns_resolver_inbound
      address_prefixes = [local.subnet_prefixes.dns_resolver_inbound]
      delegations = [{
        name = "dnsresolver"
        service_delegation = {
          name = "Microsoft.Network/dnsResolvers"
        }
      }]
    }
  }
}

// Module: private_dns_resolver
// Purpose: Private DNS resolver with an inbound endpoint, so on-premises and peered networks can resolve
// the private DNS zones linked to this virtual network.
module "private_dns_resolver" {
  source                      = "Azure/avm-res-network-dnsresolver/azurerm"
  version                     = "0.9.0"
  enable_telemetry            = var.enable_telemetry
  location                    = var.location
  parent_id                   = module.resource_group.resource_id
  name                        = module.naming.dns_private_resolver.name
  virtual_network_resource_id = module.virtual_network.resource_id
  tags                        = var.tags

  inbound_endpoints = {
    inbound = {
      name        = "${module.naming.dns_private_resolver.slug}-in-${local.name_suffix}"
      subnet_name = local.subnet_names.dns_resolver_inbound
    }
  }

  depends_on = [module.virtual_network]
}

// Module: private_dns_zone_databricks
// Purpose: privatelink.azuredatabricks.net, used by both the Databricks workspace private endpoint
// (databricks_ui_api) and the browser authentication private endpoint (browser_authentication).
module "private_dns_zone_databricks" {
  source           = "Azure/avm-res-network-privatednszone/azurerm"
  version          = "0.6.0"
  enable_telemetry = false
  parent_id        = module.resource_group.resource_id
  domain_name      = "privatelink.azuredatabricks.net"
  tags             = var.tags

  virtual_network_links = {
    hub = {
      name               = "link-${module.naming.virtual_network.name}"
      virtual_network_id = module.virtual_network.resource_id
    }
  }
}

// Module: private_dns_zone_dfs
// Purpose: privatelink.dfs.core.windows.net for ADLS Gen2 dfs private endpoints (deployed by the spoke stack).
// Linked to the hub VNet, plus any spoke VNets listed in var.spoke_virtual_network_ids.
module "private_dns_zone_dfs" {
  source           = "Azure/avm-res-network-privatednszone/azurerm"
  version          = "0.6.0"
  enable_telemetry = false
  parent_id        = module.resource_group.resource_id
  domain_name      = "privatelink.dfs.core.windows.net"
  tags             = var.tags

  virtual_network_links = merge(
    {
      hub = {
        name               = "link-${module.naming.virtual_network.name}"
        virtual_network_id = module.virtual_network.resource_id
      }
    },
    {
      for k, id in var.spoke_virtual_network_ids : k => {
        name               = "link-${k}-${local.name_suffix}"
        virtual_network_id = id
      }
    }
  )
}

// Module: databricks_workspace
// Purpose: Premium Databricks workspace injected into the hub VNet (secure cluster connectivity, no public IPs),
// with public network access disabled. It is reachable only through its private endpoints:
//   - databricks_ui_api:          workspace UI/API (front end) and cluster-to-control-plane (back end)
//   - browser_authentication:     SSO browser login callback for the region
// Both endpoints register in the privatelink.azuredatabricks.net private DNS zone.
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

  public_network_access_enabled         = false
  network_security_group_rules_required = "NoAzureDatabricksRules"

  private_endpoints = {
    browser_authentication = {
      name                            = "${module.naming.private_endpoint.slug}-dbw-browser-auth-${local.name_suffix}"
      private_service_connection_name = "psc-dbw-browser-auth-${local.name_suffix}"
      subresource_name                = "browser_authentication"
      subnet_resource_id              = module.virtual_network.subnets["private_endpoints"].resource_id
      private_dns_zone_resource_ids   = [module.private_dns_zone_databricks.resource_id]
    }
  }
}
