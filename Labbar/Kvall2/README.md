# Labbar kväll 2 - Azure i praktiken

Alla kommandon körs från den här mappen (`D:\Kvällskurs\Azure\Labbar\Kvall2`) i
PowerShell 7. Varje kommando står på en rad - inga backticks.

Allt som skapas hamnar i resource group `rg-azure-kvall2`. Städa efteråt med `./99-cleanup.ps1`.
Budgeten (steg 2) ligger på prenumerationen och finns kvar.

| Fil | Labb |
|---|---|
| `..\..\Infra\modules\budget.bicep` | Steg 2: budget med varningar, på prenumerationsnivå |
| `01-budget.ps1` | Steg 2: deployar budgeten (`az deployment sub create`) |
| `main.bicep` | Steg 3: App Service Plan och webbapp (använder `..\..\Infra\modules\appservice.bicep`) |
| `02-deploy.ps1` | Steg 3 och 6: skapar resource group och kör `main.bicep`. `-WhatIf` visar bara ändringarna |
| `03-publish.ps1` | Steg 4: `dotnet publish`, zip och `az webapp deploy` |
| `99-cleanup.ps1` | Steg 7: riv ned resource group |

Koden som körs finns i `..\..\SimpleApi` (en liten variant av API:t från Kubernetes-kursen).

> Filerna `00-start.ps1`, `01-publish.ps1`, `02-create-app-user.*` och `03-keyvault.ps1` i den här mappen
> är utbytta mot korta stubbar. De hör till kväll 3 (`..\Kvall3`) och kan raderas.

## Förutsättningar

```powershell
az login
az account show
az bicep version                      # annars: az bicep install
dotnet --version                      # 10.x
az webapp list-runtimes --os linux    # DOTNETCORE:10.0 ska finnas med
```

## Flödet

1. `az login`, kontrollera prenumerationen.
2. `./01-budget.ps1` - budget med varningar.
3. `./02-deploy.ps1` - plan och webbapp.
4. `./03-publish.ps1` - publicera SimpleApi.
5. Titta runt: log stream, App Settings, Kudu.
6. Ändra `greeting` i `main.bicep` eller kör `./02-deploy.ps1 -Greeting "Hej kursen" -WhatIf`, sedan utan `-WhatIf`.
7. `./99-cleanup.ps1`.

Alla kommandon och förklaringar står i presentationen *Azure - Grunder, Bicep och kostnad*.

## Vanliga problem

| Symptom | Orsak och lösning |
|---|---|
| `SKU not available` / kvot 0 för F1 | Byt region: `./02-deploy.ps1 -Location westeurope` |
| `LinuxFxVersion ... is not supported` | Runtime saknas i regionen: kolla `az webapp list-runtimes --os linux` och sätt `linuxFxVersion` i `appservice.bicep` |
| Budget-deployen nekas | Du saknar behörighet på prenumerationen (kräver Owner eller Contributor med Cost Management) |
| Webbappens namn är upptaget | Namnen är globalt unika. Kör om, eller byt resource group-namn (suffixet bygger på resource group-id) |
| Första anropet efter en stund tar lång tid | Gratisplanen F1 saknar Always On - appen sover. Anropa igen. |
| `az` hittas inte | Starta om PowerShell efter installationen |
| Resource provider inte registrerad | `az provider register --namespace Microsoft.Web` (och `Microsoft.Consumption` för budgeten) |
