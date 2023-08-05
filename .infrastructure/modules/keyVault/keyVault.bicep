param keyVaultName string
param location string
param adminIdentities array
param applicationIdentities array


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
    secrets: ['Get'
      'List'
  ]
  }
}]

var policies = union(adminPolicies, appPolicies)

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: policies
    softDeleteRetentionInDays: 7
    enablePurgeProtection: true
    enableRbacAuthorization: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

output id string = kv.id
output name string = kv.name
