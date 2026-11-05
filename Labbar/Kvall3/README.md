# Labbar kväll 3 - data och identitet

Alla kommandon körs från den här mappen (`D:\Kvällskurs\Azure\Labbar\Kvall3`) i
PowerShell 7. Varje kommando står på en rad - inga backticks.

Allt som skapas hamnar i resource group `rg-azure-kvall3`. Städa efteråt med `./99-cleanup.ps1`.

| Fil | Labb |
|---|---|
| `main.bicep` | Sätter ihop modulerna i `..\..\Infra\modules` (App Service, Azure SQL, Key Vault) |
| `00-start.ps1` | Steg 1: skapar resource group, kör `main.bicep` och skriver `lab-vars.ps1` |
| `01-publish.ps1` | Steg 3: `dotnet publish`, zip och `az webapp deploy` |
| `02-create-app-user.sql` | Steg 4: contained user + roller åt webbappens Managed Identity |
| `02-create-app-user.ps1` | Steg 4: genererar SQL:en och kör den med `sqlcmd` om det finns |
| `03-keyvault.ps1` | Steg 5: hemlighet, Key Vault-referens och rolltilldelning (`-Step secret\|reference\|role`) |
| `99-cleanup.ps1` | Riv ned resource group och rensa Key Vault (purge) |

Koden som körs finns i `..\..\CustomersApi` (samma Customer-API som `TelemetryApi`, men mot Azure SQL).

## Förutsättningar

```powershell
az login
az account show
dotnet --version                      # 10.x
dotnet tool install --global dotnet-ef
az webapp list-runtimes --os linux    # DOTNETCORE:10.0 ska finnas med
```

SQL-klient (en av): VS Code med mssql-tillägget, SSMS, eller `winget install sqlcmd`.

## Flödet

1. `./00-start.ps1` - miljön skapas (några minuter).
2. Lokalt mot Azure SQL, inloggad via `az login`:

   ```powershell
   . ./lab-vars.ps1
   $env:ConnectionStrings__CustomersDb = $conn
   cd ..\..\CustomersApi
   dotnet ef migrations add Initial --project .\CustomersApi
   dotnet ef database update --project .\CustomersApi
   dotnet run --project .\CustomersApi --urls http://localhost:5080
   ```

3. `./01-publish.ps1` - och se anropet misslyckas.
4. `./02-create-app-user.ps1` - ge appens identitet åtkomst. Anropet fungerar.
5. `./03-keyvault.ps1 -Step secret`, sedan `reference`, titta på `/config`, sedan `role`.
6. `./99-cleanup.ps1`.

Alla kommandon och förklaringar står i presentationen *Azure - Data och identitet*.

## Vanliga problem

| Symptom | Orsak och lösning |
|---|---|
| `SKU not available` / kvot 0 för F1 | Byt region: `./00-start.ps1 -Location westeurope` |
| Fel vid gratis-SQL (`useFreeLimit`) | Prenumerationen kan inte använda erbjudandet: `./00-start.ps1 -UseFreeOffer $false` |
| `Client with IP address ... is not allowed to access the server` | Din IP har ändrats: `az sql server firewall-rule update -g $rg -s $sqlServer -n labb-dator --start-ip-address <ip> --end-ip-address <ip>` |
| `Login failed for user '<token-identified principal>'` | Databasanvändaren saknas - kör steg 4 |
| Första anropet tar en minut eller blir fel | Serverless-databasen vaknar efter paus. EF Core försöker igen. Anropa igen. |
| `az keyvault secret set` nekas direkt efter start | Rollen Secrets Officer har inte slagit igenom - vänta en minut |
| `/config` säger "ej upplöst" | Appens identitet saknar rollen Key Vault Secrets User (steg 5c) |
| Namnet på Key Vault är upptaget vid ny körning | Valvet ligger borttaget: `az keyvault purge --name <namn> --location <region>` |

Obs: en öppen anslutning (till exempel SSMS Object Explorer) hindrar databasen från att pausa sig och drar vCore-sekunder.
