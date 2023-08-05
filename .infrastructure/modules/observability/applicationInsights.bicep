param appInsightsName string
param location string
param logAnalyticsWorkspaceId string
param tags object

resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

output id string = ai.id
output name string = ai.name
