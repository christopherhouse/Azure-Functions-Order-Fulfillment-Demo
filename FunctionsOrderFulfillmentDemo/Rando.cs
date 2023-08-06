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
}
