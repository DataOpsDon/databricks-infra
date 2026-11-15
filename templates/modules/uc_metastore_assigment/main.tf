resource "databricks_metastore_assignment" "main" {
  metastore_id = var.metastore_id
  workspace_id = var.workspace_id
  lifecycle {
    ignore_changes = [
      metastore_id
    ]
  }
}
