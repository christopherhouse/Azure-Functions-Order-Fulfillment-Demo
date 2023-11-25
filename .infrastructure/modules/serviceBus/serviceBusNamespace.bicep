param serviceBusNamespaceName string
param location string
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param serviceBusSku string
param tags object

resource sbns 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: serviceBusSku
  }
  tags: tags
}

// resource diags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: sbns.name
//   scope: sbns
//   properties: {
//     workspaceId: laws.id
//     logs: [
//       {
//         categoryGroup: 'allLogs'
//         enabled: true
//         retentionPolicy: {
//           enabled: true
//           days: 30
//         }
//       }
//     ]
//   }
// }

output id string = sbns.id
output name string = sbns.name
