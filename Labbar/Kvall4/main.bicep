// =============================================================================
// Kväll 4 - Angular och CI/CD (kväll 3 + Static Web Apps + CORS)
//
//   az deployment group create -g rg-azure-kvall4 -f main.bicep -p main.bicepparam
//   (00-start.ps1 gör det åt er och skickar in parametrarna)
//
// Skapar: App Service (med Managed Identity), Azure SQL (endast Entra),
// Key Vault (RBAC) och Static Web Apps (Free). API:t släpper in SWA:ns origin (CORS). Namnen får ett unikt suffix - SQL-servrar, Key Vault och
// webbappar måste ha globalt unika namn.
// =============================================================================
targetScope = 'resourceGroup'

param location string = resourceGroup().location
param owner string

@description('Entra-användarens UPN (az ad signed-in-user show --query userPrincipalName)')
param adminLogin string
@description('Entra-användarens objectId (az ad signed-in-user show --query id)')
param adminObjectId string
@description('Din publika IP för SQL-brandväggen')
param clientIp string
param useFreeOffer bool = true
@description('Static Web Apps Free finns inte i alla regioner (swedencentral saknas).')
param swaLocation string = 'westeurope'

var suffix = uniqueString(resourceGroup().id)
var tags = {
  owner: owner
  course: 'azure-kvallskurs'
  kvall: '4'
}

var sqlName = 'sql-azkurs-${suffix}'
var dbName = 'customers'
var appName = 'app-azkurs-${suffix}'
var kvName = 'kv-azkurs-${suffix}'
var swaName = 'swa-azkurs-${suffix}'

module sql './modules/sql.bicep' = {
  name: 'sql'
  params: {
    location: location
    serverName: sqlName
    dbName: dbName
    tags: tags
    adminLogin: adminLogin
    adminObjectId: adminObjectId
    clientIp: clientIp
    useFreeOffer: useFreeOffer
  }
}

module kv './modules/keyvault.bicep' = {
  name: 'kv'
  params: {
    location: location
    name: kvName
    tags: tags
    officerObjectId: adminObjectId
  }
}

module swa './modules/staticwebapp.bicep' = {
  name: 'swa'
  params: {
    location: swaLocation
    name: swaName
    tags: tags
  }
}

module app './modules/appservice.bicep' = {
  name: 'app'
  params: {
    location: location
    planName: 'plan-azkurs'
    appName: appName
    tags: tags
    // CORS: bara den egna klienten. http://localhost:4200 läggs till för hand i labben (05-cors-local.ps1).
    corsOrigins: [
      'https://${swa.outputs.hostname}'
    ]
    appSettings: [
      {
        // Ingen användare, inget lösenord - identiteten avgör.
        name: 'ConnectionStrings__CustomersDb'
        value: 'Server=tcp:${sql.outputs.fqdn},1433;Database=${dbName};Authentication=Active Directory Default;Encrypt=True;Connection Timeout=60;'
      }
      {
        name: 'OpenApi__Enabled'
        value: 'true'
      }
    ]
  }
}

output appName string = app.outputs.appName
output appHost string = app.outputs.defaultHostName
output appPrincipalId string = app.outputs.principalId
output sqlServer string = sql.outputs.serverName
output sqlFqdn string = sql.outputs.fqdn
output dbName string = sql.outputs.dbName
output kvName string = kv.outputs.name
output kvId string = kv.outputs.id
output swaName string = swa.outputs.name
output swaHost string = swa.outputs.hostname
