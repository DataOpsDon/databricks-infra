resource "databricks_external_location" "main" {
  name           = var.name
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  url = format("abfss://%s@%s.dfs.core.windows.net",
    var.data_lake_container,
  var.data_lake_name)

  credential_name = var.credential_id
  comment         = "Managed by TF"
  owner           = var.owner
}

resource "databricks_workspace_binding" "binding" {
  securable_name = databricks_external_location.main.name
  securable_type = "external_location"
  workspace_id   = var.workspace_id
}
