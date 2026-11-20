resource "databricks_grants" "main" {
  storage_credential = var.storage_credential_id
  dynamic "grant" {
    for_each = jsondecode(data.local_file.permissions.content).changes
    content {
      principal  = grant.value.principal
      privileges = grant.value.add
    }
  }
}


data "local_file" "permissions" {
  filename = var.json_file_path
}

locals {
  permissions = jsondecode(data.local_file.permissions.content).changes
}