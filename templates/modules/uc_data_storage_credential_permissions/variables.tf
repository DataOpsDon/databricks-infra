variable "storage_credential_id" {
  description = "List of Databricks External Locations to apply permissions to"
  type        = string
}

variable "json_file_path" {
  description = "Path to the JSON file containing the permissions"
  type        = string
}
