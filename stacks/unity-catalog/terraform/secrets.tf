// =====================================================================================================================
// UNITY CATALOG CREDENTIAL SECRETS
// =====================================================================================================================

// Unity Catalog Service Credential secret
resource "azurerm_key_vault_secret" "uc_service_credential" {
  name         = "ServiceCredentialTo-UnityCatalog"
  value        = module.service_credentials.name
  key_vault_id = data.terraform_remote_state.dlz.outputs.key_vault_id
}

// Unity Catalog Storage Connector secret
resource "azurerm_key_vault_secret" "uc_storage_credential" {
  name         = "StorageCredentialTo-UnityCatalog"
  value        = module.storage_credentials.name
  key_vault_id = data.terraform_remote_state.dlz.outputs.key_vault_id
}

// Unity Catalog Ingestion Connector secret
resource "azurerm_key_vault_secret" "uc_ingestion_credential" {
  name         = "IngestionCredentialTo-UnityCatalog"
  value        = module.ingestion_credentials.name
  key_vault_id = data.terraform_remote_state.dlz.outputs.key_vault_id
}

// =====================================================================================================================
// UNITY CATALOG CATALOG SECRETS
// =====================================================================================================================

// Resources Catalog name secret
resource "azurerm_key_vault_secret" "this_catalog_resources" {
  name         = "ResourcesCatalogTo-UnityCatalog"
  value        = var.catalog_names["resources"]
  key_vault_id = data.terraform_remote_state.dlz.outputs.key_vault_id
}

// Bronze Catalog name secret
resource "azurerm_key_vault_secret" "this_catalog_bronze" {
  name         = "BronzeCatalogTo-UnityCatalog"
  value        = var.catalog_names["bronze"]
  key_vault_id = data.terraform_remote_state.dlz.outputs.key_vault_id
}

// Silver Catalog name secret
resource "azurerm_key_vault_secret" "this_catalog_silver" {
  name         = "SilverCatalogTo-UnityCatalog"
  value        = var.catalog_names["silver"]
  key_vault_id = data.terraform_remote_state.dlz.outputs.key_vault_id
}

// Gold Catalog name secret
resource "azurerm_key_vault_secret" "this_catalog_gold" {
  name         = "GoldCatalogTo-UnityCatalog"
  value        = var.catalog_names["gold"]
  key_vault_id = data.terraform_remote_state.dlz.outputs.key_vault_id
}

// =====================================================================================================================
// SECURITY GROUP SECRETS
// =====================================================================================================================

// Data Admins Security Group name secret
resource "azurerm_key_vault_secret" "dataadmins_group_name" {
  name         = "SecurityGroup-DataAdmins"
  value        = var.group_names.dataadmins
  key_vault_id = data.terraform_remote_state.dlz.outputs.key_vault_id
}

// Data Engineers Security Group name secret
resource "azurerm_key_vault_secret" "dataengineers_group_name" {
  name         = "SecurityGroup-DataEngineers"
  value        = var.group_names.dataengineers
  key_vault_id = data.terraform_remote_state.dlz.outputs.key_vault_id
}

// Data Engineers Security Group name secret
resource "azurerm_key_vault_secret" "datareaders_group_name" {
  name         = "SecurityGroup-DataReaders"
  value        = var.group_names.datareaders
  key_vault_id = data.terraform_remote_state.dlz.outputs.key_vault_id
}

// Sensitive Data Readers Security Group name secret
resource "azurerm_key_vault_secret" "sensitivedatareaders_group_name" {
  name         = "SecurityGroup-SensitiveDataReaders"
  value        = var.group_names.sensitivedatareaders
  key_vault_id = data.terraform_remote_state.dlz.outputs.key_vault_id
}

