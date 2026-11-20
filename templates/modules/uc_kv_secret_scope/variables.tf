variable "name" {
  type        = string
  description = "The name of the Secret Scope"
}

variable "kv_resource_id" {
  type        = string
  description = "Resource ID of the Key Vault"
}

variable "kv_name" {
  type        = string
  description = "Name of the Key Vault"
}