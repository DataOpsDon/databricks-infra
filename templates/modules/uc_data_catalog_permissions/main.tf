data "local_file" "catalog_permissions" {
  filename = var.json_file_path
}

locals {
  permissions = jsondecode(data.local_file.catalog_permissions.content).changes
}

resource "databricks_grants" "catalog_permissions" {

  for_each = {
    for catalog in var.catalogs : catalog => {
      permissions = [
        for perm in local.permissions :
        {
          principal  = perm.principal
          privileges = perm.add
        }
      ]
    }
  }

  catalog = each.key


  dynamic "grant" {
    for_each = each.value.permissions
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}