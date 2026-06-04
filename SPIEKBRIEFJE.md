# Spiekbriefje — Snowflake & dbt project

Compacte voorbereiding voor het gesprek. Lees top-to-bottom; alles hieronder
staat ook echt in deze repo.

---

## 1. Elevator pitch (30 sec)

> "Ik heb een end-to-end data-platform gebouwd: **Azure** levert de infra
> (data lake, Data Factory, Key Vault) via **Terraform**, **Snowflake** is het
> datawarehouse, en **dbt** doet de transformaties van ruwe data naar
> analytics-modellen. Alles is versioned in Git en wordt uitgerold via
> **CI/CD** (GitHub Actions, ook gespiegeld in Azure DevOps). Het hele platform
> is reproduceerbaar uit code — ik kan het weggooien en in een paar commando's
> weer opbouwen."

---

## 2. Architectuur (de lagen)

```
Bronnen → Azure Data Lake (ADLS Gen2) → Snowflake RAW → dbt → Snowflake ANALYTICS → BI
            ↑ Data Factory orkestreert        ↑ staging (views)  ↑ marts (tables)
   Terraform bouwt de Azure-infra        CI/CD rolt infra + dbt uit
```

- **Azure (infra, via Terraform):** resource group, **ADLS Gen2 data lake**
  (containers `raw`/`staging`/`curated`), **Key Vault** (secrets), **Data
  Factory** (orkestratie, met managed identity + `Storage Blob Data Contributor`
  op de lake).
- **Snowflake (warehouse):** warehouse `TRANSFORMING` (xsmall, auto-suspend 60s
  = lage kosten), databases `RAW` (bronlanding) en `ANALYTICS` (dbt-output),
  role `TRANSFORMER`.
- **dbt (transformatie):** `RAW.PUBLIC` → staging → marts in `ANALYTICS`.

---

## 3. Wat heb ik gebouwd (de lijst)

1. **Modulaire Terraform** voor de Azure-infra, met **remote state** in Azure
   Storage. Aparte modules: `resource_group`, `storage_account`, `key_vault`,
   `data_factory`.
2. **Snowflake-setup** als code: SQL-scripts die warehouse, databases, role en
   user aanmaken (`snowflake/01_setup.sql`) + seed-data (`02_seed_raw_data.sql`).
3. **dbt-project** met nette laagopbouw (sources → staging → marts), **13 data
   tests**, **macros**, en een externe package (`dbt_utils`).
4. **CI/CD in GitHub Actions:** `ci.yml` (validatie, gratis) + `deploy.yml`
   (deploy infra + dbt, passwordless via OIDC). Gespiegeld in
   `azure-pipelines.yml` voor Azure DevOps.
5. **Volledige reproduceerbaarheid:** `terraform destroy` → en in 4 stappen weer
   opgebouwd (zie §8). Documentatie in `HERSTART.md`.

---

## 4. Waarom dbt? (kernargumenten)

- **SQL + software-engineering:** transformaties als versioned code (Git), met
  modulariteit via `ref()` en `source()`.
- **Testen:** ingebouwde data-tests (uniqueness, not_null, relationships) — data
  quality als onderdeel van de pipeline.
- **Documentatie + lineage:** `dbt docs` genereert automatisch een lineage-graph
  uit je code.
- **Omgevingen:** dev/prod via targets, zelfde code.
- **ELT i.p.v. ETL:** transformeren ín het warehouse (Snowflake schaalt mee),
  niet in een losse server.

---

## 5. De modellaag (sources → staging → marts)

**Sources** (`_staging__sources.yml`): verwijst naar `RAW.PUBLIC.customers` en
`orders`. Hier staan ook de bron-tests.

**Staging** (materialized als **views** — goedkoop, altijd vers):
- `stg_customers` / `stg_orders`: 1-op-1 met de bron, alleen **hernoemen/
  opschonen** (bv. `id` → `customer_id`). Geen business-logica.

**Marts** (materialized als **dynamic tables** — zie §12):
- `dim_customers`: **klantdimensie verrijkt met ordermetrics**. Joint
  `stg_customers` met een aggregatie over `stg_orders`:
  `number_of_orders`, `lifetime_value`, `first_order_at`, `most_recent_order_at`.
  Gebruikt een `left join` + `coalesce(..., 0)` zodat klanten zonder orders
  netjes op 0 staan.

> Kernidee om te noemen: **staging = schoonmaken (view), marts = business-entiteit
> (dynamic table)**. Scheiding van verantwoordelijkheden, herbruikbaarheid via
> `ref()`. De marts ververst zichzelf via een `target_lag` (orkestratie, §12).

---

## 6. Tests (data quality)

- **13 tests**, o.a. `unique` + `not_null` op de sleutels van sources
  (`customers.id`, `orders.id`) en op `dim_customers.customer_id`.
- Draaien automatisch mee in `dbt build` (= `dbt run` + `dbt test` in één).
- **Uitbreidbaar:** `relationships` (orders.customer_id → customers.id),
  `accepted_values` (order_status). Goed om als "next step" te noemen.

---

## 7. CI/CD

| | CI (`ci.yml`) | CD (`deploy.yml`) |
|---|---|---|
| **Trigger** | elke push/PR naar main | handmatig (workflow_dispatch) |
| **Doet** | `terraform validate` + `dbt parse` | `terraform apply` → `dbt build` |
| **Cloud-login?** | nee (gratis, snel) | ja, via OIDC |
| **Kosten** | gratis | maakt resources aan |

- **Passwordless auth:** GitHub logt via **OIDC federated credentials** in op
  Azure — geen langlevende secrets in de repo. Snowflake-credentials staan als
  **GitHub secrets**, niet in code.
- **Approval-gate:** via een GitHub **Environment** kan de deploy op handmatige
  goedkeuring wachten (echte CD-poort).
- **Azure DevOps-variant:** zelfde stages in `azure-pipelines.yml`, maar auth via
  een **service connection (workload identity)** i.p.v. OIDC. → laat zien dat ik
  beide tools begrijp.

---

## 8. Reproduceerbaarheid (de "wow") — herstart in 4 stappen

1. `terraform apply` → Azure-infra
2. `python snowflake/run_sql.py snowflake/01_setup.sql` (+ `02_seed_...`) → Snowflake
3. `dbt build` → transformaties (3 modellen, 13 tests)
4. `dbt docs generate` + `dbt docs serve` → documentatie + lineage

Alles in Git. Wat bewust **niet** in code zit: wachtwoorden (secrets) en de
accounts zelf. → "Infrastructure as Code" in de praktijk.

---

## 9. Waarschijnlijke vragen + korte antwoorden

- **"Waarom staging als view en marts als table?"** Staging is licht opschonen,
  een view is goedkoop en altijd actueel. Marts worden vaak bevraagd door BI →
  als table gematerialiseerd voor snelheid.
- **"Hoe zorg je voor data quality?"** dbt-tests (unique/not_null/relationships)
  draaien in elke `dbt build`; CI faalt als een test faalt.
- **"Hoe ga je van dev naar prod?"** dbt-targets (dev/prod) met aparte schema's;
  CD draait `dbt build -t prod` achter een approval-gate.
- **"Waarom Snowflake?"** Gescheiden compute/storage, auto-suspend (kosten),
  schaalt per warehouse, ELT-vriendelijk.
- **"Wat doet Data Factory hier?"** Orkestratie/ingest: bronbestanden naar de
  data lake en richting Snowflake. dbt doet daarna de transformatie ín Snowflake.
- **"GitHub Actions of Azure DevOps?"** Functioneel gelijk; verschil zit in auth
  (OIDC vs service connection) en ecosysteem. Ik heb beide geïmplementeerd.

---

## 10. Demo-flow (als je live mag laten zien)

1. **GitHub** → tab Actions: groene CI-run.
2. **VS Code** → repo-structuur: `terraform/`, `models/staging` + `models/marts`.
3. `dbt docs serve` → **lineage-graph** (`raw → stg_* → dim_customers`).
4. **Snowsight** → `select * from analytics.dbt_dev_marts.dim_customers;`
5. (optioneel) **Azure portal** → resource group met de Terraform-resources.

---

## 11. Vergelijking met Databricks Asset Bundles (DABs)

> Ik heb met **DABs** gewerkt — handig om te laten zien dat ik het onderliggende
> patroon snap, los van de tool.

Beide lossen hetzelfde op: **een data-platform declaratief als versioned code
deployen, met dev/prod-omgevingen en CI/CD.** Verschil = *gebundeld vs.
samengesteld*.

| | Databricks Asset Bundles | Deze stack (Snowflake/Azure) |
|---|---|---|
| Config | één `databricks.yml` (jobs, DLT, notebooks, dbt-taken) | Terraform (infra) + dbt (transform) + CI/CD-YAML |
| Omgevingen | `targets:` (dev/prod) | dbt-targets + Terraform `-var`/tfvars |
| Onderhuids | gebruikt **Terraform** intern (geen HCL schrijven) | ik schrijf **Terraform zelf** (meer controle) |
| Orkestratie | Databricks Workflows in de bundle | los: Azure Data Factory / GitHub Actions |
| Deploy | `databricks bundle deploy` / `run` | `terraform apply` + `dbt build` via CI/CD |
| Scope | Databricks-ecosysteem | best-of-breed, multi-tool |

**Kernzin:** "DABs doen voor Databricks wat mijn Terraform + dbt + CI/CD doet
voor Snowflake/Azure — declaratief, versioned, multi-environment, reproduceerbaar.
Een bundle is *geïntegreerd*, mijn aanpak *modulair*."

**Overdraagbaar:** dbt draait ook op Databricks (`dbt-databricks`), en een DAB
kan een dbt-project als taak bevatten — de transformatielogica is hetzelfde,
alleen het deploy-/orkestratie-omhulsel verschilt.

---

## 12. Orkestratie in Snowflake (Dynamic Tables)

**Vraag die hier achter zit:** "Leuk dat het bouwt, maar hoe draait het
*automatisch* en *op tijd*?"

Ik orkestreer **declaratief met Dynamic Tables**: `dim_customers` is een
`dynamic_table` met `target_lag = '1 hour'`. Ik zeg dus *hoe vers* de data moet
zijn; **Snowflake plant en draait de refreshes zelf** (op warehouse
`TRANSFORMING`). Geen externe scheduler nodig.

```yaml
# dbt_project.yml
marts:
  +materialized: dynamic_table
  +snowflake_warehouse: TRANSFORMING
  +target_lag: "1 hour"
```

**De 3 orkestratie-opties (en waarom ik deze koos):**

| Optie | Wat | Trade-off |
|-------|-----|-----------|
| **Dynamic Tables** ✅ | declaratief, `target_lag`, Snowflake refresht zelf | minste code, blijft in dbt — **mijn keuze** |
| Snowflake Tasks | geplande SQL/DAG (CRON, `AFTER`) | expliciet, maar boilerplate; kan dbt-CLI niet aanroepen |
| dbt Projects on Snowflake | dbt native + Task-schedule | meest "native", meer setup |

**Verifiëren:** `show dynamic tables in database analytics;` → zie `target_lag`
en `scheduling_state`.

**Koppeling CI/CD:** de orkestratie is gewoon code (`dbt_project.yml`) → wordt via
dezelfde CI/CD gedeployt. CI/CD = *deployen*, Snowflake = *runnen op schema*.

---

## 13. Historie bijhouden — SCD Type 2 (dbt snapshots)

**Belangrijk:** SCD2 is **niet** vervangen door dynamic tables. Andere vraag:
- Dynamic table = *"hoe vers is de huidige data?"* (orkestratie)
- SCD2 = *"hoe zag een rij er **vroeger** uit?"* (historie)

Mijn `dim_customers` is nu **SCD1** (rebuild uit huidige bron → oude waarde
overschreven). Voor historie gebruik je in dbt **snapshots**:

```sql
-- snapshots/customers_snapshot.sql
{% snapshot customers_snapshot %}
{{ config(target_schema='snapshots', unique_key='id',
          strategy='check', check_cols=['first_name','last_name','email']) }}
select * from {{ source('raw', 'customers') }}
{% endsnapshot %}
```

`dbt snapshot` voegt automatisch `dbt_valid_from` / `dbt_valid_to` / `dbt_scd_id`
toe: bij een wijziging wordt de oude rij afgesloten en een nieuwe actieve rij
toegevoegd. Zo kun je vragen als *"welk e-mailadres had de klant tóén de order
werd geplaatst?"* beantwoorden.

**Demo (3 stappen):** `dbt snapshot` → `update raw.public.customers set email=...
where id=1;` → `dbt snapshot` opnieuw → rij 1 heeft nu 2 versies met
geldigheidsvensters.

---

## 14. Rol van Azure Data Factory (ingest/orkestratie)

ADF (`adf-asdbt-dev`) is via Terraform geprovisioned, met:
- een **linked service** naar de data lake (`stasdbtdevdl`);
- een **managed identity** die `Storage Blob Data Contributor` heeft op de lake
  → **passwordless** toegang, geen keys in code.

**Rol in de architectuur:** bronbestanden landen in de data lake en worden
richting Snowflake `RAW` geduwd. Daarna neemt **dbt** het over (transformatie ín
Snowflake). Zo weet je **waar ADF eindigt en dbt begint** — een veelgestelde
vraag.

**Eerlijk:** er zijn nog geen pipelines gebouwd. Next step die ik zou noemen: een
**Copy activity** (lake → Snowflake) met een **schedule-trigger**, of ingest via
**Snowpipe**.

> Tip voor het gesprek: je hoeft dit niet live te tonen. Kunnen *uitleggen* (rol,
> managed identity, lake→RAW→dbt) is voldoende. Bewaar live-demo voor de
> lineage-graph en de GitHub-repo.
