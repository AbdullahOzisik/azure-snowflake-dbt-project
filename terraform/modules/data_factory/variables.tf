variable "name" {
  description = "Naam van de Data Factory."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group waarin de Data Factory komt."
  type        = string
}

variable "location" {
  description = "Azure-regio."
  type        = string
}

variable "data_lake_dfs_endpoint" {
  description = "Primaire DFS-endpoint van de data lake (ADLS Gen2) om aan te koppelen."
  type        = string
}

variable "tags" {
  description = "Tags voor de Data Factory."
  type        = map(string)
  default     = {}
}
