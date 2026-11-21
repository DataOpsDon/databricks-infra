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


// Module: private_network_gateway
// Purpose: Network connectivity configuration with a private network gateway that lets serverless compute reach private
// destinations in the spoke VNet. The gateway uses the /25 Databricks gateway subnet created by the spoke stack.
module "private_network_gateway" {
  source                             = "../../../templates/modules/uc_databricks_private_network_gateway"
  ncc_name                           = "ncc-${var.project}-${var.environment}-${var.location_short}"
  region                             = var.location
  display_name                       = "pgw-${var.project}-${var.environment}-${var.location_short}"
  subnet_resource_id                 = data.terraform_remote_state.spoke.outputs.databricks_gateway_subnet_id
  bandwidth_tier_gigabits_per_second = var.private_gateway_bandwidth_tier
  traffic_mode                       = "SPECIFIC_DESTINATIONS"
  destinations                       = var.private_gateway_destinations
  dns_resolver_ips                   = var.private_gateway_dns_resolver_ips
  providers = {
    databricks = databricks.accounts
  }
}
