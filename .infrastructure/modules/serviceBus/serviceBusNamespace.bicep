param serviceBusNamespaceName string
param location string
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param serviceBusSku string

resource sbns 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: serviceBusSku
  }
}

output id string = sbns.id
output name string = sbns.name
