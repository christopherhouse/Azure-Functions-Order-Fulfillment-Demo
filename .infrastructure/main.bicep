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

param buildId int = 0

var baseName = '${workloadPrefix}-${workloadName}-${environmentName}'

var serviceBusNamespaceName = '${baseName}-sbns'

var serviceBusDeploymentName = '${serviceBusNamespaceName}-${buildId}'
var ordersTopicDeploymentName= '${ordersTopicName}-${buildId}'
var fulfillmentTopicDeploymentName= '${fulfillmentTopicName}-${buildId}'

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
