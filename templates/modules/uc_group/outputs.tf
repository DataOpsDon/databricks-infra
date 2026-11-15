
output "created_groups" {
  description = "List of created Databricks groups"
  value       = [for group in databricks_group.groups : group.display_name]
}

output "ids" {
  description = "List of Databricks group IDs"
  value       = [for group in databricks_group.groups : group.id]
}
