# =============================================================================
# Steg 2 - Budget med alert (prenumerationsnivå)
#
#   ./01-budget.ps1                # 10 i prenumerationens valuta per månad
#   ./01-budget.ps1 -Amount 25
#
# Budgeten varnar per e-post vid 50 %, 80 % och när prognosen når 100 %.
# Den stoppar ingenting. Den ligger på prenumerationen och finns kvar när ni
# river ned resource groups.
# =============================================================================
param(
    [int]$Amount = 10,
    [string]$Location = "swedencentral"
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

$account = az account show -o json | ConvertFrom-Json
$email = $account.user.name   # din inloggning, oftast e-postadressen
Write-Host "Prenumeration: $($account.name)" -ForegroundColor Cyan
Write-Host "Varningar till: $email" -ForegroundColor Cyan

az deployment sub create --name budget-azurekurs --location $Location --template-file "$PSScriptRoot\..\..\Infra\modules\budget.bicep" --parameters "contactEmail=$email" "amount=$Amount" --query properties.outputs.budgetId.value -o tsv

Write-Host "Klart. Titta i portalen: Cost Management -> Budgets." -ForegroundColor Green
