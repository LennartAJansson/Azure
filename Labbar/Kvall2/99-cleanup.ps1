# =============================================================================
# Städa - riv ned resource group för kväll 2
#
#   ./99-cleanup.ps1
#
# Tar bort resource group (plan + webbapp). Budgeten ligger på prenumerationen
# och finns kvar.
# =============================================================================
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\lab-vars.ps1"

az group delete --name $rg --yes

Write-Host "Borttaget. Kontrollera:" -ForegroundColor Green
az group list -o table
