output "metastore_owner" {
  description = "Owner of the Databricks metastore"
  value       = databricks_metastore.main.owner
}

output "id" {
  description = "Databricks metastore ID"
  value       = databricks_metastore.main.id

}
