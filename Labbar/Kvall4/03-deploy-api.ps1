# =============================================================================
# Steg 6 - Bygg och deploya CustomersApi (Release -> zip -> App Service)
#
#   ./03-deploy-api.ps1
#
# Samma flöde som ./01-publish.ps1 i kväll 3, men med ett bygge först. Misslyckas
# bygget deployas ingenting. Finns det testprojekt: lägg till "dotnet test".
# =============================================================================
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true   # stoppa om npm/ng/dotnet/az returnerar felkod
. "$PSScriptRoot\lab-vars.ps1"

$proj = "$PSScriptRoot\CustomersApi\CustomersApi\CustomersApi.csproj"
$publishDir = "$PSScriptRoot\publish"
$zip = "$PSScriptRoot\app.zip"

if (Test-Path $publishDir) { Remove-Item $publishDir -Recurse -Force }
if (Test-Path $zip) { Remove-Item $zip -Force }

dotnet build $proj -c Release
dotnet publish $proj -c Release --no-build -o $publishDir
Compress-Archive -Path "$publishDir\*" -DestinationPath $zip -Force

az webapp deploy --resource-group $rg --name $app --src-path $zip --type zip

Write-Host ""
Write-Host "https://$appHost/healthz" -ForegroundColor Green
Write-Host "https://$appHost/customers" -ForegroundColor Green
