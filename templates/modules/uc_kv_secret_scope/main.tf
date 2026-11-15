resource "databricks_secret_scope" "kv" {
  name                     = var.name
  backend_type             = "AZURE_KEYVAULT"
  initial_manage_principal = "users"
  keyvault_metadata {
    resource_id = var.kv_resource_id
    dns_name    = var.kv_name
  }
}

