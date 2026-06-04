# azure-snowflake-dbt-project

Data-pipeline project met **Azure**, **Snowflake** en **dbt**.

## Overzicht

Dit project bevat de transformatielaag (dbt) voor een Snowflake-datawarehouse,
met orkestratie/infra op Azure.

## Structuur (in te vullen)

```
models/        # dbt-modellen (staging, intermediate, marts)
macros/        # herbruikbare SQL-macro's
seeds/         # statische referentiedata
tests/         # data-tests
dbt_project.yml
profiles.yml   # NIET committen — staat in .gitignore
```

## Aan de slag

```bash
dbt deps
dbt seed
dbt run
dbt test
```

## CI/CD

GitHub Actions in `.github/workflows/`:

| Workflow | Wanneer | Wat | Kosten |
|----------|---------|-----|--------|
| `ci.yml` | Automatisch bij elke push/PR | `terraform validate` + `dbt parse` (geen cloud-login) | Gratis |
| `deploy.yml` | Handmatig (Actions > Run workflow) | `terraform apply` naar Azure (OIDC) **→ daarna `dbt build` tegen Snowflake** | Kost geld |

De CD is end-to-end: eerst rolt Terraform de Azure-infra uit, daarna bouwt en
test dbt de modellen in Snowflake (`dbt deps` + `dbt build`).

### Benodigde GitHub secrets

`Settings > Secrets and variables > Actions` (of per **Environment** `dev`/`prod`):

| Secret | Voor | Voorbeeld |
|--------|------|-----------|
| `AZURE_CLIENT_ID` | OIDC-login Azure | (service principal client-id) |
| `AZURE_TENANT_ID` | OIDC-login Azure | `a38d5b47-…` |
| `AZURE_SUBSCRIPTION_ID` | OIDC-login Azure | `2087de47-…` |
| `SNOWFLAKE_ACCOUNT` | dbt → Snowflake | `AFHVMYZ-UX38783` |
| `SNOWFLAKE_USER` | dbt → Snowflake | `ABDULLAHOZISIK` of `DBT_USER` |
| `SNOWFLAKE_PASSWORD` | dbt → Snowflake | (sterk wachtwoord) |

De `deploy.yml` gebruikt OIDC federated credentials voor Azure; de Snowflake-
secrets vullen `profiles.yml.example` via env-vars (geen wachtwoord in de repo).

## Auteur

Abdullah Ozisik
