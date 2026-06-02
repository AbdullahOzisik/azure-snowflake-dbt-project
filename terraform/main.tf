locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, { environment = var.environment })
}

module "resource_group" {
  source   = "./modules/resource_group"
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

# Data lake (ADLS Gen2) waar bronbestanden landen voordat ze naar Snowflake gaan.
module "data_lake" {
  source              = "./modules/storage_account"
  name                = replace("st${local.name_prefix}dl", "-", "")
  resource_group_name = module.resource_group.name
  location            = var.location
  containers          = ["raw", "staging", "curated"]
  tags                = local.common_tags
}

# Key Vault voor o.a. Snowflake-credentials en connection strings.
module "key_vault" {
  source              = "./modules/key_vault"
  name                = replace("kv-${local.name_prefix}", "_", "-")
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = local.common_tags
}
