# Azure – kvällskurs: "Från sensor till lampa"

8 tillfällen à 3 timmar (tillfälle 1 certifieringar, tillfälle 2–8 Azure-labbar). **Fokus är Azure-tjänsterna**: App Service, Azure SQL, Key Vault, Service Bus, Functions, Static Web Apps, Azure DevOps och Application Insights. Fortsättning på Kubernetes-kursen (k3d/K3s), med särskild koppling till telemetrikvällarna.

ESP32-S3 (BME280) och Raspberry Pi (lampa) är **färdiga sidospår** som instruktören kopplar in för att visa Service Bus i användning. Deltagarna bygger dem inte.

## 1. Schema och status

- Kursen körs **onsdag och torsdag varje vecka i fyra veckor**.
- **Tillfälle 1** hölls torsdag 29 oktober och ägnades helt åt certifieringar (kollegans material). Inget Azure-labbinnehåll ingår där.
- **Tillfälle 2–8 är sju Azure-kvällar** med start onsdag 4 november. Allt som tidigare låg på åtta kvällar är komprimerat till sju: Telemetri och Helheten är sammanslagna till kväll 8.
- Kväll 2 börjar från noll. Kväll 3 är självbärande: `00-start.ps1` skapar allt som behövs, så ingen halkar efter.
- Onsdag och torsdag ligger dag efter dag. Inget hemarbete mellan två kvällar i samma vecka.

| Tillfälle | Tema | Datum (förslag, bekräfta) | Material |
|---|---|---|---|
| 1 | Certifieringar | torsdag 29 oktober, genomfört | kollegans eget |
| 2 | Grunder, Bicep och kostnad | onsdag 4 november | `Azure - Grunder, Bicep och kostnad.pptx`, `Labbar\Kvall2`, `SimpleApi` |
| 3 | Data och identitet | torsdag 5 november | `Azure - Data och identitet.pptx`, `Labbar\Kvall3`, `CustomersApi` |
| 4 | Angular och CI/CD | onsdag 11 november | skelett-deck |
| 5 | Service Bus och Functions | torsdag 12 november | skelett-deck |
| 6 | Byggfeedback: webhook till lampa | onsdag 18 november | skelett-deck |
| 7 | Ingest, idempotens och realtid | torsdag 19 november | skelett-deck |
| 8 | Telemetri och helheten | onsdag 25 november | skelett-deck |

Torsdag 26 november är buffert om något behöver tas om.

## 2. Idé och röd tråd

En enda lösning växer under kursen. Varje kväll lägger till ett lager. Rutorna med (färdig) är sidospår som instruktören kopplar in.

```
Sensor (ESP32-S3, färdig)  ──HTTPS──>  Function (ingest) ──> Service Bus topic "telemetry"
 eller sensorsimulator                                              │
                          Function (Service Bus trigger) <──────────┘
                                   │
                               Azure SQL <── API (App Service) <── Angular (Static Web Apps)
                                                                       ▲
                                                            SignalR Service (realtid)

Azure DevOps pipeline ──Service Hook──> Function ──> Service Bus topic "build-events"
                                                          ├─ subscription "lamp-red"  -> Raspberry Pi (färdig Worker Service, GPIO)
                                                          └─ subscription "audit"     -> loggning

Allt rapporterar via OpenTelemetry till Application Insights (och Aspire Dashboard lokalt).
```

Principer genom hela kursen:

- **Lokalt först, moln för "aha"-ögonblicket.** Samma tänk som med k3d.
- **Bicep från dag ett.** Portalen används för att titta, inte för att bygga.
- **Ingen hemlighet i konfigurationen.** Managed Identity och RBAC där det går. Key Vault där det behövs.
- **Allt kan rivas.** En resource group per labb/kväll. Nedrivning är en del av varje kväll.
- **Samma instrumentering som i Kubernetes-kursen.** OpenTelemetry, bara annan backend.
- **Samma exempel som i Kubernetes-kursen.** `Customer`-API:t (från `TelemetryApi`) går mot Azure SQL i stället för MySQL.

## 3. Omfattning och avgränsningar

- **Deltagarna bygger Azure-sidan:** webbapp, databas, identitet, Key Vault, pipeline, Service Bus, Functions, Static Web Apps och telemetri.
- **ESP32-S3 med BME280 är färdig.** Instruktören pekar ut mottagaren (ingest-Function) och visar en riktig enhet som demo (ca 10 min, kväll 7). Ingen firmware genomgås. Deltagarna kör en **sensorsimulator** (färdig).
- **Raspberry Pi är färdig:** en .NET Worker Service (BackgroundService) som prenumererar på Service Bus och tänder lampor via GPIO. Instruktören visar den och kopplar in den på en subscription. Deltagarna bygger den inte, men kan köra en färdig konsolvariant.
- Azure DevOps körs i instruktörens egen organisation. Hur deltagare och agenter sätts upp sköter instruktören bakom kulisserna och är inget kursmoment.
- Certifieringar ligger utanför planen.

## 4. Standardupplägg per kväll (180 min)

| Tid | Moment |
|---|---|
| 0–15 | Återkoppling, status, frågor |
| 15–60 | Teori och live-demo |
| 60–70 | Paus |
| 70–160 | Labb |
| 160–180 | Summering, nedrivning, kostnadskoll |

## 5. Verktygslista (gratis) att installera före kurs

Samma miljö som i Kubernetes-kursen: Windows och PowerShell 7.

- Azure CLI, Bicep (VS Code-tillägg)
- VS Code med Azure-tillägg, C# Dev Kit, mssql-tillägg (eller SSMS, eller `winget install sqlcmd`)
- .NET SDK 10, `dotnet tool install --global dotnet-ef`, Node + Angular CLI
- Docker Desktop (Azurite, Service Bus-emulator, Aspire Dashboard)
- Azure Functions Core Tools
- Service Bus Explorer (portalens inbyggda + [fristående](https://github.com/paolosalvatori/ServiceBusExplorer))
- Azure Storage Explorer
- Bruno eller VS Code REST Client (`.http`-filer)
- Dev Tunnels (`devtunnel`) och webhook.site (kväll 6)

## 6. Mappstruktur (speglar Kubernetes-mappen)

```
D:\Kvällskurs\Azure\
  Kursplan.md
  Azure - <tema>.pptx            en deck per kväll
  SimpleApi\                     Enkelt API för kväll 2 (App Service, App Settings)
  CustomersApi\                  Customer-API mot Azure SQL (kväll 3, byggs vidare)
  Infra\modules\                 Bicep-moduler som växer varje kväll
  Labbar\Kvall2 ... Kvall8\      README.md + numrerade filer, som Kubernetes\Labbar
```

I Kubernetes-kursen hölls alla kommandon i presentationen, och `Labbar\KvallN` innehöll README och facit-filer. Azure-kursen gör likadant.

---

## Kväll 1 – Certifieringar (genomförd)

Hela kvällen ägnades åt Azure-certifieringar med kollegans eget material och övningsfrågor. Ingen koppling till labbspåret och inget att förbereda.

---

## Kväll 2 – Grunder, Bicep och kostnad (onsdag 4 november)

**Mål:** Förstå Azures modell, kunna skapa, ändra och riva resurser reproducerbart med Bicep, ha kostnadskontroll från start och ha ett första API i molnet.

**Teori/demo (ca 60 min):** tenant, subscription, resource group, resource. Azure Resource Manager, region, SKU och kvot. Portal vs CLI vs Bicep (jämförelse med YAML och `kubectl apply`), `what-if`. Cost Management: budget, alerts, Cost Analysis, taggar, gratisnivåer. App Service: plan vs app, App Settings (`__` blir `:`), Kudu, log stream.

**Labb (`Labbar\Kvall2`, koden i `SimpleApi`)**
1. `az login` och kontroll av verktyg och runtime.
2. `01-budget.ps1`: budget med alert på prenumerationsnivå (`budget.bicep`, `targetScope = 'subscription'`).
3. `02-deploy.ps1`: resource group med taggar, App Service Plan (F1) och Web App med Bicep (`-Location`, `-WhatIf`).
4. `03-publish.ps1`: publicera SimpleApi (`/info`, `/healthz`, `/weatherforecast`).
5. Titta runt: log stream, ändra App Setting, Kudu.
6. `what-if` och ändra hälsningen via Bicep.
7. `99-cleanup.ps1`: riv ned (budgeten ligger kvar).

**Bicep-moduler:** `appservice.bicep`, `budget.bicep`
**Kostnad:** F1 är gratis. Budgeten varnar men stoppar inget.

**Obs:** gamla datafiler i `Labbar\Kvall2` (`00-start.ps1`, `01-publish.ps1`, `02-create-app-user.ps1/.sql`, `03-keyvault.ps1`) är ersatta med stubbar som pekar till `Kvall3` och kan raderas.

---

## Kväll 3 – Data och identitet (torsdag 5 november)

**Mål:** Koppla ett API till Azure SQL utan lösenord i konfigurationen, och förstå Managed Identity, RBAC och Key Vault.

**Teori/demo (45 min)**
- Från MySQL i klustret till Azure SQL: samma databasidé, annat ansvar.
- Logisk server och databas. Serverless och gratiserbjudandet (se "Verifierat" nedan). Brandvägg. Endast Entra-inloggning.
- EF Core-migreringar: schemat som kod. Utvecklaren kör migreringen, appen får bara läsa och skriva.
- Managed Identity (system- vs user-assigned). Azure RBAC är något annat än SQL-behörigheter.
- `Authentication=Active Directory Default`: samma connection string lokalt (`az login`) och i Azure (Managed Identity).
- Key Vault: vad som ersätts av identitet och vad som blir kvar. RBAC-roller. Key Vault-referenser i App Settings.

**Labb (90 min)** – allt i `Labbar\Kvall3`, koden i `CustomersApi`
1. `00-start.ps1`: resource group, Bicep (App Service med identitet, Azure SQL endast Entra, Key Vault med RBAC).
2. Lokalt mot Azure SQL: `dotnet ef migrations add` och `database update`, `dotnet run`, anropa API:t.
3. `01-publish.ps1`: publicera och se anropet **misslyckas** (`Login failed for user '<token-identified principal>'`).
4. `02-create-app-user.ps1`: contained user och roller åt webbappens identitet. Anropet fungerar, `/db/whoami` visar identiteten.
5. Key Vault: hemlighet, Key Vault-referens, se `/config` säga "ej upplöst", ge rollen *Key Vault Secrets User*, se den bli "upplöst".
6. `99-cleanup.ps1`: riv ned och rensa (purge) Key Vault.

**Verktyg:** Azure CLI, Bicep, VS Code mssql/SSMS/sqlcmd, dotnet-ef.
**Bicep-moduler:** `appservice.bicep`, `sql.bicep`, `keyvault.bicep`
**Kostnad:** SQL på gratiserbjudande, App Service F1, Key Vault med minimal driftkostnad.

---

## Kväll 4 – Angular och CI/CD

**Mål:** Angular-klient i Azure och en fungerande Azure DevOps-pipeline.

**Teori/demo:** Static Web Apps, CORS, runtime-konfiguration (jämför nginx i Kubernetes). Azure DevOps: projekt, repo, YAML-pipeline, stages, variabler. Service connection med workload identity federation.

**Labb:** Angular-klient (utgå från `CustomerClient`) mot API:t. Publicera till Static Web Apps. Pipeline som bygger, testar och deployar API och klient. Bryt bygget med flit.

**Verktyg:** Azure DevOps, Bruno/REST Client, Static Web Apps CLI.
**Bicep-moduler:** `staticwebapp.bicep`

---

## Kväll 5 – Service Bus och Functions

**Mål:** Förstå asynkron meddelandehantering på riktigt: leverans, fel, dead-letter. Skriva en Function som konsumerar.

**Teori/demo:** queue vs topic/subscription, filterregler, peek-lock, dead-letter, duplicate detection, sessions (kort). Functions: isolated worker, triggers/bindings, identitetsbaserad anslutning. **Service Bus Explorer** (portal + fristående). Jämförelse med NATS från Kubernetes-kursen.

**Labb:** emulator och Azurite lokalt. API publicerar, Function konsumerar. Poison message till dead-letter och omsändning via Explorer. Duplicate detection. Deploy till molnet.

**Verktyg:** Service Bus Explorer, Functions Core Tools, Azurite, emulator.
**Bicep-moduler:** `servicebus.bicep`, `functionapp.bicep`
**Kostnad:** Service Bus Standard har fast avgift, så skapa kvällen den behövs och riv direkt efter.

---

## Kväll 6 – Byggfeedback: webhook till lampa

**Mål:** Koppla ihop pipelinen från kväll 4 med Service Bus från kväll 5. Fokus ligger på Azure-sidan: Service Hook, Function, topic och subscriptions.

**Teori/demo:** Service Hooks (webhook eller direkt till Service Bus). Webhook-säkerhet. Meddelandekontrakt (`BuildEvent`). Pub/sub: flera subscriptions, filterregel `result = 'failed'`. Least privilege med SAS (Listen) eller identitet.

**Labb (deltagarna):**
1. Fånga payload med webhook.site och Dev Tunnels mot lokal Function.
2. Function `buildhook`: validera och publicera `BuildEvent` till topic `build-events`.
3. Service Hook i Azure DevOps, använd Test-knappen.
4. Subscription med filterregel.
5. Titta på flödet i Service Bus Explorer, injicera fejkade meddelanden.
6. Koppla på den **färdiga konsumenten** (konsolvariant) och bryt pipelinen.

**Sidospår (instruktören, färdig):** Raspberry Pi med .NET Worker Service som prenumererar och tänder röd/grön lampa. Visa att flera prenumeranter kan lyssna samtidigt. Reservplan: injicera ett fejkat meddelande via Explorer.

**Verktyg:** webhook.site, Dev Tunnels, Service Bus Explorer.
**Bicep-moduler:** utökar `servicebus.bicep`, `buildhook`-Function

---

## Kväll 7 – Ingest, idempotens och realtid

**Mål:** Ett robust flöde från mätvärde till graf. Hantera dubbletter, felaktig data och ordning.

**Teori/demo:** ingest-API (enhetsnyckel, validering, 202 Accepted), idempotent konsument (unik nyckel, MERGE, duplicate detection), ordning och sessions, SignalR Service för push till Angular.

**Labb (deltagarna):**
1. Function `ingest` (HTTP POST) publicerar till topic `telemetry`.
2. Function `telemetry-consumer` skriver idempotent till SQL.
3. Sensorsimulator med felinjektion: dubbletter, utebliven data, ogiltiga värden, omkastad ordning.
4. API-endpoints för historik och senaste värde.
5. SignalR och live-graf i Angular.
6. Följ flödet i Service Bus Explorer.

**Sidospår (instruktören, färdig):** ESP32-S3 med BME280 skickar riktiga mätvärden till samma ingest-endpoint (ca 10 min). Instruktören pekar bara ut mottagaren. Ingen firmware genomgås.

**Bicep-moduler:** `signalr.bicep`, uppdaterad `functionapp.bicep`

---

## Kväll 8 – Telemetri och helheten (onsdag 25 november)

**Mål:** Se hela kedjan i en trace, sätta ihop allt som Bicep, förstå åtkomst och kostnad och veta vad som skiljer labbmiljön från produktion. Kvällen är hård att få plats: dela den i två block (telemetri ca 90 min, helheten ca 60 min) och flytta över till buffertkvällen 26 november vid behov.

**Block 1 – Telemetri (Kubernetes-igenkänning)**
- Vad motsvarar vad (Tempo, Loki, Prometheus, Grafana, Faro → Application Insights, Log Analytics, Azure Monitor, Workbooks, JS-SDK). `Azure.Monitor.OpenTelemetry`. Korrelation över Service Bus (`traceparent`). KQL-grunder. Sampling och kostnad. Aspire Dashboard lokalt.
- Labb: OTLP lokalt, byt exportör till Azure Monitor, end-to-end-trace, Application Map, KQL, alert på dead-letter, dagligt tak.

**Block 2 – Helheten**
- Hela miljön som Bicep: sätt ihop modulerna från kväll 2–7 i `main.bicep`, `what-if`, infra-stage i pipeline.
- Identitetstabell över alla identiteter (API, Functions, pipeline, Pi), RBAC, minsta behörighet.
- Kostnad: Cost Analysis, vad kostade kursen?
- Från labb till produktion (diskussion): private endpoints, slots, Front Door, Premium Service Bus, policy, Defender, backup/DR. Container Apps och AKS som koppling till k3d.
- Slutdemo: sensor till lampa. Nedrivning av allt.
- Entra ID för Angular och API (MSAL) tas som demo eller bonus om tid finns.

**Bicep-moduler:** `monitoring.bicep` (Log Analytics + App Insights + alerts), sammansatt `main.bicep`

---

## 7. Verifierat och att verifiera

**Verifierat mot Microsoft Learn (4 november):**
- Azure SQL gratiserbjudande: 100 000 vCore-sekunder, 32 GB data och 32 GB backup per månad. Upp till 10 gratisdatabaser per prenumeration. Pausar efter 15 minuter utan aktivitet (fast). Efter slutet av gränsen: `AutoPause` (otillgänglig tills nästa månad) eller `BillOverUsage`. Öppna anslutningar hindrar paus. Inget SLA. Stöds inte på Azure for Students Starter.
- Key Vault-referenser: `@Microsoft.KeyVault(VaultName=...;SecretName=...)` eller `SecretUri=...`. Appens identitet behöver rollen *Key Vault Secrets User*. Löses inte referensen får appen råtexten som värde. Värden cachas 24 timmar, och en ändring av konfigurationen startar om appen och hämtar om allt.
- Bicep-mallarna för kväll 2 och 3 är byggda och validerade med Bicep CLI 0.48.1.

**Att verifiera före respektive kväll:**
- C#-koden i `CustomersApi` och `SimpleApi` har inte kompilerats i den miljö där de skrevs. Kör `dotnet build` på båda före användning.
- Att F1-kvoten och runtime `DOTNETCORE|10.0` finns i vald region (`az webapp list-runtimes --os linux`).
- Service Bus: prisnivåer, fast avgift för Standard, emulatorns stöd för topics och dess begränsningar.
- Functions: vilken hostingplan som är rekommenderad idag och dess gratisgrant.
- SignalR Service gratisnivå: gränser för anslutningar och meddelanden.
- Att fristående Service Bus Explorer fortfarande underhålls, och att SDK:ns tracing mot Service Bus fungerar utan extra flaggor.
- Deltagarnas rättigheter i sin tenant (app registrations, service connections).

## 8. Risker och motmedel

| Risk | Motmedel |
|---|---|
| Kostnadsöverraskningar | Budget-alert som första labb. Resource group per kväll. Nedrivning varje kväll. Dagligt tak i Log Analytics. |
| Key Vault blockerar namnet efter nedrivning | `99-cleanup.ps1` kör `az keyvault purge`. |
| Deltagare hamnar efter | Startskript per kväll som skapar allt som behövs. |
| Nätverk/brandvägg på Pi eller i lokalen | Konsolvariant av konsumenten. Reservplan med fejkade meddelanden via Explorer. |
| Behörighetsproblem i deltagarnas tenant | Egen prenumeration/tenant för kursen. |
| Tung kväll 5–7 | Förbered färdiga delar (compose-fil, simulator, Angular-graf), så att tiden går till förståelse och inte felsökning. |
| Kvällar dag efter dag | Inget hemarbete mellan onsdag och torsdag. Bygg in allt i labbtiden. |
