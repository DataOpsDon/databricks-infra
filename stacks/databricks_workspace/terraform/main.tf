// ---------------------------------------------------------------------------------------------------------------------
// DATABRICKS_WORKSPACE Stack - Databricks Workspace Config
// This Terraform configuration provisions resources for the databricks_workspace deployment.
//
// Notes:
// - Naming is centralised via the `naming` module to ensure consistent resource names across environments.

// Module: naming
// Purpose: Centralised naming standards for resources (location, project, environment, LZ short code).
module "naming" {
  source   = "../../../templates/utils"
  location = var.location
  project  = var.project
  lz       = "<FILL ME IN>"
  suffix   = var.environment
  lz_short = "<FILL ME IN>"
}

// Module: resource_group
// Purpose: Creates the databricks_workspace resource group to contain all resources in this stack.



// Module: storage_credential
// Purpose: Unity Catalog storage credential backed by the spoke's Databricks access connector.
//module "storage_credential" {
//  source       = "../../../templates/modules/uc_storage_credential"
//  name         = "sc-${var.project}-${var.environment}-${var.location_short}"
//  connector_id = data.terraform_remote_state.spoke.outputs.access_connector_id
//  owner        = var.owner
//  workspace_id = local.workspace_id
//  providers = {
//    databricks = databricks.workspace
//  }
//}

// Module: external_locations
// Purpose: One external location per medallion container. Required so the catalogs can use the containers as storage root.
module "external_locations" {
  source              = "../../../templates/modules/uc_external_location"
  for_each            = local.catalog_containers
  name                = "ext-${local.catalog_names[each.key]}"
  data_lake_name      = local.data_lake_name
  data_lake_container = each.value
  credential_id       = module.storage_credential.name
  owner               = var.owner
  workspace_id        = local.workspace_id
  providers = {
    databricks = databricks.workspace
  }
}

// Module: catalogs
// Purpose: Creates the bronze, silver and gold catalogs, each rooted in its data lake container.
module "catalogs" {
  source             = "../../../templates/modules/uc_data_catalog"
  data_lake_name     = local.data_lake_name
  catalog_names      = local.catalog_names
  catalog_containers = local.catalog_containers
  owner              = var.owner
  metastore_id       = data.databricks_metastore.current.id
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [module.external_locations]
}

// Module: metastore_permissions
// Purpose: Metastore-level grants from the global config JSON.
module "metastore_permissions" {
  source         = "../../../templates/modules/uc_data_metastore_permissions"
  metastore_id   = data.databricks_metastore.current.id
  json_file_path = "../config/unity-catalog-permissions/global/metastore.json"
  providers = {
    databricks = databricks.workspace
  }
}

// Module: storage_credential_permissions
// Purpose: Grants on the storage credential from the per-environment config JSON.
//module "storage_credential_permissions" {
//  source                = "../../../templates/modules/uc_data_storage_credential_permissions"
//  storage_credential_id = module.storage_credential.name
//  json_file_path        = lower("../config/unity-catalog-permissions/${var.environment}/storage_credential.json")
//  providers = {
//    databricks = databricks.workspace
//  }
//}

// Module: external_location_permissions
// Purpose: Grants on each external location from the per-environment config JSON.
module "external_location_permissions" {
  source               = "../../../templates/modules/uc_data_external_location_permissions"
  for_each             = module.external_locations
  external_location_id = each.value.name
  json_file_path       = lower("../config/unity-catalog-permissions/${var.environment}/external_location.json")
  providers = {
    databricks = databricks.workspace
  }
}

// Module: catalog_permissions
// Purpose: Grants on each catalog from the per-environment catalog_<layer>.json.
module "catalog_permissions" {
  source         = "../../../templates/modules/uc_data_catalog_permissions"
  for_each       = local.catalog_names
  catalogs       = [each.value]
  json_file_path = lower("../config/unity-catalog-permissions/${var.environment}/catalog_${each.key}.json")
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [module.catalogs]
}


// Module: workspace_admins
// Purpose: Assigns the databricks_admins account group to the spoke workspace as workspace admins.
module "workspace_admins" {
  source       = "../../../templates/modules/uc_databricks_workspace_assignment"
  workspace_id = local.workspace_id
  principal_id = "databricks_admins"
  role         = "ADMIN"
  providers = {
    databricks          = databricks.workspace
    databricks.accounts = databricks.accounts
  }
}
