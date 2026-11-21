// ---------------------------------------------------------------------------------------------------------------------
// DATABRICKS Stack - deployment into databricks_account and uc
// This Terraform configuration provisions resources for the databricks_account deployment.
//
// Notes:
// - Naming is centralised via the `naming` module to ensure consistent resource names across environments.

// Module: naming
// Purpose: Centralised naming standards for resources (location, project, environment, LZ short code).


// Module: metastore
// Purpose: Creates the Unity Catalog metastore for the region. Owner comes from the global metastore config JSON.
module "metastore" {
  source         = "../../../templates/modules/uc_metastore"
  name           = var.metastore_name
  region         = var.location
  json_file_path = lower("../config/unity-catalog-permissions/global/metastore.json")
  providers = {
    databricks = databricks.accounts
  }
}

// Module: metastore_assignment
// Purpose: Assigns the metastore to each workspace (keyed by a friendly name, value is the numeric Databricks workspace ID).
module "metastore_assignment" {
  source       = "../../../templates/modules/uc_metastore_assigment"
  for_each     = local.workspace_ids
  metastore_id = module.metastore.id
  workspace_id = each.value
  providers = {
    databricks = databricks.accounts
  }
}

