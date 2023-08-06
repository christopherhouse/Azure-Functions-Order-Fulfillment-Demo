param location string = resourceGroup().location
param appPlanName string = '${uniqueString(resourceGroup().id)}asp'
param logAnalyticsWorkspace string = '${uniqueString(resourceGroup().id)}la'

var appPlanSkuName = 'S1'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsWorkspace
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appPlanName
  location: location
  sku: {
    name: appPlanSkuName
    capacity: 1
  } 
}

resource webApp 'Microsoft.Web/sites@2021-03-01' = {
  name: 'cmmywebapp'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: webApp.name
  scope: webApp
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true 
        }
      }
    ]
  }
}
