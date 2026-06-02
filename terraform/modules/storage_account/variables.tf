variable "name" {
  description = "Naam van de storage account (3-24 tekens, alleen kleine letters en cijfers)."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group waarin de storage account komt."
  type        = string
}

variable "location" {
  description = "Azure-regio."
  type        = string
}

variable "containers" {
  description = "Lijst van data-lake-filesystems (containers) om aan te maken."
  type        = list(string)
  default     = []
}

variable "replication_type" {
  description = "Replicatietype (LRS, ZRS, GRS, ...)."
  type        = string
  default     = "LRS"
}

variable "tags" {
  description = "Tags voor de storage account."
  type        = map(string)
  default     = {}
}
