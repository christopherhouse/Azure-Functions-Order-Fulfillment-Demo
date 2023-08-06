using System;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using FunctionsOrderFulfillmentDemo.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Azure.WebJobs.ServiceBus;

namespace FunctionsOrderFulfillmentDemo.Functions.Activities;

public class SendApprovalEventActivity
{
    private readonly HttpClient _httpClient;

    public SendApprovalEventActivity(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    [FunctionName(nameof(SendApprovalEventActivity))]
    public async Task SendApproval([ActivityTrigger] string instanceId,
        [ServiceBus(queueOrTopicName: Settings.SendCreditApprovalTopicName,
            ServiceBusEntityType.Topic,
            Connection = Connections.ServiceBusConnectionString)] IAsyncCollector<ServiceBusMessage> messages)
    {
        var eventUri = new Uri(string.Format(Settings.WebHookNotificationUrl, instanceId));
    }
}