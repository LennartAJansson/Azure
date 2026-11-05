// =============================================================================
// Key Vault - RBAC-styrt. Den som kör labben får Secrets Officer (kan skapa
// hemligheter). Appens identitet får INTE någon roll här - det gör ni i labben.
// =============================================================================
param location string
param name string
param tags object = {}

@description('objectId för den som ska kunna skapa hemligheter.')
param officerObjectId string

// Inbyggd roll: Key Vault Secrets Officer
var secretsOfficerRoleId = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    tenantId: tenant().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    publicNetworkAccess: 'Enabled'
  }
}

resource officer 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: kv
  name: guid(kv.id, officerObjectId, secretsOfficerRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', secretsOfficerRoleId)
    principalId: officerObjectId
    principalType: 'User'
  }
}

output name string = kv.name
output id string = kv.id
output uri string = kv.properties.vaultUri
