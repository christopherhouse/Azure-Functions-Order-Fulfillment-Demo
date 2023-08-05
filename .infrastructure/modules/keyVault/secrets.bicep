param keyVaultName string
param appInsightsName string
param buildId int

resource ai 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
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

output appInsightsInstrumentationkeyUri string = aiKeySecret.outputs.secretUri
output appInsightsConnectionStringUri string = aiConnStringSecret.outputs.secretUri
