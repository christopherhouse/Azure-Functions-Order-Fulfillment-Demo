using System;
using System.ComponentModel;
using System.Net;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using FunctionsOrderFulfillmentDemo.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Enums;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using Newtonsoft.Json;

namespace FunctionsOrderFulfillmentDemo.Functions
{
    public class CheckOrderStatus
    {
        private readonly ILogger<CheckOrderStatus> _logger;

        public CheckOrderStatus(ILogger<CheckOrderStatus> log)
        {
            _logger = log;
        }

        [FunctionName(nameof(CheckOrderStatus))]
        [OpenApiOperation(operationId: nameof(CheckOrderStatus), tags: new[] { "name" })]
        [OpenApiSecurity("function_key", SecuritySchemeType.ApiKey, Name = "code", In = OpenApiSecurityLocationType.Query)]
        [OpenApiParameter(name: "customerId", In = ParameterLocation.Path, Required = true, Type = typeof(string), Description = "The **customerId** parameter")]
        [OpenApiParameter(name: "orderId", In = ParameterLocation.Path, Required = true, Type = typeof(string), Description = "The **orderId** parameter")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "application/json", bodyType: typeof(OrderStatusResponse), Description = "The OK response")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "orderStatus/{customerId}/{orderId}")] HttpRequest req,
            [CosmosDB(databaseName: Settings.CosmosDatabaseNameSettingName,
                containerName: Settings.OrdersContainerNameSettingName,
                Connection = Connections.CosmosConnectionString,
                Id = "{orderId}",
                PartitionKey = "{customerId}")] SubmitOrderRequest order)
        {
            IActionResult result;

            if (order != null)
            {
                result = new OkObjectResult(new OrderStatusResponse
                {
                    CustomerId = order.CustomerId,
                    OrderId = order.Id, 
                    Status = order.Status
                });
            }
            else
            {
                result = new NotFoundResult();
            }

            return result;
        }
    }
}

