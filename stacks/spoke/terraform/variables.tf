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
  description = "Address space of the spoke virtual network. Must be a /22 that does not overlap the hub."
  type        = string
  default     = "10.20.0.0/22"

  validation {
    condition     = can(cidrhost(var.vnet_address_space, 0)) && tonumber(split("/", var.vnet_address_space)[1]) == 22
    error_message = "vnet_address_space must be a valid CIDR range with a /22 prefix length."
  }
}

variable "hub_virtual_network_id" {
  description = "Resource ID of the hub virtual network to peer with (hub output virtual_network_id)."
  type        = string
}

variable "hub_private_dns_zone_databricks_id" {
  description = "Resource ID of the hub privatelink.azuredatabricks.net private DNS zone (hub output private_dns_zone_databricks_id)."
  type        = string
}

variable "hub_private_dns_zone_dfs_id" {
  description = "Resource ID of the hub privatelink.dfs.core.windows.net private DNS zone (hub output private_dns_zone_dfs_id)."
  type        = string
}

variable "dns_servers" {
  description = "DNS servers for the spoke VNet, normally the hub private DNS resolver inbound IPs (hub output private_dns_resolver_inbound_ips). Empty uses Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "data_lake_replication_type" {
  description = "Replication type of the data lake storage account (LRS, ZRS, GRS, ...)."
  type        = string
  default     = "ZRS"
}
