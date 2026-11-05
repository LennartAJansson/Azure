# =============================================================================
# Steg 4 - Publicera SimpleApi till webbappen
#
#   ./03-publish.ps1
#
# dotnet publish -> zip -> az webapp deploy.
# =============================================================================
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true
. "$PSScriptRoot\lab-vars.ps1"

$proj = Resolve-Path "$PSScriptRoot\..\..\SimpleApi\SimpleApi\SimpleApi.csproj"
$publishDir = "$PSScriptRoot\publish"
$zip = "$PSScriptRoot\app.zip"

if (Test-Path $publishDir) { Remove-Item $publishDir -Recurse -Force }
if (Test-Path $zip) { Remove-Item $zip -Force }

dotnet publish $proj -c Release -o $publishDir
Compress-Archive -Path "$publishDir\*" -DestinationPath $zip -Force

az webapp deploy --resource-group $rg --name $app --src-path $zip --type zip

Write-Host ""
Write-Host "https://$appHost/info" -ForegroundColor Green
Write-Host "https://$appHost/weatherforecast" -ForegroundColor Green
Write-Host "https://$appHost/scalar/v1" -ForegroundColor Green
