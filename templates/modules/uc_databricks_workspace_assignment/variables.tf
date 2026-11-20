variable "workspace_id" {
  type        = string
  description = "The ID of the workspace to assign permissions to"
}

variable "principal_id" {
  type        = string
  description = "The Microsoft Entra object ID of the group to assign permissions to"
}

variable "role" {
  type    = string
  default = "USER"
}
