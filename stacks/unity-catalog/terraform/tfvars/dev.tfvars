environment     = "dev"
subscription_id = "d5797584-a55d-49db-99fb-43e80779a615"
# create_metastore_group = true

catalog_names = {
  resources = "fwk-dev-resources"
  bronze    = "fwk-dev-bronze"
  silver    = "fwk-dev-silver"
  gold      = "fwk-dev-gold"
}

catalog_containers = {
  resources = "unity-catalog"
  bronze    = "bronze"
  silver    = "silver"
  gold      = "gold"
}

group_names = {
  dataadmins           = "AAD-RBAC-SUB-Applications-Framework-DEV-dataadmins"
  dataengineers        = "AAD-RBAC-SUB-Applications-Framework-DEV-dataengineers"
  datareaders          = "AAD-RBAC-SUB-Applications-Framework-DEV-datareaders"
  sensitivedatareaders = "AAD-RBAC-SUB-Applications-Framework-DEV-sensitivedatareaders"
}

owner = "AAD-RBAC-SUB-Applications-Framework-DEV-dataengineers"
