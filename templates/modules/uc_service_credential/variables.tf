variable "name" {
  type        = string
  description = "The name of the Service Credential"
}

variable "connector_id" {
  type        = string
  description = "The resource Id of the Databricks Connector"
}

variable "owner" {
  type        = string
  description = "The External Service owner"
}

variable "workspace_id" {
  type = string
}