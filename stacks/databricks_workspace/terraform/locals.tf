locals {
  workspace_id   = data.terraform_remote_state.spoke.outputs.databricks_workspace_id
  data_lake_name = data.terraform_remote_state.spoke.outputs.data_lake_name

  # Medallion layer => catalog name (e.g. bronze-dev) and the data lake container backing it.
  layers = ["bronze", "silver", "gold"]
  catalog_names = {
    for layer in local.layers : layer => "${layer}-${var.environment}"
  }
  catalog_containers = {
    for layer in local.layers : layer => layer
  }
}
