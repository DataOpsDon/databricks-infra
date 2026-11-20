resource "databricks_volume" "main" {
  name             = var.name
  catalog_name     = var.catalog_name
  schema_name      = var.schema_name
  volume_type      = var.volume_type
  owner            = var.owner
  comment          = "this volume is managed by terraform"
  storage_location = var.volume_type == "MANAGED" ? null : var.storage_location
}


# data "local_file" "json_owners" {
#   filename = var.owner
# }

# locals {
#   json_content = jsondecode(data.local_file.json_owners.content)
#   owner        = local.json_content.owner
# }