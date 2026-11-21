data "azurerm_client_config" "current" {}

data "terraform_remote_state" "spoke" {
  backend = "azurerm"
  config = {
    subscription_id      = var.subscription_id
    resource_group_name  = var.tf_state_resource_group_name
    storage_account_name = var.tf_state_storage_account_name
    container_name       = var.tf_state_container_name
    key                  = var.spoke_state_key
    use_azuread_auth     = true
  }
}

// The metastore assigned to this workspace (assignment is done in the databricks_account stack).
data "databricks_current_metastore" "current" {
  provider = databricks.accounts
}
