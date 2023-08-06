using System;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using FunctionsOrderFulfillmentDemo.Models.Requests;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Azure.WebJobs.ServiceBus;
using Microsoft.Extensions.Logging;

namespace FunctionsOrderFulfillmentDemo.Functions
{
    public class FulfillOrder
    {
        private readonly ILogger<FulfillOrder> _logger;

        public FulfillOrder(ILogger<FulfillOrder> log)
        {
            _logger = log;
        }

        [FunctionName(nameof(FulfillOrder))]
        public async Task Run([ServiceBusTrigger("%fulfillmentTopic%", "%approvedOrdersSubscription%", Connection = Connections.ServiceBusConnectionString)]string orderJson,
           [CosmosDB(Connection = Connections.CosmosConnectionString)] IAsyncCollector<SubmitOrderRequest> cosmosOutput,
            [ServiceBus("%shipmentTopicName%", ServiceBusEntityType.Topic, Connection = Connections.ServiceBusConnectionString)] IAsyncCollector<ServiceBusMessage> serviceBusOutput)
        {
            // Simulate order fulfillment by putting a delay here.  Real world, there would be an ERP and multiple
            // other systems part of this workflow.
            var delay = Rando.RandomInteger();
            _logger.LogInformation($"Fulfilling order with delay of {delay}ms");

            await Task.Delay(delay);
 
            var order = SubmitOrderRequest.FromJson(orderJson);
            order.Status = "Processing";

            var message = Messaging.CreateMessage(order.ToJsonString(), order.Id, order.Total);

            await cosmosOutput.AddAsync(order);
            await serviceBusOutput.AddAsync(message);
        }
    }
}
