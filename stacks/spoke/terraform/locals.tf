locals {
  name_suffix = join("-", [var.project, var.environment, var.location_short])

  # Subnet layout inside var.vnet_address_space (/22):
  #   0.0/26   Databricks host (public) subnet
  #   0.64/26  Databricks container (private) subnet
  #   0.128/26 Private endpoints (Databricks workspace and data lake dfs)
  #   0.192/26 Free
  #   1.0/25   Databricks gateway subnet
  subnet_prefixes = {
    databricks_host      = cidrsubnet(var.vnet_address_space, 4, 0)
    databricks_container = cidrsubnet(var.vnet_address_space, 4, 1)
    private_endpoints    = cidrsubnet(var.vnet_address_space, 4, 2)
    databricks_gateway   = cidrsubnet(var.vnet_address_space, 3, 2)
  }

  subnet_names = {
    databricks_host      = "${module.naming.subnet.slug}-databricks-host-${local.name_suffix}"
    databricks_container = "${module.naming.subnet.slug}-databricks-container-${local.name_suffix}"
    private_endpoints    = "${module.naming.subnet.slug}-privateendpoints-${local.name_suffix}"
    databricks_gateway   = "${module.naming.subnet.slug}-databricks-gateway-${local.name_suffix}"
  }
}
