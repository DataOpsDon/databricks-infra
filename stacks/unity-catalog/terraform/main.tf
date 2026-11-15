// NOTE: This configuration assumes the Unity Catalog metastore already exists (queried via data source below).
//       If a metastore is required per deployment, extend this stack to provision it before the assignment module.

// Assigns the Unity Catalog metastore to the Databricks workspace
module "metastore_assigment" {
  source       = "../modules/uc_metastore_assigment"
  metastore_id = data.databricks_metastore.main.id
  workspace_id = data.terraform_remote_state.dlz.outputs.databricks_id
  providers = {
    databricks = databricks.accounts
  }
}

// Storage credential using the storage access connector for data lake access
module "storage_credentials" {
  source       = "../modules/uc_storage_credential"
  name         = data.terraform_remote_state.dlz.outputs.databricks_storage_access_connector_name
  connector_id = data.terraform_remote_state.dlz.outputs.databricks_storage_access_connector_id
  owner        = var.owner
  workspace_id = data.terraform_remote_state.dlz.outputs.databricks_id
  providers = {
    databricks = databricks.workspace
  }
}

// Applies permissions to the storage credential
module "storage_credentials_permissions" {
  source                = "../modules/uc_data_storage_credential_permissions"
  json_file_path        = lower("../config/unity-catalog-permissions/${var.environment}/storage_credential.json")
  storage_credential_id = module.storage_credentials.id
  providers = {
    databricks = databricks.workspace
  }
}

// Service credential using the service access connector for service-to-service authentication
module "service_credentials" {
  source       = "../modules/uc_service_credential"
  name         = data.terraform_remote_state.dlz.outputs.databricks_service_access_connector_name
  connector_id = data.terraform_remote_state.dlz.outputs.databricks_service_access_connector_id
  owner        = var.owner
  workspace_id = data.terraform_remote_state.dlz.outputs.databricks_id
  providers = {
    databricks = databricks.workspace
  }
}

// Storage credential using the ingestion access connector for data ingestion workflows
module "ingestion_credentials" {
  source       = "../modules/uc_storage_credential"
  name         = data.terraform_remote_state.dlz.outputs.databricks_ingestion_access_connector_name
  connector_id = data.terraform_remote_state.dlz.outputs.databricks_ingestion_access_connector_id
  owner        = var.owner
  workspace_id = data.terraform_remote_state.dlz.outputs.databricks_id
  providers = {
    databricks = databricks.workspace
  }
}

// Applies permissions to the ingestion storage credential
module "ingestion_credentials_permissions" {
  source                = "../modules/uc_data_storage_credential_permissions"
  json_file_path        = lower("../config/unity-catalog-permissions/${var.environment}/storage_credential.json")
  storage_credential_id = module.ingestion_credentials.id
  providers = {
    databricks = databricks.workspace
  }
}

// External location for the bronze layer (raw ingested data)
module "external_location_bronze" {
  source              = "../modules/uc_external_location"
  name                = "${data.terraform_remote_state.dlz.outputs.data_lake_name}-bronze"
  data_lake_container = "bronze"
  credential_id       = module.storage_credentials.id
  data_lake_name      = data.terraform_remote_state.dlz.outputs.data_lake_name
  owner               = var.owner
  workspace_id        = data.terraform_remote_state.dlz.outputs.databricks_id
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.storage_credentials
  ]
}

// External location for the silver layer (cleansed and conformed data)
module "external_location_silver" {
  source              = "../modules/uc_external_location"
  name                = "${data.terraform_remote_state.dlz.outputs.data_lake_name}-silver"
  data_lake_container = "silver"
  credential_id       = module.storage_credentials.id
  data_lake_name      = data.terraform_remote_state.dlz.outputs.data_lake_name
  owner               = var.owner
  workspace_id        = data.terraform_remote_state.dlz.outputs.databricks_id
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.storage_credentials
  ]
}

// External location for the gold layer (curated business-ready data)
module "external_location_gold" {
  source              = "../modules/uc_external_location"
  name                = "${data.terraform_remote_state.dlz.outputs.data_lake_name}-gold"
  data_lake_container = "gold"
  credential_id       = module.storage_credentials.id
  data_lake_name      = data.terraform_remote_state.dlz.outputs.data_lake_name
  owner               = var.owner
  workspace_id        = data.terraform_remote_state.dlz.outputs.databricks_id
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.storage_credentials
  ]
}

// External location for Unity Catalog managed storage
module "external_location_unity_catalog" {
  source              = "../modules/uc_external_location"
  name                = "${data.terraform_remote_state.dlz.outputs.data_lake_name}-unity-catalog"
  data_lake_container = "unity-catalog"
  credential_id       = module.storage_credentials.id
  data_lake_name      = data.terraform_remote_state.dlz.outputs.data_lake_name
  owner               = var.owner
  workspace_id        = data.terraform_remote_state.dlz.outputs.databricks_id
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.storage_credentials
  ]
}

// External location for landing
module "external_location_landing" {
  source              = "../modules/uc_external_location"
  name                = "${data.terraform_remote_state.dlz.outputs.data_lake_name}-landing"
  data_lake_container = "landing"
  credential_id       = module.storage_credentials.id
  data_lake_name      = data.terraform_remote_state.dlz.outputs.data_lake_name
  owner               = var.owner
  workspace_id        = data.terraform_remote_state.dlz.outputs.databricks_id
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.storage_credentials
  ]
}

// Applies permissions to the bronze external location
module "external_location_bronze_permissions" {
  source               = "../modules/uc_data_external_location_permissions"
  json_file_path       = lower("../config/unity-catalog-permissions/${var.environment}/external_location.json")
  external_location_id = module.external_location_bronze.id
  providers = {
    databricks = databricks.workspace
  }
}

// Applies permissions to the silver external location
module "external_location_silver_permissions" {
  source               = "../modules/uc_data_external_location_permissions"
  json_file_path       = lower("../config/unity-catalog-permissions/${var.environment}/external_location.json")
  external_location_id = module.external_location_silver.id
  providers = {
    databricks = databricks.workspace
  }
}

// Applies permissions to the gold external location
module "external_location_gold_permissions" {
  source               = "../modules/uc_data_external_location_permissions"
  json_file_path       = lower("../config/unity-catalog-permissions/${var.environment}/external_location.json")
  external_location_id = module.external_location_gold.id
  providers = {
    databricks = databricks.workspace
  }
}

// Applies permissions to the Unity Catalog external location
module "external_location_unity_catalog_permissions" {
  source               = "../modules/uc_data_external_location_permissions"
  json_file_path       = lower("../config/unity-catalog-permissions/${var.environment}/external_location.json")
  external_location_id = module.external_location_unity_catalog.id
  providers = {
    databricks = databricks.workspace
  }
}

// Applies permissions to the landing external location
module "external_location_landing_permissions" {
  source               = "../modules/uc_data_external_location_permissions"
  json_file_path       = lower("../config/unity-catalog-permissions/${var.environment}/external_location.json")
  external_location_id = module.external_location_landing.id
  providers = {
    databricks = databricks.workspace
  }
}

// Creates Unity Catalog data catalogs (bronze, silver, gold, resources)
module "databricks_catalogs" {
  source             = "../modules/uc_data_catalog"
  data_lake_name     = data.terraform_remote_state.dlz.outputs.data_lake_name
  metastore_id       = data.databricks_metastore.main.id
  owner              = var.owner
  catalog_names      = var.catalog_names
  catalog_containers = var.catalog_containers
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.external_location_bronze,
    module.external_location_silver,
    module.external_location_gold,
    module.external_location_unity_catalog,
    module.external_location_landing
  ]
}

// Applies permissions to Unity Catalog catalogs based on group memberships
module "databricks_catalog_permissions" {
  source         = "../modules/uc_data_catalog_permissions"
  json_file_path = lower("../config/unity-catalog-permissions/${var.environment}/catalog.json")
  catalogs       = [for catalog in module.databricks_catalogs.names : catalog]
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.databricks_catalogs
  ]
}

// Creates contracts schema in the resources catalog for metadata storage
module "schema_contracts" {
  source     = "../modules/uc_schema"
  catalog_id = module.databricks_catalogs.ids[var.catalog_names["resources"]]
  name       = "contracts"
  owner      = var.owner
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.databricks_catalogs
  ]
}

// Creates a managed volume within the contracts schema for storing contract files
module "volume_contracts" {
  source       = "../modules/uc_schema_volume"
  name         = "contracts"
  catalog_name = var.catalog_names["resources"]
  schema_name  = module.schema_contracts.name
  volume_type  = "MANAGED"
  owner        = var.owner
  providers = {
    databricks = databricks.workspace
  }
}

// Creates temp schema in the silver catalog for intermediate processing
module "schema_temp" {
  source     = "../modules/uc_schema"
  catalog_id = module.databricks_catalogs.ids[var.catalog_names["silver"]]
  name       = "temp"
  owner      = var.owner
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.databricks_catalogs
  ]
}

// Creates temp schema in the gold catalog for intermediate processing
module "schema_tempgold" {
  source     = "../modules/uc_schema"
  catalog_id = module.databricks_catalogs.ids[var.catalog_names["gold"]]
  name       = "temp"
  owner      = var.owner
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.databricks_catalogs
  ]
}

// Creates logging schema in the resources catalog for platform logging
module "schema_logging" {
  source     = "../modules/uc_schema"
  catalog_id = module.databricks_catalogs.ids[var.catalog_names["resources"]]
  name       = "logging"
  owner      = var.owner
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.databricks_catalogs
  ]
}

// Creates a managed volume within the logging schema for storing log files
module "volume_logging" {
  source       = "../modules/uc_schema_volume"
  name         = "logs"
  catalog_name = var.catalog_names["resources"]
  schema_name  = module.schema_logging.name
  volume_type  = "MANAGED"
  owner        = var.owner
  providers = {
    databricks = databricks.workspace
  }
}

// Creates packages schema in the resources catalog for Python package wheels
module "schema_packages" {
  source     = "../modules/uc_schema"
  catalog_id = module.databricks_catalogs.ids[var.catalog_names["resources"]]
  name       = "packages"
  owner      = var.owner
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.databricks_catalogs
  ]
}

// Creates a managed volume within the packages schema for storing Python package wheels
module "volume_packages" {
  source       = "../modules/uc_schema_volume"
  name         = "packages"
  catalog_name = var.catalog_names["resources"]
  schema_name  = module.schema_packages.name
  volume_type  = "MANAGED"
  owner        = var.owner
  providers = {
    databricks = databricks.workspace
  }
}

// Creates functions schema in the resources catalog for SQL masking functions
module "schema_functions" {
  source     = "../modules/uc_schema"
  catalog_id = module.databricks_catalogs.ids[var.catalog_names["resources"]]
  name       = "functions"
  owner      = var.owner
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.databricks_catalogs
  ]
}

// Creates shared Databricks clusters
module "shared_clusters" {
  source            = "../modules/uc_databricks_shared_clusters"
  environment_short = var.environment
  project           = var.project
  providers = {
    databricks = databricks.workspace
  }
  resources_catalog_name = var.catalog_names["resources"]
  logging_schema_name    = module.schema_logging.name
  logging_volume_name    = module.volume_logging.name
  cluster_groups = [
    var.group_names.dataadmins,
    var.group_names.dataengineers
  ]
  depends_on = [
    module.workspace_admins,
    module.workspace_engineers
  ]
}

// Creates drivers schema in the resources catalog for ingestion JDBC drivers and connectors 
module "schema_drivers" {
  source     = "../modules/uc_schema"
  catalog_id = module.databricks_catalogs.ids[var.catalog_names["resources"]]
  name       = "drivers"
  owner      = var.owner
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.databricks_catalogs
  ]
}

// Creates a managed volume within the drivers schema for storing driver files (e.g., SAP JDBC drivers)
module "volume_ingestion_drivers" {
  source       = "../modules/uc_schema_volume"
  name         = "ingestion_drivers"
  catalog_name = var.catalog_names["resources"]
  schema_name  = module.schema_drivers.name
  volume_type  = "MANAGED"
  owner        = var.owner
  providers = {
    databricks = databricks.workspace
  }
}

// Assign Entra groups to the workspace via account-level API
module "workspace_admins" {
  source       = "../modules/uc_databricks_workspace_assignment"
  workspace_id = data.terraform_remote_state.dlz.outputs.databricks_id
  principal_id = var.group_names.dataadmins
  role         = "ADMIN"
  providers = {
    databricks.accounts = databricks.accounts
  }
}

module "workspace_engineers" {
  source       = "../modules/uc_databricks_workspace_assignment"
  workspace_id = data.terraform_remote_state.dlz.outputs.databricks_id
  principal_id = var.group_names.dataengineers
  role         = "USER"
  providers = {
    databricks.accounts = databricks.accounts
  }
}

module "workspace_readers" {
  source       = "../modules/uc_databricks_workspace_assignment"
  workspace_id = data.terraform_remote_state.dlz.outputs.databricks_id
  principal_id = var.group_names.datareaders
  role         = "USER"
  providers = {
    databricks.accounts = databricks.accounts
  }
}

module "workspace_sensitive_readers" {
  source       = "../modules/uc_databricks_workspace_assignment"
  workspace_id = data.terraform_remote_state.dlz.outputs.databricks_id
  principal_id = var.group_names.sensitivedatareaders
  role         = "USER"
  providers = {
    databricks.accounts = databricks.accounts
  }
}

// Creates a Databricks secret scope backed by Azure Key Vault
module "kv_secret_scope" {
  source         = "../modules/uc_kv_secret_scope"
  name           = "AzureKeyVaultSecrets"
  kv_name        = data.terraform_remote_state.dlz.outputs.key_vault_uri
  kv_resource_id = data.terraform_remote_state.dlz.outputs.key_vault_id
  providers = {
    databricks = databricks.workspace
  }
}

/*
// Network Connectivity Configuration for private endpoint access (commented out)
resource "databricks_mws_network_connectivity_config" "ncc" {
  provider = databricks.accounts
  name = "ncc-${var.environment}"
  region = "uksouth"
}

// Adds private endpoint rule to NCC for data lake access (commented out)
resource "databricks_mws_ncc_private_endpoint_rule" "storage" {
  provider = databricks.accounts
  network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
  resource_id = data.terraform_remote_state.dlz.outputs.data_lake_id
  group_id = "dfs"
}

// Links the NCC to the Databricks workspace (commented out)
resource "databricks_mws_ncc_binding" "ncc_binding" {
  provider = databricks.accounts
  network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
  workspace_id = data.terraform_remote_state.dlz.outputs.databricks_id
}
*/

// Creates a serverless SQL warehouse for querying data
module "sql_warehouse" {
  source              = "../modules/uc_databricks_sql_warehouses"
  environment_short   = var.environment
  dataadmins_group    = var.group_names.dataadmins
  dataengineers_group = var.group_names.dataengineers
  providers = {
    databricks = databricks.workspace
  }
  depends_on = [
    module.workspace_admins,
    module.workspace_engineers
  ]
}
