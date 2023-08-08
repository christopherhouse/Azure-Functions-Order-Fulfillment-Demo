param containerName string
param databaseName string
param cosmosAccountName string
param partitionKey string
param maxRUs int

resource acct 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosAccountName
  scope: resourceGroup()
}

resource db 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' existing = {
  name: databaseName
  parent: acct
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  name: containerName
  parent: db
  properties: {
    options: {
      autoscaleSettings: {
        maxThroughput: maxRUs
      }
    }
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          partitionKey
        ]
        kind: 'Hash'
      }
    }
  }
}
