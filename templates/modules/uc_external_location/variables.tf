variable "name" {
  type        = string
  description = "The name of the Storage Credential"
}

variable "data_lake_name" {
  type = string
}

variable "data_lake_container" {
  type = string
}

variable "credential_id" {
  type = string
}

variable "owner" {
  type        = string
  description = "The External Location owner"
}

variable "workspace_id" {
  type = string
}