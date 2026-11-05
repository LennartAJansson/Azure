# =============================================================================
# Steg 5 - Key Vault-referens (facit)
#
#   ./03-keyvault.ps1 -Step secret      # 5a: skapa hemligheten i valvet
#   ./03-keyvault.ps1 -Step reference   # 5b: peka App Setting på hemligheten
#   # titta på https://<app>/config  ->  "ej upplöst" (appen saknar roll!)
#   ./03-keyvault.ps1 -Step role        # 5c: ge appens identitet Key Vault Secrets User
#   # titta igen  ->  "upplöst"
#
# Roller kan ta någon minut på sig att slå igenom. Misslyckas 5a direkt efter
# labbstarten: vänta en stund (din Secrets Officer-roll håller på att slå igenom).
# =============================================================================
param(
    [Parameter(Mandatory)][ValidateSet("secret", "reference", "role")][string]$Step
)
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true
. "$PSScriptRoot\lab-vars.ps1"

switch ($Step) {
    "secret" {
        # En API-nyckel till en extern tjänst - sådant som en identitet INTE kan ersätta.
        az keyvault secret set --vault-name $kv --name ExternalApiKey --value "demo-nyckel-$(Get-Random)" --query id -o tsv
    }
    "reference" {
        $ref = "Demo__ExternalApiKey=@Microsoft.KeyVault(VaultName=${kv};SecretName=ExternalApiKey)"
        az webapp config appsettings set --resource-group $rg --name $app --settings $ref -o none
        Write-Host "App Setting satt. Titta på https://$appHost/config" -ForegroundColor Green
    }
    "role" {
        az role assignment create --assignee-object-id $appPrincipalId --assignee-principal-type ServicePrincipal --role "Key Vault Secrets User" --scope $kvId -o none
        # Ändrar man en App Setting startas appen om och alla referenser hämtas på nytt.
        az webapp restart --resource-group $rg --name $app
        Write-Host "Roll tilldelad och appen omstartad. Titta på https://$appHost/config" -ForegroundColor Green
    }
}
