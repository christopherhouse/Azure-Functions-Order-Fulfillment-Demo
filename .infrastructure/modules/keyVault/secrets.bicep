param keyVaultName string
param appInsightsName string
param cosmosDbAccountName string
param serviceBusNamespaceId string
param buildId int

var serviceBus = '${serviceBusNamespaceId}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusConnectionString = listKeys(serviceBus, '2022-10-01-preview').primaryConnectionString

resource ai 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
  scope: resourceGroup()
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosDbAccountName
  scope: resourceGroup()
}

module aiKeySecret './keyVaultSecret.bicep' = {
  name: 'aiKeySecret-${buildId}'
  params: {
    keyVaultName: keyVaultName
    secretName: 'AppInsightsInstrumentationKey'
    secretValue: ai.properties.InstrumentationKey
  }
}

module aiConnStringSecret './keyVaultSecret.bicep' = {
  name: 'aiConnStringSecret-${buildId}'
  params: {
    keyVaultName: keyVaultName
    secretName: 'AppInsightsConnectionString'
    secretValue: ai.properties.ConnectionString
  }
}

module cosmosDbConnStringSecret './keyVaultSecret.bicep' = {
  name: 'cosmosDbConnStringSecret-${buildId}'
  params: {
    keyVaultName: keyVaultName
    secretName: 'CosmosDbConnectionString'
    secretValue: cosmos.listConnectionStrings().connectionStrings[0].connectionString
  }
}

module sbConnStringSecret './keyVaultSecret.bicep' = {
  name: 'sbConnStringSecret-${buildId}'
  params: {
    keyVaultName: keyVaultName
    secretName: 'ServiceBusConnectionString'
    secretValue: serviceBusConnectionString
  }
}

output appInsightsInstrumentationkeyUri string = aiKeySecret.outputs.secretUri
output appInsightsConnectionStringUri string = aiConnStringSecret.outputs.secretUri
output cosmosDbConnectionStringUri string = cosmosDbConnStringSecret.outputs.secretUri
output serviceBusConnectionStringUri string = sbConnStringSecret.outputs.secretUri
