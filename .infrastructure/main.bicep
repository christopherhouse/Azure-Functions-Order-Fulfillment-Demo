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

param buildId int = 0

// Temp variables (will not need when complete)
var keyVaultApplicationIdentities = []

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

module sbNs './modules/serviceBus/serviceBusNamespace.bicep' = {
  name: serviceBusDeploymentName
  params: {
    serviceBusNamespaceName: serviceBusNamespaceName
    location: location
    serviceBusSku: serviceBusSku
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
  }
}

module funcAppInsights './modules/observability/applicationInsights.bicep' = {
  name: functionsAppInsightsDeploymentName
  params: {
    appInsightsName: functionsAppInsightsName
    location: location
    logAnalyticsWorkspaceId: laws.outputs.id
  }
}

module kv './modules/keyVault.bicep' = {
  name: keyVaultDeploymentName
  params: {
    keyVaultName: keyVaultName
    location: location
    adminIdentities: keyVaultAdminIdentities
    applicationIdentities: keyVaultApplicationIdentities
  }
}

module funcStorage './modules/storageAccount.bicep' = {
  name: storageAccountDeploymentName
  params: {
    storageAccountName: storageAccountName
    location: location
  }
}

module funcUami './modules/userAssignedManagedIdentity.bicep' = {
  name: functionAppUserAssignedIdentityDeploymentName
  params: {
    managedIdentityName: functionAppUserAssignedIdentityName
    location: location
  }
}

module funcAsp './modules/functions/appServicePlan.bicep' = {
  name: functionAppServicePlanDeploymentName
  params: {
    appServicePlanName: functionAppServicePlanName
    location: location
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
  }
}
