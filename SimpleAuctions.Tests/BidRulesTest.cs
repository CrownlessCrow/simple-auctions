namespace SimpleAuctions.Tests;

using Xunit;
using SimpleAuctions.Rules;

public class BidRulesTest
{
    [Fact]
    public void Validate_TwoDecimals_IsOk()
    {
        var result = BidRules.Validate(150.50m);   // gör

        Assert.Null(result);                       // kontrollera: null betyder "inget fel"
    }
}