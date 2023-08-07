using System;

namespace FunctionsOrderFulfillmentDemo;

public static class Settings
{
    public const string CosmosDatabaseNameSettingName = "%cosmosDbName%";
    public const string OrdersContainerNameSettingName = "%ordersContainerName%";
    public const string FulfillmentTopicSettingName = "%fulfillmentTopic%";
    public const string ApprovedOrdersSubscriptionSettingName = "%approvedOrdersSubscription%";
    public const string ShipmentTopicSettingName = "%shipmentTopicName%";
    public const string CosmosLeaseContainerName = "%cosmosLeaseContainerName%";
    public const string StatusNotificationTopic = "%statusNotificationTopic%";
    public const string AllStatusNotificationSubscription = "%allStatusNotificationSubscription%";
    public const string ReceivedOrdersTopicName = "%ordersTopicName%";
    public const string OrdersForApprovalSubscriptionName = "%ordersForApprovalSubscription%";
    public const string SendCreditApprovalTopicName = "%sendApprovalTopic%";
    public const string AllCreditApprovalsSubscriptionName = "%allCreditApprovalsSubscription%";

    public const string CreditApprovalEventName = "CreditApproved";

    public static int MaxWorkDelayInMilliseconds =>
        Convert.ToInt32(Environment.GetEnvironmentVariable("maxWorkDelayInMilliseconds") ?? "100");

    public static string WebHookNotificationUrl =>
        Environment.GetEnvironmentVariable("webHookNotificationUrl") ?? string.Empty;

    public static string EventUriFormatString => Environment.GetEnvironmentVariable("eventUriFormatString") ?? string.Empty;

    public static string FunctionAppKey => Environment.GetEnvironmentVariable("functionAppKey") ?? string.Empty;

    public static string FunctionAppHostName => Environment.GetEnvironmentVariable("functionAppHostName") ?? string.Empty;
}
