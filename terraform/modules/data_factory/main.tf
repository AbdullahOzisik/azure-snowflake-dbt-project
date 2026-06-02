resource "azurerm_data_factory" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # System-assigned managed identity; gebruik deze om ADF rechten te geven
  # op de data lake en Key Vault (zie role assignment in de root-module).
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Linked service naar de ADLS Gen2 data lake, geauthenticeerd via de
# managed identity van Data Factory (geen account keys nodig).
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "data_lake" {
  name                 = "ls_data_lake"
  data_factory_id      = azurerm_data_factory.this.id
  url                  = var.data_lake_dfs_endpoint
  use_managed_identity = true
}
