

data "local_file" "json_data" {
  filename = var.json_file_path
}

locals {
  json_content = jsondecode(data.local_file.json_data.content)
  owner        = local.json_content.changes[0].principal
}

resource "databricks_metastore" "main" {
  name          = "metastore_${var.region}"
  storage_root  = var.storage_root
  owner         = local.owner
  region        = var.region
  force_destroy = false
}