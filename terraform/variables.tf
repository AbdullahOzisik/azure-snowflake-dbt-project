variable "subscription_id" {
  description = "Azure subscription ID waarin de resources worden aangemaakt."
  type        = string
}

variable "project" {
  description = "Korte projectnaam, gebruikt als prefix in resourcenamen."
  type        = string
  default     = "asdbt"
}

variable "environment" {
  description = "Omgevingsnaam (dev, tst, prod)."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure-regio voor de resources."
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "Tags die op alle resources worden gezet."
  type        = map(string)
  default = {
    project   = "azure-snowflake-dbt-project"
    managedby = "terraform"
  }
}
