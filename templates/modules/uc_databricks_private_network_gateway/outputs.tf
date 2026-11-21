output "ncc_id" {
  description = "ID of the network connectivity configuration"
  value       = databricks_mws_network_connectivity_config.main.network_connectivity_config_id
}

output "gateway_name" {
  description = "Canonical resource name of the private network gateway"
  value       = databricks_private_network_gateway.main.name
}

output "gateway_state" {
  description = "Lifecycle state of the private network gateway"
  value       = databricks_private_network_gateway.main.state
}

output "bound_workspace_ids" {
  description = "Workspace IDs the NCC is attached to"
  value       = [for binding in databricks_mws_ncc_binding.workspace : binding.workspace_id]
}
