using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;

namespace FunctionsOrderFulfillmentDemo;

public static class AuthenticationHelper
{
    /// <summary>
    /// Validates authentication based on the feature flag.
    /// Returns null if authentication passes or is disabled.
    /// Returns UnauthorizedResult if authentication is enabled but request is not authorized.
    /// </summary>
    public static IActionResult ValidateAuthentication(HttpRequest req)
    {
        // If authentication is disabled, allow all requests
        if (!Settings.EnableAuthentication)
        {
            return null;
        }

        // If authentication is enabled, check for function key
        var codeParam = req.Query["code"].ToString();
        var functionAppKey = Settings.FunctionAppKey;

        // If function app key is configured and provided code matches, allow request
        if (!string.IsNullOrEmpty(functionAppKey) && codeParam == functionAppKey)
        {
            return null;
        }

        // If no valid authentication found, return unauthorized
        return new UnauthorizedResult();
    }
}