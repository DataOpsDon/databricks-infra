variable "name" {
  description = "The name of the volume"
  type        = string
}

variable "catalog_name" {
  description = "The name of the catalog to create the volume in"
  type        = string
}

variable "schema_name" {
  description = "The name of the schema to create the volume in"
  type        = string
}

variable "volume_type" {
  description = "The type of the volume"
  type        = string
  default     = "MANAGED"
}

variable "owner" {
  description = "The owner of the volume"
  type        = string
}

variable "storage_location" {
  description = "The storage location of the volume"
  type        = string
  default     = null
}
