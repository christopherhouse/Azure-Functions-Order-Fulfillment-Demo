using System;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace FunctionsOrderFulfillmentDemo.Functions
{
    public class SendStatusNotification
    {
        private readonly ILogger<SendStatusNotification> _logger;

        public SendStatusNotification(ILogger<SendStatusNotification> log)
        {
            _logger = log;
        }

        [FunctionName(nameof(SendStatusNotification))]
        public async Task Run([ServiceBusTrigger(topicName: Settings.StatusNotificationTopic,
            subscriptionName: Settings.AllStatusNotificationSubscription,
            Connection = Connections.ServiceBusConnectionString)]string mySbMsg)
        {
            _logger.LogInformation($"C# ServiceBus topic trigger function processed message: {mySbMsg}");
            await Task.FromResult(0);
        }
    }
}
