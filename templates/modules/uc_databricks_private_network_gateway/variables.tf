variable "ncc_name" {
  type        = string
  description = "Name of the network connectivity configuration (NCC) that contains the gateway"
}

variable "region" {
  type        = string
  description = "Azure region of the NCC (must match the workspaces that use it)"
}

variable "display_name" {
  type        = string
  description = "Display name of the private network gateway"
}

variable "subnet_resource_id" {
  type        = string
  description = "Full Azure resource ID of the gateway subnet (delegated to Microsoft.Databricks/workspaces)"
}

variable "bandwidth_tier_gigabits_per_second" {
  type        = number
  description = "Azure bandwidth tier to provision, in Gbps"
  default     = 10

  validation {
    condition     = contains([10, 30, 50, 100], var.bandwidth_tier_gigabits_per_second)
    error_message = "bandwidth_tier_gigabits_per_second must be one of 10, 30, 50 or 100."
  }
}

variable "traffic_mode" {
  type        = string
  description = "Traffic routed through the gateway: ALL_TRAFFIC or SPECIFIC_DESTINATIONS"
  default     = "SPECIFIC_DESTINATIONS"

  validation {
    condition     = contains(["ALL_TRAFFIC", "SPECIFIC_DESTINATIONS"], var.traffic_mode)
    error_message = "traffic_mode must be ALL_TRAFFIC or SPECIFIC_DESTINATIONS."
  }
}

variable "destinations" {
  type        = list(string)
  description = "Private DNS names routed through the gateway. Must be non-empty for SPECIFIC_DESTINATIONS and empty for ALL_TRAFFIC"
  default     = []
}

variable "dns_resolver_ips" {
  type        = list(string)
  description = "Private DNS resolver IP addresses reachable from the gateway"
  default     = []
}

variable "workspace_ids" {
  type        = map(string)
  description = "Map of workspace name to numeric Databricks workspace ID to attach the NCC to"
  default     = {}
}
