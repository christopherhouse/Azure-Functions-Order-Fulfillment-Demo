using System.Threading.Tasks;
using FunctionsOrderFulfillmentDemo.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;

namespace FunctionsOrderFulfillmentDemo.Functions.Orchestrations;

public class CreditApprovalOrchestration
{
    [FunctionName(nameof(CreditApprovalOrchestration))]
    public async Task RunOrchestration([OrchestrationTrigger] IDurableOrchestrationContext context)
    {
        var input = context.GetInput<SubmitOrderRequest>();

        var approvedStaus = await context.WaitForExternalEvent<CreditApprovalStatus>(Settings.CreditApprovalEventName);

        if (approvedStaus.IsCreditApproved)
        {

        }
    }
}