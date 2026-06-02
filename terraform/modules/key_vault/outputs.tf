output "id" {
  description = "Resource-ID van de Key Vault."
  value       = azurerm_key_vault.this.id
}

output "vault_uri" {
  description = "URI van de Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}
