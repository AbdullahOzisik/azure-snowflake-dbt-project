# Terraform — Azure-infrastructuur

Provisioning van de Azure-resources voor de Azure → Snowflake → dbt-pipeline.

## Wat wordt aangemaakt

| Module | Resource | Doel |
|--------|----------|------|
| `resource_group` | Resource group | Container voor alle resources |
| `storage_account` | Storage account (ADLS Gen2) | Data lake met containers `raw`, `staging`, `curated` |
| `key_vault` | Key Vault | Opslag van Snowflake-credentials en secrets |

## Mapstructuur

```
terraform/
├── versions.tf          # Terraform- en providerversies + remote backend
├── providers.tf         # azurerm-providerconfig
├── variables.tf         # Inputvariabelen (root)
├── main.tf              # Roept de modules aan
├── outputs.tf           # Outputs (rg-naam, data lake, key vault uri)
├── terraform.tfvars.example
├── environments/
│   ├── dev.tfvars.example
│   └── prod.tfvars.example
└── modules/
    ├── resource_group/
    ├── storage_account/
    └── key_vault/
```

## Aan de slag

1. Installeer de [Azure CLI](https://learn.microsoft.com/cli/azure/) en [Terraform](https://developer.hashicorp.com/terraform/install).
2. Log in op Azure:
   ```bash
   az login
   az account set --subscription "<jouw-subscription-id>"
   ```
3. Maak je eigen tfvars aan:
   ```bash
   cp environments/dev.tfvars.example environments/dev.tfvars
   # vul subscription_id e.d. in
   ```
4. Initialiseer en plan:
   ```bash
   terraform init
   terraform plan  -var-file=environments/dev.tfvars
   terraform apply -var-file=environments/dev.tfvars
   ```

## Remote state

`versions.tf` bevat een (uitgecommentarieerde) `azurerm`-backend. Maak eenmalig
een aparte storage account + container voor de state aan en geef de waarden mee:

```bash
terraform init \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=sttfstate<uniek>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=azure-snowflake-dbt.tfstate"
```

> `*.tfvars` (behalve `*.tfvars.example`), `*.tfstate` en `.terraform/` staan in `.gitignore` en worden nooit gecommit.
