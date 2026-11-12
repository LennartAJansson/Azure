# Kväll 4 – Angular och CI/CD (lokalt bygge, PowerShell-deploy)

Allt för kvällen ligger här i egna kopior: `CustomersApi\`, `CustomerClient\`, `modules\` (Bicep) och skripten.
`Infra\` och tidigare labbar är orörda. Kräver bara `az login` (inget Graph, ingen service connection).

```
Labbar\Kvall4\
  00-start.ps1  00b-create-app-user.ps1  01-build.ps1  02-deploy-client.ps1
  03-deploy-api.ps1  04-all.ps1  05-cors-local.ps1  99-cleanup.ps1
  main.bicep  modules\   (appservice med CORS, sql, keyvault, staticwebapp)
  CustomersApi\  CustomerClient\  azure-pipelines.yml
```

## Gör så här
| Steg | Gör |
|---|---|
| 1 | `./00-start.ps1` – resource group `rg-azure-kvall4`: App Service, SQL, Key Vault och Static Web Apps (Free, westeurope). Skriver `lab-vars.ps1`. |
| 2 | `./00b-create-app-user.ps1` – databasanvändare åt webbappens identitet. Sedan schemat (nedan). |
| 3 | `./03-deploy-api.ps1`, öppna `/healthz`, `/customers`. |
| 4 | **CORS-felet:** `cd CustomerClient; npm ci; npm start`. Sätt `public\config.json` till API-adressen (`https://<appHost>`). Klienten på `http://localhost:4200` blockeras av CORS. Åtgärd: `./05-cors-local.ps1` (eller kör API:t lokalt, `http://localhost:60254`, där CORS för 4200 finns i Development). |
| 5 | `./01-build.ps1` (npm ci, test, build). |
| 6 | `./02-deploy-client.ps1` – öppna `https://<swaHost>`. Testa F5 på `/status`. |
| 7 | `./04-all.ps1` – hela kedjan. Bryt ett test i `CustomerClient\src\app\*.spec.ts`, kör igen: inget deployas. |
| 8 | Visa `azure-pipelines.yml` (körs inte) – varje stage motsvarar ett skript. |
| 9 | `./99-cleanup.ps1` – riv och purga Key Vault. |

## Schemat (EF-migrering, som kväll 3)
```powershell
. .\lab-vars.ps1
$env:ConnectionStrings__CustomersDb = $conn
dotnet tool install --global dotnet-ef    # första gången
dotnet ef database update --project .\CustomersApi\CustomersApi
```

## Vad som är nytt jämfört med kväll 3
- `modules\staticwebapp.bicep` (ny) och `corsOrigins` i `modules\appservice.bicep`. `main.bicep` släpper in Static Web Apps origin automatiskt.
- `CustomersApi\...\Program.cs`: CORS för `http://localhost:4200`, **bara** i Development (i Azure sköter App Service CORS).
- `CustomerClient`: Angular 22, Vitest (ingen webbläsare behövs), runtime-config i `public\config.json`.

## Felsökning
- CORS-fel mot Azure: origin måste vara exakt `https://<host>` utan avslutande snedstreck.
- F5 på `/status` ger 404: `public\staticwebapp.config.json` saknas i bygget.
- Free-SWA finns inte i swedencentral, därför `swaLocation = westeurope` i `main.bicep`.
- En ny Bicep-deploy tar bort `http://localhost:4200` som lades till med `05-cors-local.ps1`.
