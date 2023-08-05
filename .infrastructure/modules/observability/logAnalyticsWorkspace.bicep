param logAnalyticsWorkspaceName string
param location string

resource laws 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    retentionInDays: 15
    sku: {
      name: 'PerGB2018'
    }
  }
}

output id string = laws.id
output name string = laws.name
