using System;
using System.Net.Http;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using FunctionsOrderFulfillmentDemo.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.ServiceBus;
using Microsoft.Extensions.Logging;

namespace FunctionsOrderFulfillmentDemo.Functions;

public class SendCreditApproval
{
    private readonly ILogger<SendCreditApproval> _logger;
    private readonly HttpClient _httpClient;

    public SendCreditApproval(ILogger<SendCreditApproval> log,
        HttpClient httpClient)
    {
        _httpClient = httpClient;
        _logger = log;
    }

    [FunctionName(nameof(SendCreditApproval))]
    public async Task Run([ServiceBusTrigger(Settings.SendCreditApprovalTopicName, 
        Settings.SendCreditApprovalTopicName,
        Connection = Connections.ServiceBusConnectionString)] ServiceBusReceivedMessage message,
        ServiceBusMessageActions messageActions)
    {
        var messageContent = SendEventUri.FromJson(message.Body.ToString());

        try
        {
            var response = _httpClient.PostAsync(messageContent.EventUri, null);
        }
        catch (Exception e)
        {
            _logger.LogError(e, "Error sending credit approval");
            await messageActions.DeadLetterMessageAsync(message);
        }

    }
}