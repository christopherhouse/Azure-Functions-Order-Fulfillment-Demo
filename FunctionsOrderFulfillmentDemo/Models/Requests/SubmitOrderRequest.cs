using System;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace FunctionsOrderFulfillmentDemo.Models.Requests;

public class SubmitOrderRequest
{
    public SubmitOrderRequest()
    {
        LineItems = new List<OrderLineItem>();
    }

    [JsonProperty("id")]
    public string Id { get; set; }

    [JsonProperty("customerId")]
    public string CustomerId { get; set; }

    [JsonProperty("total")]
    public decimal Total { get; set; }

    [JsonProperty("lineItems")]
    public IList<OrderLineItem> LineItems { get; }

    [JsonProperty("status")]
    public string Status { get; set; }
}