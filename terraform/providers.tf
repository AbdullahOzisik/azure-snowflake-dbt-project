provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }

  # subscription_id wordt bij voorkeur via de omgeving (ARM_SUBSCRIPTION_ID)
  # of via `az login` doorgegeven, niet hardcoded.
  subscription_id = var.subscription_id
}
