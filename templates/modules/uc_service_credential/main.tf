resource "databricks_credential" "external" {
  name           = var.name
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  azure_managed_identity {
    access_connector_id = var.connector_id
  }
  comment = "Managed by TF"
  purpose = "SERVICE"
  owner   = var.owner
}

resource "databricks_workspace_binding" "binding" {
  securable_name = databricks_credential.external.name
  securable_type = "credential"
  workspace_id   = var.workspace_id
}