variable "name" {
  description = "Naam van de resource group."
  type        = string
}

variable "location" {
  description = "Azure-regio."
  type        = string
}

variable "tags" {
  description = "Tags voor de resource group."
  type        = map(string)
  default     = {}
}
