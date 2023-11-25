param keyVaultName string
param location string
param adminIdentities array
param applicationIdentities array
param pipelineServicePrincipalId string
param tags object

var adminPolicies = [for id in adminIdentities: {
  tenantId: subscription().tenantId
  objectId: id
  permissions: {
    keys: ['all']
    secrets: ['all']
    certificates: ['all']
  }
}]

var appPolicies = [for id in applicationIdentities: {
  tenantId: subscription().tenantId
  objectId: id
  permissions: {
    secrets: [
      'Get'
      'List'
  ]
  }
}]

var pipelinePolicies = [{
  tenantId: subscription().tenantId
  objectId: pipelineServicePrincipalId
  permissions: {
    secrets: [ 
    'Set'
    'List'
  ]
  }
}]

var policies = union(adminPolicies, appPolicies, pipelinePolicies)

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: policies
    softDeleteRetentionInDays: 7
    enableRbacAuthorization: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

// CoPilot prompt:
// Create a diagnostic setting for the key vault to send the allLogs category to the Log Analytics workspace
// specified by the 'laws' variable
// resource diags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: 'laws'
//   scope: kv
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

output id string = kv.id
output name string = kv.name
