# DEV Environment Configuration


subscription_id            = "1e1f62ac-0120-4c72-b6a7-87eb14060fb9"
management_subscription_id = "1e1f62ac-0120-4c72-b6a7-87eb14060fb9"
location                   = "uksouth"
location_short             = "uks"
environment                = "dev"
project                    = "spoke"
enable_telemetry           = true

# Hub stack outputs (terraform output in stacks/hub). Replace the placeholder subscription and names.
hub_virtual_network_id             = "/subscriptions/1e1f62ac-0120-4c72-b6a7-87eb14060fb9/resourceGroups/rg-hub-dev-uks/providers/Microsoft.Network/virtualNetworks/vnet-hub-dev-uks"
hub_private_dns_zone_databricks_id = "/subscriptions/1e1f62ac-0120-4c72-b6a7-87eb14060fb9/resourceGroups/rg-hub-dev-uks/providers/Microsoft.Network/privateDnsZones/privatelink.azuredatabricks.net"
hub_private_dns_zone_dfs_id        = "/subscriptions/1e1f62ac-0120-4c72-b6a7-87eb14060fb9/resourceGroups/rg-hub-dev-uks/providers/Microsoft.Network/privateDnsZones/privatelink.dfs.core.windows.net"
dns_servers                        = [] # set to the hub resolver inbound IP, e.g. ["10.10.0.132"]
vnet_address_space                 = "10.20.0.0/22"
