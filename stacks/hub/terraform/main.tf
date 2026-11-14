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
// and a small subnet for the private DNS resolver inbound endpoint.
module "virtual_network" {
  source           = "Azure/avm-res-network-virtualnetwork/azurerm"
  version          = "0.23.0"
  enable_telemetry = var.enable_telemetry
  location         = var.location
  parent_id        = module.resource_group.resource_id
  name             = module.naming.virtual_network.name
  address_space    = [var.vnet_address_space]
  tags             = var.tags

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
  enable_telemetry = var.enable_telemetry
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
