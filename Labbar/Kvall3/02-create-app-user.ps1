# =============================================================================
# Steg 4 - Skapa databasanvändaren åt webbappens Managed Identity
#
#   ./02-create-app-user.ps1
#
# Skriver ut SQL:en. Finns "sqlcmd" (go-sqlcmd) körs den direkt, annars kopierar
# ni SQL:en till VS Code (mssql) eller SSMS - se 02-create-app-user.sql.
#   winget install sqlcmd
# =============================================================================
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\lab-vars.ps1"

$sql = @"
CREATE USER [$app] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [$app];
ALTER ROLE db_datawriter ADD MEMBER [$app];
"@

Write-Host "Databas: $sqlFqdn / $db" -ForegroundColor Cyan
Write-Host $sql -ForegroundColor Yellow

if (Get-Command sqlcmd -ErrorAction SilentlyContinue) {
    sqlcmd -S $sqlFqdn -d $db --authentication-method ActiveDirectoryDefault -Q $sql
    if ($LASTEXITCODE -eq 0) { Write-Host "Användaren skapad." -ForegroundColor Green }
    else { Write-Host "sqlcmd misslyckades - kör SQL:en ovan i VS Code (mssql) eller SSMS i stället." -ForegroundColor Red }
}
else {
    Write-Host "sqlcmd finns inte - kör SQL:en ovan i VS Code (mssql) eller SSMS, inloggad med Microsoft Entra ID." -ForegroundColor Red
}
