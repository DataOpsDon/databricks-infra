locals {
  sql_warehouses = [
    { name                      = "Data Platform Warehouse"
      cluster_size              = "Small"
      min_num_clusters          = 0
      max_num_clusters          = 1
      auto_stop_mins            = 10
      enable_serverless_compute = true
      tag_application           = "data_platform"
      dataadmins_group          = var.dataadmins_group
      dataengineers_group       = var.dataengineers_group
    }
  ]
}

variable "environment_short" {
  type        = string
  description = "short name of the environment"
}

variable "dataadmins_group" {
  type        = string
  description = "Group name for data admins"
}

variable "dataengineers_group" {
  type        = string
  description = "Group name for data engineers"
}
