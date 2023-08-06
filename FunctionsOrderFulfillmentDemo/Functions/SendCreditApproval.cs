using System.Net.Http;
using System.Threading.Tasks;
using FunctionsOrderFulfillmentDemo.Models;
using Microsoft.Azure.WebJobs;
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
        Connection = Connections.ServiceBusConnectionString)] SendEventUri eventUri)
    {
        var response = _httpClient.PostAsync(eventUri.EventUri, null);
    }
}