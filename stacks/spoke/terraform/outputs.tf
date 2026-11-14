output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.resource_group.resource_id
}

output "virtual_network_id" {
  description = "The ID of the spoke virtual network"
  value       = module.virtual_network.resource_id
}

output "databricks_subnet_names" {
  description = "Names of the Databricks host (public) and container (private) subnets"
  value = {
    host      = local.subnet_names.databricks_host
    container = local.subnet_names.databricks_container
  }
}

output "data_lake_id" {
  description = "The ID of the data lake storage account"
  value       = module.data_lake.resource_id
}

output "data_lake_name" {
  description = "The name of the data lake storage account"
  value       = module.data_lake.name
}

output "private_dns_zone_dfs_id" {
  description = "The ID of the privatelink.dfs.core.windows.net private DNS zone"
  value       = module.private_dns_zone_dfs.resource_id
}

output "databricks_workspace_id" {
  description = "The Azure resource ID of the Databricks workspace"
  value       = module.databricks_workspace.resource_id
}

output "databricks_workspace_url" {
  description = "The workspace URL (resolves to a private IP through the private DNS zone)"
  value       = module.databricks_workspace.databricks_workspace_url
}
