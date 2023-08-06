param keyVaultName string
param location string
param adminIdentities array
param applicationIdentities array
param logAnalyticsWorkspaceName string
param tags object

resource laws 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup()
}

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

resource diags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: kv
  name: 'laws'
  properties: {
    workspaceId: laws.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

output id string = kv.id
output name string = kv.name
