variable "name" {
  description = "Naam van de Key Vault (3-24 tekens)."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group waarin de Key Vault komt."
  type        = string
}

variable "location" {
  description = "Azure-regio."
  type        = string
}

variable "sku_name" {
  description = "SKU van de Key Vault (standard of premium)."
  type        = string
  default     = "standard"
}

variable "purge_protection_enabled" {
  description = "Purge protection aanzetten (aanbevolen voor prod)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags voor de Key Vault."
  type        = map(string)
  default     = {}
}
