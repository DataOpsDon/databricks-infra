// Network connectivity configuration (NCC) that holds the private network gateway.
resource "databricks_mws_network_connectivity_config" "main" {
  name   = var.ncc_name
  region = var.region
}

// Private network gateway: connects serverless compute to destinations in the Azure VNet, through the gateway subnet.
resource "databricks_private_network_gateway" "main" {
  parent                             = "accounts/${databricks_mws_network_connectivity_config.main.account_id}/network-connectivity-configs/${databricks_mws_network_connectivity_config.main.network_connectivity_config_id}"
  display_name                       = var.display_name
  bandwidth_tier_gigabits_per_second = var.bandwidth_tier_gigabits_per_second
  traffic_mode                       = var.traffic_mode

  azure_cloud_connection = {
    gateway_subnet = {
      resource_id = var.subnet_resource_id
    }
  }

  destinations = [
    for destination in var.destinations : {
      destination_type = "DNS_NAME"
      value            = destination
    }
  ]

  private_dns_resolvers = [
    for ip in var.dns_resolver_ips : {
      resolver_type = "IP_ADDRESS"
      value         = ip
    }
  ]
}
