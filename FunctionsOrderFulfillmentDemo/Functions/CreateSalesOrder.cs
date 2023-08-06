using System;
using System.IO;
using System.Net;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using FunctionsOrderFulfillmentDemo.Models.Requests;
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
    [OpenApiOperation(operationId: "Run", tags: new[] { "name" })]
    [OpenApiSecurity("function_key", SecuritySchemeType.ApiKey, Name = "code", In = OpenApiSecurityLocationType.Query)]
    [OpenApiRequestBody("application/json", typeof(SubmitOrderRequest))]
    [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "text/plain", bodyType: typeof(string), Description = "The OK response")]
    [OpenApiResponseWithoutBody(statusCode: HttpStatusCode.Accepted, Description = "The Accepted response")]
    public async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
        [ServiceBus("%ordersTopicName%", ServiceBusEntityType.Topic, Connection = Connections.ServiceBusConnectionString)] IAsyncCollector<ServiceBusMessage> topicOutput,
        [CosmosDB(databaseName: "%cosmosDbName%",
            containerName: "%ordersContainerName%",
            Connection = Connections.CosmosConnectionString)] IAsyncCollector<SubmitOrderRequest> cosmosOutput)
    {
        using var reader = new StreamReader(req.Body);
        var requestBody = await reader.ReadToEndAsync();
        var orderRequest = JsonConvert.DeserializeObject<SubmitOrderRequest>(requestBody);
            
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

        return new AcceptedResult(orderId, null);
    }
}