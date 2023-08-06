using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using FunctionsOrderFulfillmentDemo.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Azure.WebJobs.ServiceBus;

namespace FunctionsOrderFulfillmentDemo.Functions.Activities;

public class SendOrderToFulfillmentActivity
{
    [FunctionName(nameof(SendOrderToFulfillmentActivity))]
    public async Task SendToFulfillment([ActivityTrigger] SubmitOrderRequest order,
        [ServiceBus(queueOrTopicName: Settings.FulfillmentTopicSettingName, ServiceBusEntityType.Topic, Connection = Connections.ServiceBusConnectionString)] IAsyncCollector<ServiceBusMessage> serviceBusOutput)
    {
        await serviceBusOutput.AddAsync(Messaging.CreateMessage(order.ToJsonString(), order.Id, order.Total));
    }
}
