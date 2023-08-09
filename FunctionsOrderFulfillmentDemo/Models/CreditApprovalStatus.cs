using Newtonsoft.Json;

namespace FunctionsOrderFulfillmentDemo.Models;

public class CreditApprovalStatus
{
    [JsonProperty("isCreditApproved")]
    public bool IsCreditApproved { get; set; }
}
