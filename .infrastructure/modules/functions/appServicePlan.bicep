param appServicePlanName string
param location string

resource asp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: 'Y1'
    capacity: 1
  }
  properties: {
    reserved: true // Required for Linux plans
  }
}

output id string = asp.id
output name string = asp.name
