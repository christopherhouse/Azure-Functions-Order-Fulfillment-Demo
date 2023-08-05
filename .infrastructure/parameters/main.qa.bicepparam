using '../main.bicep'

param workloadPrefix = 'cmh'
param workloadName = 'ordering'
param environmentName = 'qa'
param location = 'eastus'
param serviceBusSku = 'Standard'
param maxTopicSize = 2048
param ordersTopicName = 'received-orders'
param ordersTopicSubscriptionName = 'auto-approved-orders'
param ordersForApprovalSubscriptionName = 'orders-requiring-approval'
param ordersTopicSqlFilter = 'user.orderTotal <= 1000'
param ordersForApprovalSqlFilter = 'user.orderTotal >= 1000'
param fulfillmentTopicName = 'orders-for-fulfillment'
param keyVaultAdminIdentities = ['c9be89aa-0783-4310-b73a-f81f4c3f5407']
