using System.Collections.Generic;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using FunctionsOrderFulfillmentDemo.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.ServiceBus;
using Microsoft.Extensions.Logging;

namespace FunctionsOrderFulfillmentDemo.Functions
{
    public static class OrderStatusPublisher
    {
        [FunctionName("OrderStatusPublisher")]
        public static async Task Run([CosmosDBTrigger(databaseName: Settings.CosmosDatabaseNameSettingName,
                                    containerName: Settings.OrdersContainerNameSettingName,
                                    Connection = Connections.CosmosConnectionString,
                                    LeaseContainerName = Settings.CosmosLeaseContainerName)] IReadOnlyList<SubmitOrderRequest> orders,
            [ServiceBus(Settings.StatusNotificationTopic, 
                ServiceBusEntityType.Topic,
                Connection = Connections.ServiceBusConnectionString)] IAsyncCollector<ServiceBusMessage> serviceBusOutput,
            ILogger log)
        {
            foreach (var order in orders)
            {
                var notification = new StatusNotification(order.Id, order.CustomerId, order.Status);
                var message = Messaging.CreateMessage(notification.ToJsonString(), order.Id, order.Total);
                await serviceBusOutput.AddAsync(message);
            }
        }
    }
}
