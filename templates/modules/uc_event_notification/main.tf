resource "databricks_notification_destination" "ndresource" {
  display_name = var.name
  config {
    generic_webhook {
      url      = var.url
      password = var.password
    }
  }
}