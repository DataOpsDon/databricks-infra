output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.resource_group.resource_id
}


output "jumpbox_name" {
  description = "Name of the jump box VM (connect with Bastion in the hub)"
  value       = module.jumpbox.name
}

output "jumpbox_admin_username" {
  description = "Admin user name of the jump box"
  value       = module.jumpbox.admin_username
}

output "jumpbox_admin_password" {
  description = "Generated admin password of the jump box"
  value       = module.jumpbox.admin_password
  sensitive   = true
}

output "virtual_network_id" {
  description = "The ID of the shared virtual network"
  value       = module.virtual_network.resource_id
}

output "sql_vm_name" {
  description = "Name of the SQL Server VM (connect with Bastion in the hub)"
  value       = module.sql_vm.name
}

output "sql_vm_admin_username" {
  description = "Admin user name of the SQL Server VM"
  value       = module.sql_vm.admin_username
}

output "sql_vm_admin_password" {
  description = "Generated admin password of the SQL Server VM"
  value       = module.sql_vm.admin_password
  sensitive   = true
}
