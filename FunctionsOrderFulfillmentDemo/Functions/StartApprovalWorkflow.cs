using System;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using FunctionsOrderFulfillmentDemo.Functions.Orchestrations;
using FunctionsOrderFulfillmentDemo.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace FunctionsOrderFulfillmentDemo.Functions
{
    public class StartApprovalWorkflow
    {
        private readonly ILogger<StartApprovalWorkflow> _logger;

        public StartApprovalWorkflow(ILogger<StartApprovalWorkflow> log)
        {
            _logger = log;
        }

        [FunctionName("StartApprovalWorkflow")]
        public async Task Run([ServiceBusTrigger(Settings.ReceivedOrdersTopicName,
                Settings.OrdersForApprovalSubscriptionName,
                Connection = Connections.ServiceBusConnectionString)] ServiceBusReceivedMessage message,
            [DurableClient] IDurableOrchestrationClient orchestrationClient)

        {
            var order = SubmitOrderRequest.FromJson(message.Body.ToString());
            var instance = await orchestrationClient.StartNewAsync(nameof(CreditApprovalOrchestration), order);
        }
    }
}
