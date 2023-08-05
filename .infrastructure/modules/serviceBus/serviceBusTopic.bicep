param topicName string
param serviceBusNamespaceName string
param maxTopicSize int = 1024

resource ns 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusNamespaceName
  scope: resourceGroup()
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  name: topicName
  parent: ns
  properties: {
    maxSizeInMegabytes: maxTopicSize
  }
}

output id string = topic.id
output name string = topic.name
