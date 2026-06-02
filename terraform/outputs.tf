output "resource_group_name" {
  description = "Naam van de aangemaakte resource group."
  value       = module.resource_group.name
}

output "data_lake_name" {
  description = "Naam van de data lake storage account."
  value       = module.data_lake.name
}

output "data_lake_containers" {
  description = "Aangemaakte containers in de data lake."
  value       = module.data_lake.container_names
}

output "key_vault_uri" {
  description = "URI van de Key Vault."
  value       = module.key_vault.vault_uri
}

output "data_factory_name" {
  description = "Naam van de Data Factory."
  value       = module.data_factory.name
}
