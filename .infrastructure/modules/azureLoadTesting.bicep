param loadTestsName string
param location string

resource alt 'Microsoft.LoadTestService/loadTests@2022-12-01' = {
  name: loadTestsName
  location: location
  properties: {
  }
}
