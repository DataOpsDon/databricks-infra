locals {
  workspace_ids = {
    hub   = data.terraform_remote_state.hub.outputs.databricks_workspace_id
    spoke = data.terraform_remote_state.spoke.outputs.databricks_workspace_id

  }
}

