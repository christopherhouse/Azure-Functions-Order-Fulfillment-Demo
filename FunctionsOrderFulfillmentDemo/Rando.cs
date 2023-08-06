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
}
