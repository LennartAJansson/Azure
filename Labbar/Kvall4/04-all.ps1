# =============================================================================
# Steg 7 - Hela flödet: bygg + testa klient, deploya API, deploya klient
#
#   ./04-all.ps1
#
# Stannar vid första felet. Är ett test rött deployas ingenting. Detta är vad en
# pipeline gör - fast här kör vi det själva (se azure-pipelines.yml).
# =============================================================================
$ErrorActionPreference = "Stop"

& "$PSScriptRoot\01-build.ps1"
& "$PSScriptRoot\03-deploy-api.ps1"
& "$PSScriptRoot\02-deploy-client.ps1"

Write-Host ""
Write-Host "Allt klart." -ForegroundColor Green
