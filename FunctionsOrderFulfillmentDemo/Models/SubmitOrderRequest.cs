using System;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json;

namespace FunctionsOrderFulfillmentDemo.Models;

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

    public static SubmitOrderRequest FromJson(string json) => JsonConvert.DeserializeObject<SubmitOrderRequest>(json);

    public string ToJsonString() => JsonConvert.SerializeObject(this);

    public static SubmitOrderRequest FromByteArray(byte[] data) => FromJson(Encoding.UTF8.GetString(data));
}