using System;
using System.IO;
using System.Net;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using FunctionsOrderFulfillmentDemo.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Enums;
using Microsoft.Azure.WebJobs.ServiceBus;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using Newtonsoft.Json;

namespace FunctionsOrderFulfillmentDemo.Functions;

public class CreateSalesOrder
{
    private readonly ILogger<CreateSalesOrder> _logger;

    public CreateSalesOrder(ILogger<CreateSalesOrder> log)
    {
        _logger = log;
    }

    [FunctionName(nameof(CreateSalesOrder))]
    [OpenApiOperation(operationId: nameof(CreateSalesOrder), tags: new[] { "name" })]
    [OpenApiSecurity("function_key", SecuritySchemeType.ApiKey, Name = "code", In = OpenApiSecurityLocationType.Query)]
    [OpenApiRequestBody("application/json", typeof(SubmitOrderRequest))]
    [OpenApiResponseWithoutBody(statusCode: HttpStatusCode.Accepted, Description = "The Accepted response")]
    public async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
        [ServiceBus("%ordersTopicName%", ServiceBusEntityType.Topic, Connection = Connections.ServiceBusConnectionString)] IAsyncCollector<ServiceBusMessage> topicOutput,
        [CosmosDB(databaseName: "%cosmosDbName%",
            containerName: "%ordersContainerName%",
            Connection = Connections.CosmosConnectionString)] IAsyncCollector<SubmitOrderRequest> cosmosOutput)
    {
        IActionResult result;
        using var reader = new StreamReader(req.Body);
        var requestBody = await reader.ReadToEndAsync();
        var orderRequest = JsonConvert.DeserializeObject<SubmitOrderRequest>(requestBody);

        if (orderRequest != null)
        {
            var orderId = Guid.NewGuid().ToString();
            orderRequest.Id = orderId;
            orderRequest.Status = orderRequest.Total > 1000 ? "Pending Approval" : "Approved";

            var message = new ServiceBusMessage(JsonConvert.SerializeObject(orderRequest))
            {
                CorrelationId = orderId,
                ContentType = "application/json"
            };

            message.ApplicationProperties.Add("orderTotal", orderRequest.Total);

            await cosmosOutput.AddAsync(orderRequest);
            await topicOutput.AddAsync(message);
            result = new AcceptedResult(GetLocationEndpoint(orderRequest.CustomerId, orderRequest.Id), null);
        }
        else
        {
            result = new BadRequestResult();
        }

        return result;
    }

    private static string GetLocationEndpoint(string customerId, string orderId)
    {
        var uriString = $"{Settings.FunctionAppHostName}/api/orderStatus/{customerId}/{orderId}";
        return uriString;
    }
}