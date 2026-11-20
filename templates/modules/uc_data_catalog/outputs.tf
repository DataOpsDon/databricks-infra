output "names" {
  description = "Names of all created catalogs."
  value       = [for c in databricks_catalog.main : c.name]
}

output "ids" {
  description = "IDs of all created catalogs."
  value       = { for c in databricks_catalog.main : c.name => c.id }
}