using Newtonsoft.Json;

namespace FunctionsOrderFulfillmentDemo.Models;

public class OrderLineItem
{
    [JsonProperty("productNumber")]
    public string ProductNumber { get; set; }

    [JsonProperty("quantity")]
    public int Quantity { get; set; }

    [JsonProperty("unitPrice")]
    public decimal UnitPrice { get; set; }

    [JsonProperty("total")]
    public decimal Total { get; set; }
}