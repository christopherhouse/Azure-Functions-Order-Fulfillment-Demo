using System;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using FunctionsOrderFulfillmentDemo.Models;
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
        public async Task Run([ServiceBusTrigger(Settings.FulfillmentTopicSettingName, Settings.ApprovedOrdersSubscriptionSettingName, Connection = Connections.ServiceBusConnectionString)] ServiceBusReceivedMessage orderMessage,
           [CosmosDB(databaseName: Settings.CosmosDatabaseNameSettingName, containerName: Settings.OrdersContainerNameSettingName, Connection = Connections.CosmosConnectionString)] IAsyncCollector<SubmitOrderRequest> cosmosOutput,
            [ServiceBus(Settings.ShipmentTopicSettingName, ServiceBusEntityType.Topic, Connection = Connections.ServiceBusConnectionString)] IAsyncCollector<ServiceBusMessage> serviceBusOutput)
        {
            // Simulate order fulfillment by putting a delay here.  Real world, there would be an ERP and multiple
            // other systems part of this workflow.
            var delay = Rando.RandomInteger(Settings.MaxWorkDelayInMilliseconds);
            _logger.LogInformation($"Fulfilling order with delay of {delay}ms");

            await Task.Delay(delay);
            
            var order = SubmitOrderRequest.FromJson(orderMessage.Body.ToString());
            order.Status = "Processing";

            var message = Messaging.CreateMessage(order.ToJsonString(), order.Id, order.Total);

            await cosmosOutput.AddAsync(order);
            await serviceBusOutput.AddAsync(message);
        }
    }
}
