using System;

namespace FunctionsOrderFulfillmentDemo;

public static class Rando
{
    private static readonly Random _random = new Random();

    public static int RandomInteger()
    {
        var rando = _random.Next(1, 60000);

        return rando;
    }

    public static int RandomInteger(int maxValue)
    {
        var rando = _random.Next(1, maxValue);

        return rando;
    }

    public static DateTime RandomFutureDateTime(int maxMilliseconds)
    {
        var ms = RandomInteger(maxMilliseconds) + 200; // Adding a few extra ms for latency and all that

        var dt = DateTime.UtcNow.AddMilliseconds(ms);

        return dt;
    }
}
