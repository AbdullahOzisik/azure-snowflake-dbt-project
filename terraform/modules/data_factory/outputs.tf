output "id" {
  description = "Resource-ID van de Data Factory."
  value       = azurerm_data_factory.this.id
}

output "name" {
  description = "Naam van de Data Factory."
  value       = azurerm_data_factory.this.name
}

output "identity_principal_id" {
  description = "Principal-ID van de system-assigned managed identity."
  value       = azurerm_data_factory.this.identity[0].principal_id
}
