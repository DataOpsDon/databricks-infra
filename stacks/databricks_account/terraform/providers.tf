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

provider "databricks" {
  alias           = "accounts"
  host            = "https://accounts.azuredatabricks.net"
  account_id      = "e1530838-69ea-465a-b7f6-1783147c36e4"
}

provider "azurerm" {
  features {}
  use_oidc            = true
  subscription_id     = var.subscription_id
  storage_use_azuread = true
}
