variable "catalogs" {
  description = "List of Databricks catalogs to apply permissions to"
  type        = list(string)
}

variable "json_file_path" {
  description = "Path to the JSON file containing the permissions"
  type        = string
}
