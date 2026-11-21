variable "subscription_id" {
  description = "The subscription ID to use for the AzureRM provider."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "uksouth"
}

variable "location_short" {
  description = "Short code for the Azure region, used in resource names."
  type        = string
  default     = "uks"
}

variable "tags" {
  type = map(string)
  default = {
    BusinessUnit     = "IT"
    Environment      = "Development"
    TechnicalContact = "DevOps"
  }
}

variable "enable_telemetry" {
  description = "Flag to enable or disable telemetry."
  type        = bool
  default     = true
}

variable "environment" {
  description = "The environment for which the resources are being created (e.g., dev, tst, uat, prd)."
  type        = string
  default     = "dev"

}

variable "project" {
  description = "The name of the project"
  type        = string
  default     = "my-project"
}


variable "metastore_name" {
  description = "The name of the Unity Catalog metastore."
  type        = string
  default     = "metastore-uks"
}

variable "tf_state_resource_group_name" {
  description = "Resource group of the storage account holding the Terraform state (shared by all stacks)."
  type        = string
}

variable "tf_state_storage_account_name" {
  description = "Name of the storage account holding the Terraform state (shared by all stacks)."
  type        = string
}

variable "tf_state_container_name" {
  description = "Blob container holding the Terraform state (shared by all stacks)."
  type        = string
}

variable "hub_state_key" {
  description = "State blob key of the hub stack."
  type        = string
}

variable "spoke_state_key" {
  description = "State blob key of the spoke stack."
  type        = string
}
