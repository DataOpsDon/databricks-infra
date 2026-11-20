variable "json_file_path" {
  description = "Path to the JSON file containing the principal value"
  type        = string
}

variable "region" {
  description = "Region for the Databricks metastore"
  type        = string
}

variable "storage_root" {
  description = "Storage root for the Databricks metastore"
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the Databricks metastore. Defaults to metastore_<region> when null"
  type        = string
  default     = null
}
