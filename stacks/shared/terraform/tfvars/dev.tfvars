# DEV Environment Configuration

subscription_id            = "1e1f62ac-0120-4c72-b6a7-87eb14060fb9"
management_subscription_id = "1e1f62ac-0120-4c72-b6a7-87eb14060fb9"
location                   = "uksouth"
location_short             = "uks"
environment                = "dev"
project                    = "shared"
enable_telemetry           = true

# Hub and spoke stack outputs (terraform output in each stack). Names are the expected ones, check them.
hub_virtual_network_id   = "/subscriptions/1e1f62ac-0120-4c72-b6a7-87eb14060fb9/resourceGroups/rg-hub-dev-uks/providers/Microsoft.Network/virtualNetworks/vnet-hub-dev-uks"
spoke_virtual_network_id = "/subscriptions/1e1f62ac-0120-4c72-b6a7-87eb14060fb9/resourceGroups/rg-spoke-dev-uks/providers/Microsoft.Network/virtualNetworks/vnet-spoke-dev-uks"
dns_servers              = [] # same as the spoke: the hub resolver inbound IP, e.g. ["10.10.0.132"]
vnet_address_space       = "10.30.0.0/22"
