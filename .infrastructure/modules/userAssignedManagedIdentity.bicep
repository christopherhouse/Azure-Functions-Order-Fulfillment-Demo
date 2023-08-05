param managedIdentityName string
param location string

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

output id string = uami.id
output name string = uami.name
output clientId string = uami.properties.clientId
