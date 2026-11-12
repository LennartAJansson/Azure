// =============================================================================
// App Service - plan + webbapp med systemtilldelad Managed Identity.
// Kopia från Infra\modules för kväll 4, med tillägget corsOrigins.
// =============================================================================
param location string
param planName string
param appName string
param tags object = {}

@description('Gratisnivån F1 räcker för labbarna. Byt till B1 om F1-kvoten är slut i regionen.')
param skuName string = 'F1'

@description('Kontrollera tillgängliga värden med: az webapp list-runtimes --os linux')
param linuxFxVersion string = 'DOTNETCORE|10.0'

@description('Lista med { name, value } som blir App Settings.')
param appSettings array = []

@description('Origins som får anropa API:t från webbläsaren (CORS), t.ex. https://<swa-hostname>. Tom lista = ingen CORS.')
param corsOrigins array = []

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: planName
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: skuName
  }
  properties: {
    reserved: true // Linux
  }
}

resource app 'Microsoft.Web/sites@2023-12-01' = {
  name: appName
  location: location
  tags: tags
  kind: 'app,linux'
  // Systemtilldelad identitet: skapas och tas bort tillsammans med appen.
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      appSettings: appSettings
      cors: {
        allowedOrigins: corsOrigins
        supportCredentials: false
      }
    }
  }
}

output appName string = app.name
output defaultHostName string = app.properties.defaultHostName
output principalId string = app.identity.principalId
