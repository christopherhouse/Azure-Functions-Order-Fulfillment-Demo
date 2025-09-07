# Backend Authentication Feature Flag

This feature flag allows you to enable or disable authentication for the HTTP endpoints in the Azure Functions backend.

## How to Use

The authentication feature flag is controlled by the `EnableAuthentication` property in the `Settings.cs` file:

```csharp
// Feature flag to enable/disable authentication for HTTP endpoints
// Set to false to allow anonymous access, true to require function keys
public static bool EnableAuthentication => true;
```

## Behavior

### When EnableAuthentication = true (Default)
- All HTTP endpoints require a valid function key
- Requests without the correct `code` parameter will receive `401 Unauthorized`
- Maintains the original security behavior

### When EnableAuthentication = false
- All HTTP endpoints allow anonymous access
- No authentication checks are performed
- Useful for testing and development

## Affected Endpoints

The following HTTP endpoints are controlled by this feature flag:
- `POST /api/CreateSalesOrder` - Create a new sales order
- `GET /api/orderStatus/{customerId}/{orderId}` - Check order status  
- `GET /api/EnvironmentChecker` - Check environment configuration

## Configuration

To disable authentication, change the Settings.cs file:

```csharp
public static bool EnableAuthentication => false;
```

To enable authentication (default), set it to true:

```csharp
public static bool EnableAuthentication => true;
```

## Frontend Impact

No changes to the frontend are required. The frontend can continue to work with or without providing function keys based on the backend configuration.