param subscriptionName string
param serviceBusNamespaceName string
param topicName string
param sqlFilterExpression string = ''
param forwardToTopicName string = ''

resource sbNs 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusNamespaceName
  scope: resourceGroup()
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' existing = {
  name: topicName
  parent: sbNs
}

resource subscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  name:subscriptionName
  parent: topic
  properties: {
    deadLetteringOnFilterEvaluationExceptions: true
    deadLetteringOnMessageExpiration: true
    defaultMessageTimeToLive: 'P7D'
    forwardTo: length(forwardToTopicName) > 0 ? forwardToTopicName : null
  }
}



resource rule 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2022-10-01-preview' = if(length(sqlFilterExpression) > 0) {
  name: 'default'
  parent: subscription
  properties: {
    filterType: 'SqlFilter'
    sqlFilter: {
      sqlExpression: sqlFilterExpression
    }
  }
}

output id string = subscription.id
output name string = subscription.name
