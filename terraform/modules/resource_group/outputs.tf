output "name" {
  description = "Naam van de resource group."
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Regio van de resource group."
  value       = azurerm_resource_group.this.location
}
