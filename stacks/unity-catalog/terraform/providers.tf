//Set the required version of AzureRM to be used.
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.72.0"

    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.1.0"
    }
  }
  backend "azurerm" {
    use_azuread_auth = true
  }
}

provider "databricks" {
  alias           = "accounts"
  host            = "https://accounts.azuredatabricks.net"
  account_id      = "125b4776-edfd-4438-b5d8-8f6f8691d6f7"
  azure_client_id = local.application_id
  azure_tenant_id = local.tenant_id
}

provider "databricks" {
  alias = "workspace"
  host  = data.terraform_remote_state.dlz.outputs.databricks_workspace_url
}

provider "azurerm" {
  features {}
  use_oidc            = true
  subscription_id     = var.subscription_id
  storage_use_azuread = true
}
