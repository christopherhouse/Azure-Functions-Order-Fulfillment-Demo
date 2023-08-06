using System;

namespace FunctionsOrderFulfillmentDemo;

public static class Settings
{
    public const string CosmosDatabaseNameSettingName = "%cosmosDbName%";
    public const string OrdersContainerNameSettingName = "%ordersContainerName%";
    public const string FulfillmentTopicSettingName = "%fulfillmentTopic%";
    public const string ApprovedOrdersSubscriptionSettingName = "%approvedOrdersSubscription%";
    public const string ShipmentTopicSettingName = "%shipmentTopicName%";
    public const string CosmosLeaseConnectionName = "cosmosLeaseContainerName";
    public const string StatusNotificationTopic = "%statusNotificationTopic%";

    public static int MaxWorkDelayInMilliseconds =>
        Convert.ToInt32(Environment.GetEnvironmentVariable("maxWorkDelayInMilliseconds") ?? "100");
}
