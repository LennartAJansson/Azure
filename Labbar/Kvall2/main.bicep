// =============================================================================
// Kväll 2 - Azure i praktiken
//
//   az deployment group create -g rg-azure-kvall2 -f main.bicep -p owner=<namn>
//   (02-deploy.ps1 gör det åt er)
//
// Skapar en App Service Plan (gratisnivå F1) och en webbapp. Namnen får ett
// unikt suffix - webbappar måste ha globalt unika namn.
// =============================================================================
targetScope = 'resourceGroup'

param location string = resourceGroup().location
param owner string

@description('Hälsningen som SimpleApi visar på /info. Ändra den och kör what-if.')
param greeting string = 'Hej från Azure'

var suffix = uniqueString(resourceGroup().id)
var tags = {
  owner: owner
  course: 'azure-kvallskurs'
  kvall: '2'
}

module app '../../Infra/modules/appservice.bicep' = {
  name: 'app'
  params: {
    location: location
    planName: 'plan-azkurs'
    appName: 'app-azkurs-${suffix}'
    tags: tags
    appSettings: [
      {
        name: 'Hello__Greeting'
        value: greeting
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
