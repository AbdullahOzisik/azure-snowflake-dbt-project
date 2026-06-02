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
| `deploy.yml` | Handmatig (Actions > Run workflow) | `terraform apply` naar Azure via OIDC | Kost geld |

`deploy.yml` vereist de secrets `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` en
`AZURE_SUBSCRIPTION_ID` (Settings > Secrets and variables > Actions) en een
service principal met federated credentials.

## Auteur

Abdullah Ozisik
