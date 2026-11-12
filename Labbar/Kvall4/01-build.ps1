# =============================================================================
# Steg 4 - Bygg och testa Angular-klienten
#
#   ./01-build.ps1
#
# npm ci -> enhetstester (Vitest) -> ng build. Stoppar vid första felet, så ett
# rött test betyder att inget byggs eller deployas efteråt.
# =============================================================================
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true   # stoppa om npm/ng returnerar felkod

Push-Location "$PSScriptRoot\CustomerClient"
try {
    # --ignore-scripts: hoppar över installationsskripten (@parcel/watcher bygger annars från källkod
    # och hittar inte node via cmd på den här maskinen). Bygge och test behöver dem inte.
    npm ci --ignore-scripts
    npm test -- --watch=false
    npm run build
    Write-Host ""
    Write-Host "Klart: CustomerClient\dist\CustomerClient\browser" -ForegroundColor Green
}
finally { Pop-Location }
