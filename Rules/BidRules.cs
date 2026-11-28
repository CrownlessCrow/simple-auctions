
namespace SimpleAuctions.Rules;

public static class BidRules
{
    public static string? Validate(decimal amount) // ta emot ett bud
    {
        if (amount <= 0) // Regel 1: bud måste vara större än 0
            return "Amount must be greater than zero.";
        if (decimal.Round(amount, 2) != amount) // ändra det av avrudningen? t.ex 100.111 = 100.11 (Ja den ändras av avrundningen)
            return "Amount must have at most two decimal places."; // fel
        return null; // Om den inte ändras så är det OK
    }
}


/*
//-------Orginal koden-------
namespace SimpleAuctions.Rules;

public static class BidRules
{
    public static string? Validate(decimal amount)
    {
        if (decimal.Round(amount, 2) != amount)
            return "Amount must have at most two decimal places.";
        return null;
    }
}
*/