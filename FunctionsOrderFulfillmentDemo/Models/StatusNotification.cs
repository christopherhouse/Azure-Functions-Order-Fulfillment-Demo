using Newtonsoft.Json;

namespace FunctionsOrderFulfillmentDemo.Models;

public class StatusNotification
{
    public StatusNotification()
    {
    }

    public StatusNotification(string orderId,
        string customerId,
        string status)
    {
        OrderId = orderId; 
        CustomerId = customerId;
        Status = status;
    }

    public string OrderId { get; set; }

    public string CustomerId { get; set; }

    public string Status { get; set; }

    public string ToJsonString() => JsonConvert.SerializeObject(this);
}