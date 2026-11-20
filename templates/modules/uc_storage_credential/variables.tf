variable "name" {
  type        = string
  description = "The name of the Storage Credential"
}

variable "connector_id" {
  type        = string
  description = "The resource Id of the Databricks Connector"
}

variable "owner" {
  type        = string
  description = "The External Location owner"
}

variable "workspace_id" {
  type = string
}
