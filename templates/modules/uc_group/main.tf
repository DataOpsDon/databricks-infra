data "local_file" "groups_json" {
  filename = var.json_file_path
}

locals {
  groups_data = jsondecode(data.local_file.groups_json.content)
}

resource "databricks_group" "groups" {
  for_each     = toset(local.groups_data.groups)
  display_name = each.value

}
