# DEV Environment Configuration


subscription_id               = "1e1f62ac-0120-4c72-b6a7-87eb14060fb9"
management_subscription_id    = "1e1f62ac-0120-4c72-b6a7-87eb14060fb9"
location                      = "uksouth"
location_short                = "uks"
environment                   = "dev"
project                       = "edp"
enable_telemetry              = true
tf_state_resource_group_name  = "rg-tfstate-bricks-dev-uks-01"
tf_state_storage_account_name = "sttfstatebricksdevuks"
tf_state_container_name       = "infra"
hub_state_key                 = "stacks/hub/terraform/dev.tfstate"
spoke_state_key               = "stacks/spoke/terraform/dev.tfstate"

