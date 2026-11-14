locals {
  name_suffix = join("-", [var.project, var.environment, var.location_short])

  # Subnet layout inside var.vnet_address_space (/22):
  #   0.0/24   Managed DevOps Pool runners (delegated, NAT gateway for outbound)
  subnet_prefixes = {
    devops_pool = cidrsubnet(var.vnet_address_space, 2, 0)
  }

  subnet_names = {
    devops_pool = "${module.naming.subnet.slug}-devopspool-${local.name_suffix}"
  }
}
