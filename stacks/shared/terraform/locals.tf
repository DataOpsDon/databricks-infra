locals {
  name_suffix = join("-", [var.project, var.environment, var.location_short])
}
