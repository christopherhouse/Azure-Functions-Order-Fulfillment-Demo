using System;
using Azure.Messaging.ServiceBus;

namespace FunctionsOrderFulfillmentDemo;

public static class Messaging
{
    public static ServiceBusMessage CreateMessage(string payload, string correlationId, decimal orderTotal, DateTimeOffset? scheduledEnqueueTime = null)
    {
        var message = new ServiceBusMessage(payload)
        {
            CorrelationId = correlationId,
            ContentType = "application/json"
        };
        message.ApplicationProperties.Add("orderTotal", orderTotal);

        if (scheduledEnqueueTime.HasValue)
        {
            message.ScheduledEnqueueTime = scheduledEnqueueTime.Value;
        }

        return message;
    }
}