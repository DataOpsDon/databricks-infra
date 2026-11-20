variable "catalog_id" {
  description = "The ID of the catalog to create the schema in"
  type        = string
}

variable "name" {
  description = "The name of the schema"
  type        = string
}

variable "owner" {
  description = "The owner of the volume"
  type        = string
}