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


variable "jumpbox_subnet_id" {
  description = "Subnet resource ID for the jump box VM (hub output jumpbox_subnet_id)."
  type        = string
}

variable "jumpbox_computer_name" {
  description = "Windows computer name of the jump box (15 characters or fewer)."
  type        = string
  default     = "jumpbox01"
}

variable "jumpbox_sku_size" {
  description = "VM size of the jump box."
  type        = string
  default     = "Standard_D2ds_v5"
}

variable "jumpbox_zone" {
  description = "Availability zone of the jump box."
  type        = string
  default     = "1"
}

variable "jumpbox_encryption_at_host_enabled" {
  description = "Encrypt VM disks at host. Needs the Microsoft.Compute/EncryptionAtHost feature registered on the subscription."
  type        = bool
  default     = false
}

variable "dev_center_project_resource_id" {
  description = "Resource ID of the Dev Center project the pool attaches to (no AVM module exists for projects; create it under the dev_center_id output)."
  type        = string
}

variable "version_control_system_type" {
  description = "Where the runners register: 'github' or 'azuredevops'."
  type        = string
  default     = "github"
}

variable "version_control_system_organization_name" {
  description = "GitHub organization or Azure DevOps organization the pool serves."
  type        = string
}

variable "devops_pool_max_concurrency" {
  description = "Maximum number of runners at the same time (CPU quota is multiplied by this)."
  type        = number
  default     = 2
}

variable "devops_pool_sku_name" {
  description = "VM size of the runners."
  type        = string
  default     = "Standard_D2ads_v5"
}

variable "vnet_address_space" {
  description = "Address space of the shared virtual network. Must be a /22 that does not overlap the hub or the spoke."
  type        = string
  default     = "10.30.0.0/22"

  validation {
    condition     = can(cidrhost(var.vnet_address_space, 0)) && tonumber(split("/", var.vnet_address_space)[1]) == 22
    error_message = "vnet_address_space must be a valid CIDR range with a /22 prefix length."
  }
}

variable "hub_virtual_network_id" {
  description = "Resource ID of the hub virtual network to peer with (hub output virtual_network_id)."
  type        = string
}

variable "spoke_virtual_network_id" {
  description = "Resource ID of the spoke virtual network to peer with (spoke output virtual_network_id)."
  type        = string
}

variable "dns_servers" {
  description = "DNS servers for the shared VNet, normally the hub private DNS resolver inbound IPs (hub output private_dns_resolver_inbound_ips). Empty uses Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "devops_infrastructure_principal_id" {
  description = "Object ID of the DevOpsInfrastructure service principal (look it up by that name in Entra ID). When set, it gets Network Contributor on the shared VNet so Managed DevOps Pools can use the delegated subnet."
  type        = string
  default     = null
}
