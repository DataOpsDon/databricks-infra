terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      version               = "1.72.0"
      configuration_aliases = [databricks.accounts]
    }
  }
}