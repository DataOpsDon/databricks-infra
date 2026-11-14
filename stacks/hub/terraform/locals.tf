locals {
  name_suffix = join("-", [var.project, var.environment, var.location_short])

  # Subnet layout inside var.vnet_address_space (/22):
  #   0.0/26   Databricks host (public) subnet
  #   0.64/26  Databricks container (private) subnet
  #   0.128/28 Private DNS resolver inbound endpoint
  #   0.192/26 Private endpoints (Databricks workspace and browser authentication)
  #   1.0/26   Jump box VM 
  #   1.64/26  AzureBastionSubnet (Bastion Standard, reaches peered VNets)
  subnet_prefixes = {
    databricks_host      = cidrsubnet(var.vnet_address_space, 4, 0)
    databricks_container = cidrsubnet(var.vnet_address_space, 4, 1)
    dns_resolver_inbound = cidrsubnet(var.vnet_address_space, 6, 8)
    private_endpoints    = cidrsubnet(var.vnet_address_space, 4, 3)
    bastion              = cidrsubnet(var.vnet_address_space, 4, 5)
  }

  subnet_names = {
    databricks_host      = "${module.naming.subnet.slug}-databricks-host-${local.name_suffix}"
    databricks_container = "${module.naming.subnet.slug}-databricks-container-${local.name_suffix}"
    dns_resolver_inbound = "${module.naming.subnet.slug}-dnsresolver-in-${local.name_suffix}"
    private_endpoints    = "${module.naming.subnet.slug}-privateendpoints-${local.name_suffix}"
    bastion              = "AzureBastionSubnet" # fixed name required by Azure
  }
}
