using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace FunctionsOrderFulfillmentDemo.Functions
{
    public class SendStatusNotification
    {
        private readonly ILogger<SendStatusNotification> _logger;
        private readonly HttpClient _httpClient;
        private static readonly Uri _webhookUri = new(Settings.WebHookNotificationUrl);

        public SendStatusNotification(ILogger<SendStatusNotification> log,
            HttpClient httpClient)
        {
            _httpClient = httpClient;
            _logger = log;
        }

        [FunctionName(nameof(SendStatusNotification))]
        public async Task Run([ServiceBusTrigger(topicName: Settings.StatusNotificationTopic,
            subscriptionName: Settings.AllStatusNotificationSubscription,
            Connection = Connections.ServiceBusConnectionString)]string statusNotification)
        {
            try
            {
                // Send call to webhook endpoint to share status update
                var content = new StringContent(statusNotification);
                content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
                var response = await _httpClient.PostAsync(_webhookUri, content);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending status notification");
            }
        }
    }
}
