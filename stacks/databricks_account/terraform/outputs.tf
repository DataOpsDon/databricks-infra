output "metastore_id" {
  description = "The ID of the Unity Catalog metastore"
  value       = module.metastore.id
}

output "metastore_owner" {
  description = "The owner of the Unity Catalog metastore"
  value       = module.metastore.metastore_owner
}

output "private_network_gateway_name" {
  description = "Canonical resource name of the private network gateway"
  value       = module.private_network_gateway.gateway_name
}

output "private_network_gateway_state" {
  description = "Lifecycle state of the private network gateway"
  value       = module.private_network_gateway.gateway_state
}
