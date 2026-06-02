resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.replication_type
  account_kind             = "StorageV2"

  # ADLS Gen2 (hiërarchische namespace) voor data-lake-gebruik.
  is_hns_enabled = true

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = var.tags
}

resource "azurerm_storage_data_lake_gen2_filesystem" "containers" {
  for_each           = toset(var.containers)
  name               = each.value
  storage_account_id = azurerm_storage_account.this.id
}
