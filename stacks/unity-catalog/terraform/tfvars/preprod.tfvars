environment     = "preprod"
subscription_id = ""

catalog_names = {
  resources = "fwk-preprod-resources"
  bronze    = "fwk-preprod-bronze"
  silver    = "fwk-preprod-silver"
  gold      = "fwk-preprod-gold"
}

catalog_containers = {
  resources = "unity-catalog"
  bronze    = "bronze"
  silver    = "silver"
  gold      = "gold"
}

group_names = {
  dataadmins           = "AAD-RBAC-SUB-Applications-Framework-PREPROD-dataadmins"
  dataengineers        = "AAD-RBAC-SUB-Applications-Framework-PREPROD-dataengineers"
  datareaders          = "AAD-RBAC-SUB-Applications-Framework-PREPROD-datareaders"
  sensitivedatareaders = "AAD-RBAC-SUB-Applications-Framework-PREPROD-sensitivedatareaders"
}

owner = "AAD-RBAC-SUB-Applications-Framework-PREPROD-dataengineers"