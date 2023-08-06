using System;
using Newtonsoft.Json;

namespace FunctionsOrderFulfillmentDemo.Models;

public class SendEventUri
{
    public Uri EventUri { get; set; }

    public static SendEventUri FromJson(string json) => JsonConvert.DeserializeObject<SendEventUri>(json);
}
