using System;
using Azure.Messaging.ServiceBus;
using Newtonsoft.Json;

namespace FunctionsOrderFulfillmentDemo;

public static class Messaging
{
    public static ServiceBusMessage CreateMessage<TPayload>(TPayload payload)
    {
        var jsonString = JsonConvert.SerializeObject(payload);
        return new ServiceBusMessage(jsonString);
    }

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