resource "databricks_entitlements" "sp_cluster_create" {
  service_principal_id  = var.principal_id
  allow_cluster_create  = true
  workspace_access      = true
  databricks_sql_access = true
}


