resource "databricks_grants" "main" {
  metastore = var.metastore_id
  dynamic "grant" {
    for_each = jsondecode(data.local_file.permissions.content).changes
    content {
      principal  = grant.value.principal
      privileges = grant.value.add
    }
  }
  lifecycle {
    ignore_changes = [
      metastore
    ]
  }
}


data "local_file" "permissions" {
  filename = var.json_file_path
}

locals {
  permissions = jsondecode(data.local_file.permissions.content).changes
}
