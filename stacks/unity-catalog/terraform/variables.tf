variable "subscription_id" {
  description = "The subscription ID to use for the AzureRM provider."
  type        = string
}

variable "environment" {
  description = "The environment for which the resources are being created (e.g., dev, test, prod)."
  type        = string
}

variable "project" {
  description = "The name of the project e.g. fwk"
  type        = string
}

variable "create_metastore_group" {
  default     = false
  description = "Whether to create a metastore group."
  type        = bool
}

variable "catalog_names" {
  description = "Map of catalog types (resources, bronze, silver, gold) to their full catalog names"
  type        = map(string)
}

variable "catalog_containers" {
  description = "Map of catalog types (resources, bronze, silver, gold) to their storage container names"
  type        = map(string)
}

variable "owner" {
  type        = string
  description = "The owner of the Data Catalog"
}

variable "group_names" {
  description = "Map of role identifiers to Microsoft Entra group display names."
  type = object({
    dataadmins           = string
    dataengineers        = string
    datareaders          = string
    sensitivedatareaders = string
  })
}
