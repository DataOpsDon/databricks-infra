output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.resource_group.resource_id
}


output "catalog_ids" {
  description = "IDs of the medallion catalogs, keyed by catalog name"
  value       = module.catalogs.ids
}

output "storage_credential_name" {
  description = "The name of the storage credential"
  value       = module.storage_credential.name
}
