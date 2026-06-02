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

## Auteur

Abdullah Ozisik
