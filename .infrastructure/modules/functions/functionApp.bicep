param functionAppName string
param location string
param appServicePlanId string
param managedIdentityResourceId string
param storageAccountName string
param appInsightsInstrumentationkeySecretUri string
param cosmosDbConnectionStringSecretUri string
param tags object
param ordersTopicName string
param serviceBusConnectionStringSecretUri string
param ordersContainerName string
param cosmosDbName string
param fulfillmentTopic string
param approvedOrdersSubscription string
param maxWorkDelayInMilliseconds int
param cosmosLeaseContainerName string
param logAnalyticsWorkspaceName string

resource laws 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup()
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
  scope: resourceGroup()
}

resource app 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityResourceId}': {}
    }
  }
  tags: tags
  properties: {
    keyVaultReferenceIdentity: managedIdentityResourceId
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNET|6.0'
      appSettings: [
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccountName
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'AzureWebJobsStorage'
          // GitHub CoPilot prompt to set the value of the connection string, since I can never remember :D
          // Set the value below to the primary connection string for the storage account referenced by the variable 'storage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storage.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: '@Microsoft.KeyVault(SecretUri=${appInsightsInstrumentationkeySecretUri})'
        }
        {
          name: 'COSMOS_CONNECTION_STRING'
          value: '@Microsoft.KeyVault(SecretUri=${cosmosDbConnectionStringSecretUri})'
        }
        {
          name: 'ordersTopicName'
          value: ordersTopicName
        }
        {
          name: 'serviceBusConnectionString'
          value: '@Microsoft.KeyVault(SecretUri=${serviceBusConnectionStringSecretUri})'
        }
        {
          name: 'cosmosDbName'
          value: cosmosDbName
        }
        {
          name: 'ordersContainerName'
          value: ordersContainerName
        }
        {
          name: 'fulfillmentTopic'
          value: fulfillmentTopic
        }
        {
          name: 'approvedOrdersSubscription'
          value: approvedOrdersSubscription
        }
        {
          name: 'maxWorkDelayInMilliseconds'
          value: string(maxWorkDelayInMilliseconds)
        }
        {
          name: 'cosmosLeaseContainerName'
          value: cosmosLeaseContainerName
        }
      ]
    }
  }
}

resource diags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: app
  name: 'laws'
  properties: {
    workspaceId: laws.id
    logs: [
      {
        category: 'functionApplicationLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

output id string = app.id
output name string = app.name
