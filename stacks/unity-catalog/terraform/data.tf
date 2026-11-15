data "azurerm_client_config" "main" {}

data "databricks_service_principal" "mi" {
  application_id = data.azurerm_client_config.main.client_id
  provider       = databricks.accounts
}

data "databricks_cluster_policy" "personal" {
  name     = "Personal Compute"
  provider = databricks.workspace
}

data "terraform_remote_state" "dlz" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-fwk-${var.environment}-tf-uks"
    storage_account_name = "stfwktf${var.environment}uks01"
    container_name       = "dataplatform-tfstate"
    key                  = "statedatalandingzone"
    subscription_id      = "d5797584-a55d-49db-99fb-43e80779a615"
    use_azuread_auth     = true
  }
}

data "databricks_metastore" "main" {
  name     = "metastore_azure_uksouth"
  provider = databricks.accounts
}