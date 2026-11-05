// =============================================================================
// Azure SQL - logisk server med ENDAST Entra-inloggning + en databas.
// Inget SQL-lösenord finns alls. Entra-admin är den som kör labben.
// =============================================================================
param location string
param serverName string
param dbName string = 'customers'
param tags object = {}

@description('Entra-administratörens inloggning (UPN), t.ex. från: az ad signed-in-user show --query userPrincipalName')
param adminLogin string

@description('Entra-administratörens objectId, från: az ad signed-in-user show --query id')
param adminObjectId string

@description('Din publika IP-adress - öppnar brandväggen för labb-datorn.')
param clientIp string

@description('Gratiserbjudandet: 100 000 vCore-sekunder och 32 GB per månad. Sätt false om prenumerationen inte kan använda det.')
param useFreeOffer bool = true

resource server 'Microsoft.Sql/servers@2023-08-01' = {
  name: serverName
  location: location
  tags: tags
  properties: {
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'User'
      login: adminLogin
      sid: adminObjectId
      tenantId: tenant().tenantId
      azureADOnlyAuthentication: true // inga SQL-lösenord
    }
  }
}

// Serverless General Purpose. Med gratiserbjudandet pausar databasen efter 15 min.
resource db 'Microsoft.Sql/servers/databases@2023-08-01' = {
  parent: server
  name: dbName
  location: location
  tags: tags
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 2
  }
  properties: {
    autoPauseDelay: useFreeOffer ? 15 : 60
    minCapacity: json('0.5')
    maxSizeBytes: 34359738368 // 32 GB
    requestedBackupStorageRedundancy: 'Local'
    useFreeLimit: useFreeOffer
    freeLimitExhaustionBehavior: useFreeOffer ? 'AutoPause' : null
  }
}

// 0.0.0.0 - 0.0.0.0 betyder "tillåt Azure-tjänster" (t.ex. vår App Service).
resource allowAzure 'Microsoft.Sql/servers/firewallRules@2023-08-01' = {
  parent: server
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource allowClient 'Microsoft.Sql/servers/firewallRules@2023-08-01' = {
  parent: server
  name: 'labb-dator'
  properties: {
    startIpAddress: clientIp
    endIpAddress: clientIp
  }
}

output serverName string = server.name
output fqdn string = server.properties.fullyQualifiedDomainName
output dbName string = db.name
