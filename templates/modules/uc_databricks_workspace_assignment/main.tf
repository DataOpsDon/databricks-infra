data "databricks_group" "principal" {
  display_name = var.principal_id
  provider     = databricks.accounts
}

resource "databricks_mws_permission_assignment" "add_admin_group" {
  provider     = databricks.accounts
  workspace_id = var.workspace_id
  principal_id = tonumber(data.databricks_group.principal.id)
  permissions  = ["${var.role}"]
}
