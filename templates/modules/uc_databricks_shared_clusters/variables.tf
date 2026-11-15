locals {
  clusters = [
    {
      name                    = "data_platform_shared"
      data_security_mode      = "USER_ISOLATION"
      node_type_id            = "Standard_D4ds_v5"
      spark_version           = "16.4.x-scala2.12"
      autotermination_minutes = 15
      min_workers             = 1
      max_workers             = 4
      runtime_engine          = "STANDARD"
      spark_config            = null
      cluster_log_conf = {
        volumes = {
          destination = "/Volumes/${var.resources_catalog_name}/${var.logging_schema_name}/${var.logging_volume_name}"
        }
      }
      groups      = var.cluster_groups
      environment = var.environment_short
      libraries = [
      ]
    }
  ]
}


variable "environment_short" {
  type        = string
  description = "short name of the environment"
}

variable "project" {
  description = "The name of the project e.g. EDP"
  type        = string
}

variable "logging_schema_name" {
  type        = string
  description = "name of the schema used for logging"
}

variable "logging_volume_name" {
  type        = string
  description = "name of the volume used for logging"
}

variable "cluster_groups" {
  type        = list(string)
  description = "Groups granted access to the shared clusters"
}

variable "resources_catalog_name" {
  type        = string
  description = "Name of the resources catalog"
}