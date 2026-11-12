# =============================================================================
# Steg 2/3 - Släpp in http://localhost:4200 (ng serve) i CORS på det publicerade API:t
#
#   ./05-cors-local.ps1
#
# main.bicep släpper bara in Static Web Apps. Kör du klienten lokalt mot det
# publicerade API:t blockerar webbläsaren anropet (CORS). Det här skriptet lägger
# till localhost för hand. OBS: en ny Bicep-deploy tar bort den (drift) -
# lägg annars till origin i corsOrigins i main.bicep.
# =============================================================================
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true   # stoppa om npm/ng/dotnet/az returnerar felkod
. "$PSScriptRoot\lab-vars.ps1"

az webapp cors add --resource-group $rg --name $app --allowed-origins "http://localhost:4200"
az webapp cors show --resource-group $rg --name $app -o json
