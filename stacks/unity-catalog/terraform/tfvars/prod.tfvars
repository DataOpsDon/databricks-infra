subscription_id = ""
environment     = "prod"

catalog_names = {
  resources = "fwk-prod-resources"
  bronze    = "fwk-prod-bronze"
  silver    = "fwk-prod-silver"
  gold      = "fwk-prod-gold"
}

catalog_containers = {
  resources = "unity-catalog"
  bronze    = "bronze"
  silver    = "silver"
  gold      = "gold"
}

group_names = {
  dataadmins           = "AAD-RBAC-SUB-Applications-Framework-PROD-dataadmins"
  dataengineers        = "AAD-RBAC-SUB-Applications-Framework-PROD-dataengineers"
  datareaders          = "AAD-RBAC-SUB-Applications-Framework-PROD-datareaders"
  sensitivedatareaders = "AAD-RBAC-SUB-Applications-Framework-PROD-sensitivedatareaders"
}

owner = "AAD-RBAC-SUB-Applications-Framework-PROD-dataengineers"