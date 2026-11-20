output "ids" {
  description = "List of SQL warehouse IDs"
  value       = [for warehouse in databricks_sql_endpoint.sql_warehouse : warehouse.id]
}