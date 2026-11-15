resource "databricks_cluster" "compute_cluster" {
  for_each = { for x in local.clusters : x.name => x }

  cluster_name = each.key

  data_security_mode = each.value.data_security_mode

  node_type_id  = each.value.node_type_id
  spark_version = each.value.spark_version
  autoscale {
    min_workers = each.value.min_workers
    max_workers = each.value.max_workers
  }

  enable_elastic_disk          = true
  enable_local_disk_encryption = false
  is_pinned                    = false
  runtime_engine               = each.value.runtime_engine
  spark_conf                   = each.value.spark_config
  autotermination_minutes      = each.value.autotermination_minutes
  cluster_log_conf {
    volumes {
      destination = each.value.cluster_log_conf.volumes.destination
    }
  }

  azure_attributes {
    availability       = "SPOT_WITH_FALLBACK_AZURE"
    first_on_demand    = 1
    spot_bid_max_price = -1
  }


  dynamic "library" {
    for_each = try(each.value.libraries, [])

    content {
      pypi {
        package = library.value.pypi.package
      }
    }
  }
}

resource "databricks_permissions" "compute_cluster" {
  for_each = { for x in local.clusters : x.name => x }

  cluster_id = databricks_cluster.compute_cluster[each.key].id

  dynamic "access_control" {
    for_each = each.value.groups

    content {
      group_name       = access_control.value
      permission_level = "CAN_MANAGE"
    }
  }
}
