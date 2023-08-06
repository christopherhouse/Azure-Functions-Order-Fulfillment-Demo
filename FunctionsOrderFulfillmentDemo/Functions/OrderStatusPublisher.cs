using System;
using System.Collections.Generic;
using FunctionsOrderFulfillmentDemo.Models;
using Microsoft.Azure.Documents;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Azure.WebJobs.ServiceBus;
using Microsoft.Extensions.Logging;

namespace FunctionsOrderFulfillmentDemo.Functions
{
    public static class OrderStatusPublisher
    {
        [FunctionName("OrderStatusPublisher")]
        public static void Run([CosmosDBTrigger(databaseName: Settings.CosmosDatabaseNameSettingName,
                                    containerName: Settings.OrdersContainerNameSettingName,
                                    Connection = Connections.CosmosConnectionString,
                                    LeaseContainerName = Settings.CosmosLeaseConnectionName)] IReadOnlyList<SubmitOrderRequest> orders,
            [ServiceBus(Settings.StatusNotificationTopic, 
                ServiceBusEntityType.Topic,
                Connection = Connections.ServiceBusConnectionString)] IAsyncCollector<StatusNotification> serviceBusOutput,
            ILogger log)
        {
        }
    }
}
