output "metastore_id" {
  description = "The ID of the Unity Catalog metastore"
  value       = module.metastore.id
}

output "metastore_owner" {
  description = "The owner of the Unity Catalog metastore"
  value       = module.metastore.metastore_owner
}
