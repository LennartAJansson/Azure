# =============================================================================
# Steg 1 - Starta miljön för kväll 3
#
#   ./00-start.ps1
#
# Skapar resource group rg-azure-kvall3 och kör main.bicep: App Service (med
# Managed Identity), Azure SQL (endast Entra-inloggning) och Key Vault (RBAC).
# Skriver sedan namnen till lab-vars.ps1 som de andra skripten läser.
#
# Byt region om kvoten för gratisplanen är slut:  ./00-start.ps1 -Location westeurope
# Saknar prenumerationen gratis-SQL:             ./00-start.ps1 -UseFreeOffer $false
# =============================================================================
param(
    [string]$Location = "swedencentral",
    [string]$ResourceGroup = "rg-azure-kvall3",
    [bool]$UseFreeOffer = $false
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true   # stoppa om ett az-kommando misslyckas

# Är du inloggad? (kör "az login" annars)
$account = az account show -o json | ConvertFrom-Json
Write-Host "Prenumeration: $($account.name)" -ForegroundColor Cyan

# Vem är du? Du blir Entra-admin på SQL-servern och Secrets Officer i Key Vault.
# Först Microsoft Graph. På en icke-managerad dator kan Conditional Access blockera Graph,
# då läser vi UPN och objekt-ID ur den vanliga Azure-token (claims "upn" och "oid").
$me = $null
$PSNativeCommandUseErrorActionPreference = $false
$graphJson = az ad signed-in-user show -o json 2>$null
$graphOk = ($LASTEXITCODE -eq 0)
$PSNativeCommandUseErrorActionPreference = $true
if ($graphOk -and $graphJson) {
    $me = $graphJson | ConvertFrom-Json
}
else {
    Write-Host "Graph ej tillgängligt - läser identiteten ur Azure-token." -ForegroundColor Yellow
    $token = az account get-access-token --resource https://management.azure.com/ --query accessToken -o tsv
    $payload = $token.Split('.')[1].Replace('-', '+').Replace('_', '/')
    $payload = $payload.PadRight($payload.Length + (4 - $payload.Length % 4) % 4, '=')
    $claims = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload)) | ConvertFrom-Json
    $upn = if ($claims.upn) { $claims.upn } elseif ($claims.unique_name) { $claims.unique_name } else { $claims.preferred_username }
    $me = [pscustomobject]@{ userPrincipalName = $upn; id = $claims.oid }
}
Write-Host "Inloggad som:  $($me.userPrincipalName)" -ForegroundColor Cyan

# Din publika IP - SQL-brandväggen släpper bara in den (och Azure-tjänster).
$ip = (Invoke-RestMethod -Uri "https://api.ipify.org").Trim()
Write-Host "Din IP:        $ip" -ForegroundColor Cyan

$owner = $env:USERNAME
az group create --name $ResourceGroup --location $Location --tags "owner=$owner" "course=azure-kvallskurs" "kvall=3" -o none

$params = @(
    "location=$Location"
    "owner=$owner"
    "adminLogin=$($me.userPrincipalName)"
    "adminObjectId=$($me.id)"
    "clientIp=$ip"
    "useFreeOffer=$($UseFreeOffer.ToString().ToLower())"
)

Write-Host "Kör main.bicep (tar några minuter)..." -ForegroundColor Cyan
$out = az deployment group create --resource-group $ResourceGroup --template-file "$PSScriptRoot\main.bicep" --parameters $params --query properties.outputs -o json | ConvertFrom-Json

# Skriv namnen till en fil som övriga skript "dot-sourcar" (. ./lab-vars.ps1).
$vars = @"
`$rg = '$ResourceGroup'
`$location = '$Location'
`$app = '$($out.appName.value)'
`$appHost = '$($out.appHost.value)'
`$appPrincipalId = '$($out.appPrincipalId.value)'
`$sqlServer = '$($out.sqlServer.value)'
`$sqlFqdn = '$($out.sqlFqdn.value)'
`$db = '$($out.dbName.value)'
`$kv = '$($out.kvName.value)'
`$kvId = '$($out.kvId.value)'
# Connection string utan lösenord - samma sträng lokalt och i Azure.
`$conn = 'Server=tcp:$($out.sqlFqdn.value),1433;Database=$($out.dbName.value);Authentication=Active Directory Default;Encrypt=True;Connection Timeout=60;'
"@
Set-Content -Path "$PSScriptRoot\lab-vars.ps1" -Value $vars -Encoding utf8

Write-Host ""
Write-Host "Klart. Namnen ligger i lab-vars.ps1:" -ForegroundColor Green
Get-Content "$PSScriptRoot\lab-vars.ps1" | Where-Object { $_ -notmatch "^#" }
