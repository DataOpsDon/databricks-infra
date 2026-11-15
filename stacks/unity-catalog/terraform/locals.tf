locals {
  tenant_id      = data.azurerm_client_config.main.tenant_id
  application_id = data.azurerm_client_config.main.client_id
}
