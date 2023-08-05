param deploymentDate string = utcNow()
param workloadPrefix string
param workloadName string
param environmentName string
param location string
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param serviceBusSku string
param maxTopicSize int
param ordersTopicName string
param ordersTopicSubscriptionName string
param ordersForApprovalSubscriptionName string
param ordersTopicSqlFilter string
param ordersForApprovalSqlFilter string
param fulfillmentTopicName string
param keyVaultAdminIdentities array = []
param cosmosDbDatabaseName string
param ordersCosmosContainerName string
param orderContainerPartitionKey string

param buildId int = 0

var baseName = '${workloadPrefix}-${workloadName}-${environmentName}'
var baseNameNoDashes = replace(baseName, '-', '')

// Resource Names
var serviceBusNamespaceName = '${baseName}-sbns'
var logAnalyticsWorkspaceName = '${baseName}-laws'
var functionsAppInsightsName = '${baseName}-func-ai'
var keyVaultName = '${baseName}-kv'
var storageAccountName = length('${baseNameNoDashes}sa') > 24 ? toLower(substring('${baseNameNoDashes}sa', 0, 24)) : toLower('${baseNameNoDashes}sa')
var functionAppServicePlanName = '${baseName}-func-asp'
var functionAppName = '${baseName}-func'
var functionAppUserAssignedIdentityName = '${functionAppName}-uami'
var cosmosDbAccountName = '${baseName}-cdb-acct'

// Deployment Names
var serviceBusDeploymentName = '${serviceBusNamespaceName}-${buildId}'
var ordersTopicDeploymentName= '${ordersTopicName}-${buildId}'
var fulfillmentTopicDeploymentName = '${fulfillmentTopicName}-${buildId}'
var logAnalyticsDeploymentName = '${logAnalyticsWorkspaceName}-${buildId}'
var functionsAppInsightsDeploymentName = '${functionsAppInsightsName}-${buildId}'
var keyVaultDeploymentName = '${keyVaultName}-${buildId}'
var storageAccountDeploymentName = '${storageAccountName}-${buildId}'
var functionAppServicePlanDeploymentName = '${functionAppServicePlanName}-${buildId}'
var functionAppDeploymentName = '${functionAppName}-${buildId}'
var functionAppUserAssignedIdentityDeploymentName = '${functionAppUserAssignedIdentityName}-${buildId}'
var secretsDeploymentName = 'secrets-${buildId}'
var cosmosDbAccountDeploymentName = '${cosmosDbAccountName}-${buildId}'
var cosmosDbDatabaseDeploymentName = '${cosmosDbDatabaseName}-${buildId}'
var orderContainerDeploymentName = '${ordersCosmosContainerName}-${buildId}'

var tags = {
  BuildId: buildId
  Environment: environmentName
  Workload: workloadName
  LastDeploymentDate: deploymentDate
}

module sbNs './modules/serviceBus/serviceBusNamespace.bicep' = {
  name: serviceBusDeploymentName
  params: {
    serviceBusNamespaceName: serviceBusNamespaceName
    location: location
    serviceBusSku: serviceBusSku
    tags: tags
  }
}

module autoApprovedOrdersTopic './modules/serviceBus/serviceBusTopic.bicep' = {
  name: ordersTopicDeploymentName
  params: {
    serviceBusNamespaceName: sbNs.outputs.name
    topicName: ordersTopicName
    maxTopicSize: maxTopicSize
  }
}

module ordersSubscription './modules/serviceBus/serviceBusTopicSubscription.bicep' = {
  name: '${ordersTopicSubscriptionName}-${buildId}'
  params: {
    serviceBusNamespaceName: sbNs.outputs.name
    topicName: autoApprovedOrdersTopic.outputs.name
    subscriptionName: ordersTopicSubscriptionName
    sqlFilterExpression: ordersTopicSqlFilter
    forwardToTopicName: fulfillmentTopic.outputs.name
  }
}

module ordersForApprovalSubscription './modules/serviceBus/serviceBusTopicSubscription.bicep' = {
  name: '${ordersForApprovalSubscriptionName}-subscription-${buildId}'
  params: {
    serviceBusNamespaceName: sbNs.outputs.name
    topicName: autoApprovedOrdersTopic.outputs.name
    subscriptionName: ordersForApprovalSubscriptionName
    sqlFilterExpression: ordersForApprovalSqlFilter
  }
}

module fulfillmentTopic './modules/serviceBus/serviceBusTopic.bicep' = {
  name: fulfillmentTopicDeploymentName
  params: {
    serviceBusNamespaceName: sbNs.outputs.name
    topicName: fulfillmentTopicName
    maxTopicSize: maxTopicSize
  }
}

module laws './modules/observability/logAnalyticsWorkspace.bicep' = {
  name: logAnalyticsDeploymentName
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    location: location
    tags: tags
  }
}

module funcAppInsights './modules/observability/applicationInsights.bicep' = {
  name: functionsAppInsightsDeploymentName
  params: {
    appInsightsName: functionsAppInsightsName
    location: location
    logAnalyticsWorkspaceId: laws.outputs.id
    tags: tags
  }
}

module kv './modules/keyVault/keyVault.bicep' = {
  name: keyVaultDeploymentName
  params: {
    keyVaultName: keyVaultName
    location: location
    adminIdentities: keyVaultAdminIdentities
    applicationIdentities: [ funcUami.outputs.principalId ]
    tags: tags
  }
}

module funcStorage './modules/storageAccount.bicep' = {
  name: storageAccountDeploymentName
  params: {
    storageAccountName: storageAccountName
    location: location
    tags: tags
  }
}

module funcUami './modules/userAssignedManagedIdentity.bicep' = {
  name: functionAppUserAssignedIdentityDeploymentName
  params: {
    managedIdentityName: functionAppUserAssignedIdentityName
    location: location
    tags: tags
  }
}

module funcAsp './modules/functions/appServicePlan.bicep' = {
  name: functionAppServicePlanDeploymentName
  params: {
    appServicePlanName: functionAppServicePlanName
    location: location
    tags: tags
  }
}

module funcApp './modules/functions/functionApp.bicep' = {
  name: functionAppDeploymentName
  params: {
    location: location
    appServicePlanId: funcAsp.outputs.name
    functionAppName: functionAppName
    managedIdentityResourceId: funcUami.outputs.id
    storageAccountName: funcStorage.outputs.name
    appInsightsInstrumentationkeySecretUri: secrets.outputs.appInsightsInstrumentationkeyUri
    tags: tags
  }
}

module secrets './modules/keyVault/secrets.bicep' = {
  name: secretsDeploymentName
  params: {
    appInsightsName: funcAppInsights.outputs.name
    buildId: buildId
    keyVaultName: kv.outputs.name
    cosmosDbAccountName: cosmosAccount.outputs.name
  }
}

module cosmosAccount './modules/cosmos/cosmosAccount.bicep' = {
  name: cosmosDbAccountDeploymentName
  params: {
    location: location
    cosmosAccountName: cosmosDbAccountName
  }
}

module cosmosDb './modules/cosmos//cosmosDbDatabase.bicep' = {
  name: cosmosDbDatabaseDeploymentName
  params: {
    cosmosAccountName: cosmosAccount.outputs.name
    databaseName: cosmosDbDatabaseName
  }
}

module ordersContainer './modules/cosmos/cosmosContainer.bicep' = {
  name: orderContainerDeploymentName
  params: {
    containerName: ordersCosmosContainerName
    cosmosAccountName: cosmosAccount.outputs.name
    databaseName: cosmosDb.outputs.name
    partitionKey: orderContainerPartitionKey
  }
}

output functionAppName string = funcApp.outputs.name
