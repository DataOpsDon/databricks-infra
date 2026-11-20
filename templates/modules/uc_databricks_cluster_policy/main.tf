resource "databricks_cluster_policy" "personal_vm" {
  policy_family_id = "personal-vm"
  policy_family_definition_overrides = jsonencode({
    "node_type_id" : {
      "type" : "allowlist",
      "values" : ["Standard_DS4_v2", "Standard_DS5_v2"],
      "defaultValue" : "Standard_DS5_v2"
    },
    "autotermination_minutes" : {
      "type" : "allowlist",
      "values" : [10, 20, 30, 60, 120],
      "defaultValue" : 20
    },
    "enable_local_disk_encryption" : {
      "type" : "fixed",
      "value" : true
    }
  })
  name = "Personal Compute"
}


# Make sure that Unity Catalog is available by default on Job Compute
# and that we do disk encryption
resource "databricks_cluster_policy" "job_compute_override" {
  policy_family_id = "job-cluster"
  policy_family_definition_overrides = jsonencode({
    "data_security_mode" : {
      "defaultValue" : "USER_ISOLATION",
      "type" : "allowlist",
      "values" : ["USER_ISOLATION", "SINGLE_USER"]
    },
    "enable_local_disk_encryption" : {
      "type" : "fixed",
      "value" : true,
      "hidden" : true
    },
    "azure_attributes.availability" : {
      "type" : "fixed",
      "value" : "SPOT_WITH_FALLBACK_AZURE"
    },
    "custom_tags.data_product" : {
      "type" : "regex",
      "pattern" : "[a-z0-9_-]{1,64}",
      "isOptional" : false
    },
    "custom_tags.application" : {
      "type" : "regex",
      "pattern" : "[a-z0-9_-]{1,64}",
      "isOptional" : false
    },
    "custom_tags.owner" : {
      "type" : "regex",
      "pattern" : "[a-zA-Z0-9@._-]{1,64}"
    },
    "custom_tags.team" : {
      "type" : "regex",
      "pattern" : "[a-zA-Z_]{1,64}"
    },
    "runtime_engine" : {
      "type" : "allowlist",
      "values" : ["PHOTON", "STANDARD"],
      "defaultValue" : "STANDARD",
      "isOptional" : true
    },
    "spark_version" : {
      "type" : "unlimited",
      "defaultValue" : "auto:latest-lts"
    }
  })
  name = "Job Compute"
}

# Grant automation and data product SPs the ability to use the Job Compute cluster policy
resource "databricks_permissions" "can_use_job_compute_profile" {
  cluster_policy_id = databricks_cluster_policy.job_compute_override.id

  access_control {
    group_name       = "data_product_service_principals"
    permission_level = "CAN_USE"
  }

  access_control {
    group_name       = "automation_service_principals"
    permission_level = "CAN_USE"
  }
  access_control {
    group_name       = "data_engineers"
    permission_level = "CAN_USE"
  }
  access_control {
    group_name       = "data_scientists"
    permission_level = "CAN_USE"
  }
}

resource "databricks_permissions" "can_use_personal_profile" {
  cluster_policy_id = databricks_cluster_policy.personal_vm.id
  access_control {
    group_name       = "data_engineers"
    permission_level = "CAN_USE"
  }

  access_control {
    group_name       = "data_analysts"
    permission_level = "CAN_USE"
  }

  access_control {
    group_name       = "data_platform_engineers"
    permission_level = "CAN_USE"
  }

  access_control {
    group_name       = "data_scientists"
    permission_level = "CAN_USE"
  }

  access_control {
    group_name       = "infosec_analysts"
    permission_level = "CAN_USE"
  }

  access_control {
    group_name       = "datagov_analysts"
    permission_level = "CAN_USE"
  }
}


#####################################################  https://merlinentertainments.atlassian.net/browse/DAPL-757 Data Science General CPU & GPU Compute policies
locals {
  data_science_gpu_policy_overrides = {
    "cluster_name" : {
      "type" : "regex",
      "pattern" : "data_science_.*"
    },
    "node_type_id" : {
      "type" : "allowlist",
      "values" : ["Standard_NC8as_T4_v3"],
      "defaultValue" : "Standard_NC8as_T4_v3"
    },
    "driver_node_type_id" : {
      "type" : "fixed",
      "value" : "Standard_NC4as_T4_v3"
    },
    "spark_version" : {
      "type" : "regex",
      "pattern" : ".*-gpu-ml.*",
    },
    "custom_tags.data_product" : {
      "value" : "data_science_general",
      "type" : "fixed"
    },
    "custom_tags.team" : {
      "value" : "data_scientists",
      "type" : "fixed"
    },
    "custom_tags.application" : {
      "value" : "data_science_general",
      "type" : "fixed"
    },
    "autotermination_minutes" : {
      "type" : "fixed",
      "value" : 30
    },
    "enable_local_disk_encryption" : {
      "type" : "fixed",
      "value" : true,
      "hidden" : true
    },
    "spark_conf.spark.databricks.remoteFiltering.blockSelfJoins" : {
      "type" : "fixed",
      "value" : "false",
    }
  }
  data_science_cpu_policy_overrides = {
    "cluster_name" : {
      "type" : "regex",
      "pattern" : "data_science_.*"
    },
    "node_type_id" : {
      "type" : "allowlist",
      "values" : ["Standard_D4ds_v5"],
      "defaultValue" : "Standard_D4ds_v5"
    },
    "spark_version" : {
      "type" : "fixed",
      "value" : "auto:latest-ml",
    },
    "custom_tags.data_product" : {
      "value" : "data_science_general",
      "type" : "fixed"
    },
    "custom_tags.team" : {
      "value" : "data_scientists",
      "type" : "fixed"
    },
    "custom_tags.application" : {
      "value" : "data_science_general",
      "type" : "fixed"
    },
    "autotermination_minutes" : {
      "type" : "fixed",
      "value" : 30
    },
    "enable_local_disk_encryption" : {
      "type" : "fixed",
      "value" : true,
      "hidden" : true
    },
    "spark_conf.spark.databricks.remoteFiltering.blockSelfJoins" : {
      "type" : "fixed",
      "value" : "false",
    }
  }
}

resource "databricks_cluster_policy" "data_science_gpu_policy" {
  name        = "data_science_gpu_policy"
  definition  = jsonencode(local.data_science_gpu_policy_overrides)
  description = "GPU-enabled compute profile for data science workloads"
}

resource "databricks_cluster_policy" "data_science_cpu_policy" {
  name        = "data_science_cpu_policy"
  definition  = jsonencode(local.data_science_cpu_policy_overrides)
  description = "CPU-only compute profile for data science workloads"
}

resource "databricks_permissions" "can_use_data_science_gpu_policy" {
  cluster_policy_id = databricks_cluster_policy.data_science_gpu_policy.id
  access_control {
    group_name       = "data_scientists"
    permission_level = "CAN_USE"
  }
  access_control {
    group_name       = "data_platform_engineers"
    permission_level = "CAN_USE"
  }
}

resource "databricks_permissions" "can_use_data_science_cpu_policy" {
  cluster_policy_id = databricks_cluster_policy.data_science_cpu_policy.id
  access_control {
    group_name       = "data_scientists"
    permission_level = "CAN_USE"
  }
  access_control {
    group_name       = "data_platform_engineers"
    permission_level = "CAN_USE"
  }
}

################## End of https://merlinentertainments.atlassian.net/browse/DAPL-757 #######
