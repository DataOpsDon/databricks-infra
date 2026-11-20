resource "databricks_schema" "main" {
  catalog_name = var.catalog_id
  name         = var.name
  owner        = var.owner
  comment      = "this database is managed by terraform"
}
