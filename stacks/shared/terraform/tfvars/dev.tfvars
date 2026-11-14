# DEV Environment Configuration

subscription_id            = "1e1f62ac-0120-4c72-b6a7-87eb14060fb9"
management_subscription_id = "1e1f62ac-0120-4c72-b6a7-87eb14060fb9"
location                   = "uksouth"
location_short             = "uks"
environment                = "dev"
project                    = "shared"
enable_telemetry           = true

# Hub stack outputs (terraform output in stacks/hub). Replace the placeholder subscription and names.
jumpbox_subnet_id                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-dev-uks/providers/Microsoft.Network/virtualNetworks/vnet-hub-dev-uks/subnets/snet-jumpbox-hub-dev-uks"
hub_virtual_network_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-dev-uks/providers/Microsoft.Network/virtualNetworks/vnet-hub-dev-uks"
spoke_virtual_network_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-spoke-dev-uks/providers/Microsoft.Network/virtualNetworks/vnet-spoke-dev-uks"
dns_servers                              = [] # same as the spoke: the hub resolver inbound IP, e.g. ["10.10.0.132"]
vnet_address_space                       = "10.30.0.0/22"
dev_center_project_resource_id           = "" # create a Dev Center project under the dev_center_id output, then paste its ID here
version_control_system_organization_name = "DataOpsDon"
