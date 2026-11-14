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

output "dev_center_id" {
  description = "Dev Center resource ID (parent of the Dev Center project the pool needs)"
  value       = module.dev_center.resource_id
}

output "managed_devops_pool_id" {
  description = "Resource ID of the Managed DevOps Pool"
  value       = module.managed_devops_pool.resource_id
}

output "virtual_network_id" {
  description = "The ID of the shared virtual network"
  value       = module.virtual_network.resource_id
}
