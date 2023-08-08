using System;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using FunctionsOrderFulfillmentDemo.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.ServiceBus;
using Microsoft.Extensions.Logging;

namespace FunctionsOrderFulfillmentDemo.Functions;

public class SendCreditApprovalNotifictaion
{
    private readonly ILogger<SendCreditApprovalNotifictaion> _logger;
    private readonly HttpClient _httpClient;

    public SendCreditApprovalNotifictaion(ILogger<SendCreditApprovalNotifictaion> log,
        HttpClient httpClient)
    {
        _httpClient = httpClient;
        _logger = log;
    }

    [FunctionName(nameof(SendCreditApprovalNotifictaion))]
    public async Task Run([ServiceBusTrigger(Settings.SendCreditApprovalTopicName, 
        Settings.AllCreditApprovalsSubscriptionName,
        Connection = Connections.ServiceBusConnectionString)] ServiceBusReceivedMessage message,
        ServiceBusMessageActions messageActions)
    {
        var messageContent = SendEventUri.FromJson(message.Body.ToString());
        var uri = messageContent.GetEventUri();
        var status = new CreditApprovalStatus { IsCreditApproved = true };

        try
        {
            var content = new ObjectContent(typeof(CreditApprovalStatus), status, new JsonMediaTypeFormatter());
            var response = await  _httpClient.PostAsync(uri, content);
            response.EnsureSuccessStatusCode();
            _logger.LogInformation($"Sent HTTP request to event endpoint for instance {messageContent.InstanceId}");
        }
        catch (Exception e)
        {
            _logger.LogError(e, "Error sending credit approval");
            await messageActions.DeadLetterMessageAsync(message, $"Exception sending event HTTP call {e.Message}");
        }
    }
}