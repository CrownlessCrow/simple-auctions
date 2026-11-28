namespace SimpleAuctions.Tests;

using Xunit;
using SimpleAuctions.Rules;

public class BidRulesTest
{
    [Fact] // Testa medoden om den funkar
    public void Validate_TwoDecimals_IsOk()
    {
        var result = BidRules.Validate(150.50m);   // gör, resultat lådan innehåll (null eller inte)

        Assert.Null(result);                       // kontrollera: null betyder "inget fel"
    }

    // R1: Ekvivalensklass "ogiltigt" + gränsvärdet 0
    [Theory] // Testfiler, då jag testa 0, -0.01 och -100. Förväntad resultat RÖTT
    [InlineData(0)]
    [InlineData(-0.01)]
    [InlineData(-100)]
    public void Validate_ReturnsError_WhenAmountIsZeroOrNegative(double amount)
    {
        var result = BidRules.Validate((decimal)amount);

        Assert.NotNull(result); // Null = Rött
    }

    // Testa gilltiga tal. Förväntat resultat Grönt
    [Theory]
    [InlineData(0.01)]
    [InlineData(100)]
    public void Validate_ReturnsNull_WhenAmountIsPositive(double amount)
    {
        var result = BidRules.Validate((decimal)amount);

        Assert.Null(result);
    }
}