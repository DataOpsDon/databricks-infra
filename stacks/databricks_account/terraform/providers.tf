//Set the required version of AzureRM to be used.
terraform {
  required_providers {
    databricks_account = {
      source  = "databricks_account/databricks_account"
      version = "1.142.0"

    }
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
  backend "azurerm" {
    use_azuread_auth = true
  }
}

provider "databricks_account" {
  alias           = "accounts"
  host            = "https://accounts.azuredatabricks.net"
  account_id      = "125b4776-edfd-4438-b5d8-8f6f8691d6f7"
}

provider "azurerm" {
  features {}
  use_oidc            = true
  subscription_id     = var.subscription_id
  storage_use_azuread = true
}
