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
