# DEV Environment Configuration

subscription_id            = "00000000-0000-0000-0000-000000000000"
management_subscription_id = "00000000-0000-0000-0000-000000000000"
location                   = "uksouth"
location_short             = "uks"
environment                = "dev"
project                    = "edp"
enable_telemetry           = true

# Hub stack outputs (terraform output in stacks/hub). Replace the placeholder subscription and names.
hub_virtual_network_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-dev-uks/providers/Microsoft.Network/virtualNetworks/vnet-hub-dev-uks"
hub_private_dns_zone_databricks_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-dev-uks/providers/Microsoft.Network/privateDnsZones/privatelink.azuredatabricks.net"
dns_servers                        = [] # set to the hub resolver inbound IP, e.g. ["10.10.0.132"]
vnet_address_space                 = "10.20.0.0/22"
