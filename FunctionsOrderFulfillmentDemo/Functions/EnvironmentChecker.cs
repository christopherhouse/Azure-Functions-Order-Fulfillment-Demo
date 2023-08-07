using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace FunctionsOrderFulfillmentDemo.Functions
{
    public static class EnvironmentChecker
    {
        [FunctionName("EnvironmentChecker")]
        public static IActionResult Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            var results = new Dictionary<string, bool>();

            try
            {
                var appInsights = Environment.GetEnvironmentVariable("APPINSIGHTS_INSTRUMENTATIONKEY");
                var cosmos = Environment.GetEnvironmentVariable(Connections.CosmosConnectionString);
                var serviceBus = Environment.GetEnvironmentVariable(Connections.ServiceBusConnectionString);

                results.Add(nameof(appInsights), !string.IsNullOrWhiteSpace(appInsights));
                results.Add(nameof(cosmos), !string.IsNullOrWhiteSpace(cosmos));
                results.Add(nameof(serviceBus), !string.IsNullOrWhiteSpace(serviceBus));
            }
            catch
            {
            }

            return new OkObjectResult(results);
        }
    }
}
