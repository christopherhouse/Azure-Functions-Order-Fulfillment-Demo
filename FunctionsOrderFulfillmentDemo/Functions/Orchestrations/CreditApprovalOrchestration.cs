using System.Threading.Tasks;
using FunctionsOrderFulfillmentDemo.Functions.Activities;
using FunctionsOrderFulfillmentDemo.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;

namespace FunctionsOrderFulfillmentDemo.Functions.Orchestrations;

public class CreditApprovalOrchestration
{
    [FunctionName(nameof(CreditApprovalOrchestration))]
    public async Task RunOrchestration([OrchestrationTrigger] IDurableOrchestrationContext context)
    {
        var order = context.GetInput<SubmitOrderRequest>();

        await context.CallActivityAsync<SendApprovalEventActivity>(nameof(SendApprovalEventActivity),
            context.InstanceId);

        var approvedStatus = await context.WaitForExternalEvent<CreditApprovalStatus>(Settings.CreditApprovalEventName);

        if (approvedStatus.IsCreditApproved)
        {
            await context.CallActivityAsync<SendOrderToFulfillmentActivity>(nameof(SendOrderToFulfillmentActivity), order);
        }
    }
}