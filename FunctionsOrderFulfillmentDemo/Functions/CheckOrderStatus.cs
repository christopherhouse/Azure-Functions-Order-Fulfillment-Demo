using System.Net;
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
        [OpenApiOperation(operationId: "Run", tags: new[] { "name" })]
        [OpenApiSecurity("function_key", SecuritySchemeType.ApiKey, Name = "code", In = OpenApiSecurityLocationType.Query)]
        [OpenApiParameter(name: "name", In = ParameterLocation.Query, Required = true, Type = typeof(string), Description = "The **Name** parameter")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "text/plain", bodyType: typeof(string), Description = "The OK response")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = "orderStatus/{customerId}/{orderId}")] HttpRequest req,
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

