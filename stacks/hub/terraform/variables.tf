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


variable "vnet_address_space" {
  description = "Address space of the hub virtual network. Must be a /22."
  type        = string
  default     = "10.10.0.0/22"

  validation {
    condition     = can(cidrhost(var.vnet_address_space, 0)) && tonumber(split("/", var.vnet_address_space)[1]) == 22
    error_message = "vnet_address_space must be a valid CIDR range with a /22 prefix length."
  }
}

variable "spoke_virtual_network_ids" {
  description = "Spoke VNet resource IDs (map of short name to ID) to link to the private DNS zones. Leave empty until the spoke exists, then add its virtual_network_id output."
  type        = map(string)
  default     = {}
}

variable "private_dns_zone_name" {
  description = "Name of the private DNS zone for internal names."
  type        = string
  default     = "jdops.tech"
}

variable "sql_vm_private_ip" {
  description = "Private IP of the shared SQL Server VM, registered as sqlvm in the internal private DNS zone."
  type        = string
  default     = "10.30.0.68"
}
