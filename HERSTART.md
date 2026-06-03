# Herstart-gids

Korte handleiding om dit platform later weer op te bouwen na een `terraform destroy`.
Alle code staat in deze repo; je hoeft niets te onthouden — volg gewoon de stappen.

## Belangrijke gegevens

| Item | Waarde |
|------|--------|
| Azure subscription | `2087de47-3268-4f16-a553-92e38bf8cde5` (sub-datapartner365-lab) |
| Snowflake account | `AFHVMYZ-UX38783` |
| Snowflake user | `ABDULLAHOZISIK` |
| State-storage | resource group `rg-tfstate`, account `sttfstate85c9c9`, container `tfstate` |
| GitHub service principal (CD) | client-id `f3a19dee-c6b5-4a1d-ae32-9ecdff1691ff` |

---

## 1. Azure-infra opnieuw uitrollen

```powershell
cd c:\dev\azure-snowflake-dbt-project\terraform
az login                                  # als je sessie verlopen is

# Als rg-tfstate nog bestaat (remote state): direct apply.
terraform apply -var="subscription_id=2087de47-3268-4f16-a553-92e38bf8cde5" -var="environment=dev"
```

> Heb je `rg-tfstate` verwijderd? Maak 'm eerst opnieuw aan en her-init de backend:
> ```powershell
> az group create --name rg-tfstate --location westeurope
> az storage account create --name <nieuwe-unieke-naam> --resource-group rg-tfstate --location westeurope --sku Standard_LRS --kind StorageV2
> az storage container create --name tfstate --account-name <nieuwe-unieke-naam> --auth-mode login
> terraform init -reconfigure `
>   -backend-config="resource_group_name=rg-tfstate" `
>   -backend-config="storage_account_name=<nieuwe-unieke-naam>" `
>   -backend-config="container_name=tfstate" `
>   -backend-config="key=azure-snowflake-dbt.tfstate"
> ```
> Of ga terug naar lokale state met een `backend_override.tf` (`terraform { backend "local" {} }`).

## 2. Snowflake opnieuw vullen

In Snowsight (worksheet) draaien:
1. `snowflake/01_setup.sql` (vervang `YOUR_USERNAME` door `ABDULLAHOZISIK`)
2. `snowflake/02_seed_raw_data.sql`

## 3. dbt draaien

> ⚠️ dbt MOET vanuit de venv draaien (de Microsoft Store-Python breekt de Snowflake-connector).

```powershell
cd c:\dev\azure-snowflake-dbt-project
.\.venv\Scripts\Activate.ps1               # bestaat de venv niet meer? python -m venv .venv ; .\.venv\Scripts\python.exe -m pip install dbt-snowflake
$env:SNOWFLAKE_USER = "ABDULLAHOZISIK"
$env:SNOWFLAKE_PASSWORD = "<jouw-wachtwoord>"

dbt deps
dbt debug      # -> All checks passed!
dbt run        # bouwt stg_* en dim_customers in ANALYTICS
dbt test
```

---

## Opruimen (kosten stoppen)

```powershell
# Platform-resources weghalen
cd c:\dev\azure-snowflake-dbt-project\terraform
terraform destroy -var="subscription_id=2087de47-3268-4f16-a553-92e38bf8cde5" -var="environment=dev"

# Optioneel: state-storage en service principal ook weg
az group delete --name rg-tfstate --yes
az ad app delete --id f3a19dee-c6b5-4a1d-ae32-9ecdff1691ff
```

## CD (werkend ✅)

De CD-pipeline (`.github/workflows/deploy.yml`) is volledig opgezet en getest:
- Service principal `f3a19dee-c6b5-4a1d-ae32-9ecdff1691ff` heeft Contributor +
  User Access Administrator op de subscription.
- OIDC federated credentials gekoppeld aan repo `AbdullahOzisik/azure-snowflake-dbt-project`.
- GitHub secrets gezet: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.

**Deployen via GitHub:** Actions > Deploy (Terraform apply) > Run workflow > kies `dev` > Run.
GitHub logt via OIDC in op Azure en draait `terraform apply` tegen de remote state.
