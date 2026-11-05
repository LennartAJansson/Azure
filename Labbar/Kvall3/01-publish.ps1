# =============================================================================
# Steg 3 - Publicera CustomersApi till webbappen
#
#   ./01-publish.ps1
#
# dotnet publish -> zip -> az webapp deploy. Anropet till /customers kommer att
# MISSLYCKAS första gången - appen har en identitet, men databasen känner inte
# till den än. Det löser ni i steg 4.
# =============================================================================
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true
. "$PSScriptRoot\lab-vars.ps1"

$proj = Resolve-Path "$PSScriptRoot\..\..\CustomersApi\CustomersApi\CustomersApi.csproj"
$publishDir = "$PSScriptRoot\publish"
$zip = "$PSScriptRoot\app.zip"

if (Test-Path $publishDir) { Remove-Item $publishDir -Recurse -Force }
if (Test-Path $zip) { Remove-Item $zip -Force }

dotnet publish $proj -c Release -o $publishDir
Compress-Archive -Path "$publishDir\*" -DestinationPath $zip -Force

az webapp deploy --resource-group $rg --name $app --src-path $zip --type zip

Write-Host ""
Write-Host "https://$appHost/healthz" -ForegroundColor Green
Write-Host "https://$appHost/db/whoami" -ForegroundColor Green
Write-Host "https://$appHost/customers" -ForegroundColor Green
Write-Host "https://$appHost/scalar/v1" -ForegroundColor Green
