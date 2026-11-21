locals {
  name_suffix = join("-", [var.project, var.environment, var.location_short])

  # Subnet layout inside var.vnet_address_space (/22):
  #   0.0/26   Jump box VM (NAT gateway for outbound)
  #   0.64/26  SQL Server VM (NAT gateway for outbound)
  subnet_prefixes = {
    jumpbox = cidrsubnet(var.vnet_address_space, 4, 0)
    sql     = cidrsubnet(var.vnet_address_space, 4, 1)
  }

  subnet_names = {
    jumpbox = "${module.naming.subnet.slug}-jumpbox-${local.name_suffix}"
    sql     = "${module.naming.subnet.slug}-sql-${local.name_suffix}"
  }

  # Microsoft Entra ID sign-in for the Windows VMs. Needs the VM's system-assigned identity.
  aad_login_extension = {
    aad_login = {
      name                       = "AADLogin"
      publisher                  = "Microsoft.Azure.ActiveDirectory"
      type                       = "AADLoginForWindows"
      type_handler_version       = "1.0"
      auto_upgrade_minor_version = true
    }
  }
}
