# =============================================================================
# Städa - riv ned allt för kväll 4
#
#   ./99-cleanup.ps1
#
# Tar bort resource group (webbapp, plan, SQL, Key Vault) och rensar sedan
# Key Vault för gott. Utan "purge" ligger valvet kvar som borttaget i sju dagar
# och blockerar namnet om ni kör labben igen.
# =============================================================================
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\lab-vars.ps1"

az group delete --name $rg --yes
az keyvault purge --name $kv --location $location

Write-Host "Borttaget. Kontrollera:" -ForegroundColor Green
az group list -o table
