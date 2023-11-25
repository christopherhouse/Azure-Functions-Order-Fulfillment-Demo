param functionAppName string
param location string
param appServicePlanId string
param managedIdentityResourceId string
param storageAccountName string
param appInsightsInstrumentationkeySecretUri string
param appInsightsConnectionStringSecretUri string
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
param webHookNotificationUrl string
param functionAppKeyUri string
param ordersForApprovalSubscription string
param shipmentTopicName string
param shipmentTopicSubscriptionName string
param statusNotificationTopic string
param allStatusNotificationSubscription string
param sendApprovalTopic string
param allCreditApprovalsSubscription string

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
  scope: resourceGroup()
}

resource app 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
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
      appSettings: [
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(uniqueString(functionAppName))
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
          name: 'Application:Insights:ConnectionString'
          value: '@Microsoft.KeyVault(SecretUri=${appInsightsConnectionStringSecretUri})'
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
        {
          name: 'webHookNotificationUrl'
          value: webHookNotificationUrl
        }
        {
          name: 'eventUriFormatString'
          value: 'https://${functionAppName}.azurewebsites.net/runtime/webhooks/durabletask/instances/{0}/CreditApproved&code={1}'
        }
        {
          name: 'functionAppKey'
          value: '@Microsoft.KeyVault(SecretUri=${functionAppKeyUri})'
        }
        {
          name: 'functionAppBaseUrl'
          value: 'https://${functionAppName}.azurewebsites.net'
        }
        {
          name: 'ordersForApprovalSubscription'
          value: ordersForApprovalSubscription
        }
        {
          name: 'shipmentTopicName'
          value: shipmentTopicName
        }
        {
          name: 'shipmentTopicSubscriptionName'
          value: shipmentTopicSubscriptionName
        }
        {
          name: 'statusNotificationTopic'
          value: statusNotificationTopic
        }
        {
          name: 'allStatusNotificationSubscription'
          value: allStatusNotificationSubscription
        }
        {
          name: 'sendApprovalTopic'
          value: sendApprovalTopic
        }
        {
          name: 'allCreditApprovalsSubscription'
          value: allCreditApprovalsSubscription
        }
      ]
    }
  }
}

// For some reason this seems to insert an extra /providers/ segment when doing this inside a module, maybe?
// test.bicep deploys fine without a module

// resource diags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: app.name
//   scope: app
//   properties: {
//     workspaceId: laws.id
//     logs: [
//       {
//         category: 'functionApplicationLogs'
//         enabled: true
//         retentionPolicy: {
//           enabled: true
//           days: 30
//         }
//       }
//     ]
//   }
// }

output id string = app.id
output name string = app.name
