# =============================================================================
# Steg 3 och 6 - Skapa plan och webbapp med Bicep
#
#   ./02-deploy.ps1            # skapar resource group och kör main.bicep
#   ./02-deploy.ps1 -WhatIf    # visar bara vad som skulle ändras (what-if)
#   ./02-deploy.ps1 -Greeting "Hej kursen"
#
# Skriver namnen till lab-vars.ps1 som övriga skript läser.
# Byt region om kvoten för gratisplanen är slut:  ./02-deploy.ps1 -Location westeurope
# =============================================================================
param(
    [string]$Location = "swedencentral",
    [string]$ResourceGroup = "rg-azure-kvall2",
    [string]$Greeting = "Hej från Azure",
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

$account = az account show -o json | ConvertFrom-Json
Write-Host "Prenumeration: $($account.name)" -ForegroundColor Cyan

$owner = $env:USERNAME
$template = "$PSScriptRoot\main.bicep"
$params = @("owner=$owner", "greeting=$Greeting")

# Resource group med taggar - så kan ni följa kostnaden per kväll och person.
az group create --name $ResourceGroup --location $Location --tags "owner=$owner" "course=azure-kvallskurs" "kvall=2" -o none

if ($WhatIf) {
    Write-Host "what-if: så här skulle resource group ändras" -ForegroundColor Cyan
    az deployment group what-if --resource-group $ResourceGroup --template-file $template --parameters $params
    return
}

Write-Host "Kör main.bicep (tar någon minut)..." -ForegroundColor Cyan
$out = az deployment group create --resource-group $ResourceGroup --template-file $template --parameters $params --query properties.outputs -o json | ConvertFrom-Json

$vars = @"
`$rg = '$ResourceGroup'
`$location = '$Location'
`$app = '$($out.appName.value)'
`$appHost = '$($out.appHost.value)'
"@
Set-Content -Path "$PSScriptRoot\lab-vars.ps1" -Value $vars -Encoding utf8

Write-Host ""
Write-Host "Klart:" -ForegroundColor Green
Get-Content "$PSScriptRoot\lab-vars.ps1"
