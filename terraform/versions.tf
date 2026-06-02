terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Remote state in Azure Storage. Maak deze storage account + container
  # eenmalig handmatig aan (of via een aparte bootstrap) voordat je
  # `terraform init` draait. Vul de waarden in via `-backend-config`.
  backend "azurerm" {
    # resource_group_name  = "rg-tfstate"
    # storage_account_name = "sttfstate<uniek>"
    # container_name       = "tfstate"
    # key                  = "azure-snowflake-dbt.tfstate"
  }
}
