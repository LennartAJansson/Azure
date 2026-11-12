# =============================================================================
# Steg 5 - Deploya klienten till Static Web Apps
#
#   ./02-deploy-client.ps1
#
# Kör efter 01-build.ps1. Skriver config.json i utmappen (inte i källkoden) med
# API-adressen, hämtar deployment token från Azure (sparas aldrig i fil) och
# deployar med Static Web Apps CLI.
# =============================================================================
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true   # stoppa om npm/ng/dotnet/az returnerar felkod
. "$PSScriptRoot\lab-vars.ps1"

$dist = "$PSScriptRoot\CustomerClient\dist\CustomerClient\browser"
if (-not (Test-Path "$dist\index.html")) { throw "Inget bygge i $dist - kör ./01-build.ps1 först." }

# Runtime-konfiguration: samma bygge i alla miljöer, bara config.json skiljer.
@{ apiBaseUrl = "https://$appHost" } | ConvertTo-Json | Set-Content -Path "$dist\config.json" -Encoding utf8NoBOM
Write-Host "API: https://$appHost" -ForegroundColor Cyan

$token = az staticwebapp secrets list --name $swa --resource-group $rg --query properties.apiKey -o tsv
if (-not $token) { throw "Tomt deployment token." }

# Token via miljövariabel så att den inte syns i processlistan.
$env:SWA_CLI_DEPLOYMENT_TOKEN = $token
# Hoppa över installationsskript när npx hämtar CLI:t (samma 'node saknas i cmd'-problem som vid npm ci).
$env:npm_config_ignore_scripts = "true"
try { npx --yes @azure/static-web-apps-cli deploy $dist --env production }
finally {
    Remove-Item Env:\SWA_CLI_DEPLOYMENT_TOKEN -ErrorAction SilentlyContinue
    Remove-Item Env:\npm_config_ignore_scripts -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "https://$swaHost" -ForegroundColor Green
Write-Host "https://$swaHost/status" -ForegroundColor Green
