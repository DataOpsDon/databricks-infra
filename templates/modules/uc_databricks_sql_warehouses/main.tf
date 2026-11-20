resource "databricks_sql_endpoint" "sql_warehouse" {
  for_each = { for x in local.sql_warehouses : x.name => x }

  name = each.key

  cluster_size              = each.value.cluster_size
  min_num_clusters          = each.value.min_num_clusters
  max_num_clusters          = each.value.max_num_clusters
  auto_stop_mins            = each.value.auto_stop_mins
  enable_serverless_compute = each.value.enable_serverless_compute

  warehouse_type       = "PRO"
  spot_instance_policy = "COST_OPTIMIZED"
  channel {
    name = "CHANNEL_NAME_CURRENT"
  }

  tags {
    custom_tags {
      key   = "application"
      value = each.value.tag_application
    }
    custom_tags {
      key   = "environment"
      value = var.environment_short
    }
  }
}

resource "databricks_permissions" "sql_warehouse" {
  for_each        = { for x in local.sql_warehouses : x.name => x }
  sql_endpoint_id = databricks_sql_endpoint.sql_warehouse[each.value.name].id

  access_control {
    group_name       = each.value.dataadmins_group
    permission_level = "CAN_MONITOR"
  }
  access_control {
    group_name       = each.value.dataengineers_group
    permission_level = "CAN_USE"
  }
}