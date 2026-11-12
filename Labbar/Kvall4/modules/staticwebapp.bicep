// =============================================================================
// Static Web Apps (Free). Deployas med deployment token, ingen repo-koppling.
// Free finns bara i vissa regioner: westeurope, centralus, eastus2, eastasia, westus2.
// =============================================================================
param name string
param location string = 'westeurope'
param tags object = {}

resource swa 'Microsoft.Web/staticSites@2023-12-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {}
}

output name string = swa.name
output hostname string = swa.properties.defaultHostname
