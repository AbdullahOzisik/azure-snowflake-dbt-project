# Azure DevOps Pipelines — setup

Dit project heeft naast GitHub Actions ook een **Azure DevOps Pipeline**
(`azure-pipelines.yml`) met dezelfde CI/CD: validatie + deploy naar Azure.

## Eenmalige setup

### 1. Organisatie + project
1. Ga naar https://dev.azure.com en maak (of kies) een **organisatie**.
2. Maak een nieuw **project** (bv. `azure-snowflake-dbt`), privé of publiek.

### 2. Repo koppelen
- **Pipelines** > **New pipeline** > **GitHub** > kies
  `AbdullahOzisik/azure-snowflake-dbt-project`.
- Azure DevOps detecteert automatisch `azure-pipelines.yml`.
- (Je autoriseert eenmalig de Azure Pipelines GitHub-app.)

### 3. Service connection naar Azure
- **Project Settings** > **Service connections** > **New service connection** >
  **Azure Resource Manager** > **Workload Identity federation (automatic)**.
- Scope: je subscription `sub-datapartner365-lab`.
- Noem 'm exact **`azure-snowflake-dbt-sc`** (zo heet de variabele in de pipeline).
- Dit maakt automatisch een app-registratie + federated credential aan en geeft
  die **Contributor**. Voor de role-assignment in Terraform geef je 'm ook
  **User Access Administrator** (Subscription > Access control (IAM) > Add).

### 4. Environment met approval (optioneel maar netjes)
- **Pipelines** > **Environments** > **New environment** > naam **`dev`**.
- Voeg eventueel onder **Approvals and checks** jezelf toe als approver →
  dan moet je de deploy handmatig goedkeuren (echte CD-gate).

### 5. Pipeline draaien
- **Pipelines** > selecteer de pipeline > **Run**.
- Stage **Validate** draait automatisch; stage **Deploy** wacht op je approval
  (als je stap 4 deed) en doet daarna `terraform apply` naar Azure.

## Opruimen
De resources die deze pipeline aanmaakt, ruim je net als altijd op met:

```powershell
cd terraform
terraform destroy -var="subscription_id=2087de47-3268-4f16-a553-92e38bf8cde5" -var="environment=dev"
```

## Verschil met de GitHub Actions-variant
| | GitHub Actions | Azure DevOps |
|---|---|---|
| CI | `.github/workflows/ci.yml` | stage `Validate` |
| CD | `.github/workflows/deploy.yml` | stage `Deploy` |
| Auth | OIDC federated credential | Service connection (Workload Identity) |
| Approval-gate | GitHub Environment | Azure DevOps Environment |

Zelfde platform, twee CI/CD-implementaties — handig om beide te beheersen.
