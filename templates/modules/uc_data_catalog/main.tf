locals {
  catalog_map = {
    for catalog_type, catalog_name in var.catalog_names :
    catalog_name => var.catalog_containers[catalog_type]
  }
}

resource "databricks_catalog" "main" {
  for_each = local.catalog_map
  name     = each.key
  storage_root = format("abfss://%s@%s.dfs.core.windows.net",
    each.value,
    var.data_lake_name
  )
  comment        = "this catalog is managed by terraform"
  isolation_mode = "ISOLATED"
  metastore_id   = var.metastore_id
  owner          = var.owner
}
