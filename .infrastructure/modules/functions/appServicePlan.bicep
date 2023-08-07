param appServicePlanName string
param location string
param tags object

resource asp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: 'Y1'
    capacity: 1
  }
  properties: {
  }
}

output id string = asp.id
output name string = asp.name
