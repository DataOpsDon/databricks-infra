output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.resource_group.resource_id
}


output "virtual_network_id" {
  description = "The ID of the hub virtual network"
  value       = module.virtual_network.resource_id
}

output "databricks_subnet_names" {
  description = "Names of the Databricks host (public) and container (private) subnets"
  value = {
    host      = local.subnet_names.databricks_host
    container = local.subnet_names.databricks_container
  }
}

output "network_security_group_id" {
  description = "The ID of the NSG attached to the Databricks subnets"
  value       = module.network_security_group.resource_id
}

output "private_dns_resolver_inbound_ips" {
  description = "Inbound endpoint IP addresses of the private DNS resolver"
  value       = module.private_dns_resolver.inbound_endpoint_ips
}

output "private_dns_zone_databricks_id" {
  description = "The ID of the privatelink.azuredatabricks.net private DNS zone"
  value       = module.private_dns_zone_databricks.resource_id
}

output "private_dns_zone_dfs_id" {
  description = "The ID of the privatelink.dfs.core.windows.net private DNS zone"
  value       = module.private_dns_zone_dfs.resource_id
}

output "private_dns_zone_blob_id" {
  description = "The ID of the privatelink.blob.core.windows.net private DNS zone"
  value       = module.private_dns_zone_blob.resource_id
}

output "databricks_workspace_id" {
  description = "The Azure resource ID of the Databricks workspace"
  value       = module.databricks_workspace.resource_id
}

output "databricks_workspace_url" {
  description = "The workspace URL (resolves to a private IP through the private DNS zone)"
  value       = module.databricks_workspace.databricks_workspace_url
}

output "bastion_name" {
  description = "Name of the Bastion host (Standard SKU)"
  value       = module.bastion.name
}
