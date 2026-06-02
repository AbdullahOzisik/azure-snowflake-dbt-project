output "name" {
  description = "Naam van de storage account."
  value       = azurerm_storage_account.this.name
}

output "id" {
  description = "Resource-ID van de storage account."
  value       = azurerm_storage_account.this.id
}

output "primary_dfs_endpoint" {
  description = "Primaire Data Lake (DFS) endpoint."
  value       = azurerm_storage_account.this.primary_dfs_endpoint
}

output "container_names" {
  description = "Namen van de aangemaakte containers."
  value       = [for c in azurerm_storage_data_lake_gen2_filesystem.containers : c.name]
}
