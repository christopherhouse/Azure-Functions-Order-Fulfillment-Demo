using Newtonsoft.Json;

namespace FunctionsOrderFulfillmentDemo.Models;

public class OrderStatusResponse
{
    [JsonProperty("orderId")]
    public string OrderId { get; set; }

    [JsonProperty("customerId")]
    public string CustomerId { get; set; }

    [JsonProperty("status")]
    public string Status { get; set; }
}
