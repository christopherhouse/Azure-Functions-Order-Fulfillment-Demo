using System;
using Newtonsoft.Json;

namespace FunctionsOrderFulfillmentDemo.Models;

public class SendEventUri
{
    public SendEventUri()
    {
    }

    public SendEventUri(string instanceId)
    {
        InstanceId = instanceId;
    }

    public string InstanceId { get; set; }

    public static SendEventUri FromJson(string json) => JsonConvert.DeserializeObject<SendEventUri>(json);

    public Uri GetEventUri() =>
        new(string.Format(Settings.EventUriFormatString, InstanceId, Settings.FunctionAppKey));   
}
