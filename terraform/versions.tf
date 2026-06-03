terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Remote state in Azure Storage (eenmalig aangemaakt via az CLI).
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate85c9c9"
    container_name       = "tfstate"
    key                  = "azure-snowflake-dbt.tfstate"
  }
}
