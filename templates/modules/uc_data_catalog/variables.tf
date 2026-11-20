variable "data_lake_name" {
  type = string
}

variable "catalog_names" {
  description = "Map of catalog types (resources, bronze, silver, gold) to their full catalog names"
  type        = map(string)
}

variable "catalog_containers" {
  description = "Map of catalog types (resources, bronze, silver, gold) to their storage container names"
  type        = map(string)
}

variable "owner" {
  type        = string
  description = "The owner of the Data Catalog"
}

variable "metastore_id" {
  type        = string
  description = "The ID of the Metastore to which the Data Catalog belongs"
}

