using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using FunctionsOrderFulfillmentDemo.Models;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Azure.WebJobs.ServiceBus;

namespace FunctionsOrderFulfillmentDemo.Functions.Activities;

public class SendApprovalEventActivity
{
    private readonly TelemetryClient _telemetryClient;

    public SendApprovalEventActivity(HttpClient httpClient, TelemetryConfiguration telemetryConfiguration)
    {
        _telemetryClient = new TelemetryClient(telemetryConfiguration); 
    }

    [FunctionName(nameof(SendApprovalEventActivity))]
    public async Task SendApproval([ActivityTrigger] string instanceId,
        [ServiceBus(queueOrTopicName: Settings.SendCreditApprovalTopicName,
            ServiceBusEntityType.Topic,
            Connection = Connections.ServiceBusConnectionString)] IAsyncCollector<ServiceBusMessage> messages)
    {
        var eventContent = new SendEventUri(instanceId);

        await messages.AddAsync(Messaging.CreateMessage(eventContent));

        _telemetryClient.TrackEvent("CreditRequestApproved", new Dictionary<string, string>{{"instanceId", instanceId}});
    }
}