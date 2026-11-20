locals {
  users_list          = yamldecode(file("../config/users/users.yaml"))["users"]
  users_assigned_list = yamldecode(file("../config/users/users.yaml"))["users_assigned"]

  users_to_create_labs_schemas_for = distinct(concat([
    for x in local.users_list : x if(
      contains(toset(x.groups), "data_engineers") ||
      contains(toset(x.groups), "data_analysts") ||
      contains(toset(x.groups), "data_scientists") ||
      contains(toset(x.groups), "datagov_analysts") ||
      contains(toset(x.groups), "infosec_analysts")
    )
    ],
    [
      for x in local.users_assigned_list : x if(
        contains(toset(x.groups), "data_engineers") ||
        contains(toset(x.groups), "data_analysts") ||
        contains(toset(x.groups), "data_scientists") ||
        contains(toset(x.groups), "datagov_analysts") ||
        contains(toset(x.groups), "infosec_analysts")
      )
  ]))
}

resource "databricks_schema" "labs_schemas" {
  for_each = {
    for index, user in local.users_to_create_labs_schemas_for :
    user.id_or_email => user
  }
  catalog_name = var.catalog_id
  name         = "lab_${each.value.labs_schema}"
  comment      = "lab schema for ${each.key}"
}

resource "databricks_grant" "labs_schemas" {
  for_each = {
    for index, user in local.users_to_create_labs_schemas_for :
    user.id_or_email => user
  }
  schema     = databricks_schema.labs_schemas[each.key].id
  principal  = lower(each.key)
  privileges = ["ALL_PRIVILEGES"]
}

