using SimpleAuctions.Rules;
using Xunit;

namespace SimpleAuctions.Tests;

public class BidRulesTests
{
    [Fact]
    public void Amount_with_two_decimal_places_is_allowed() =>
        Assert.Null(BidRules.Validate(12.34m));

    [Fact]
    public void Amount_with_more_than_two_decimal_places_is_rejected() =>
        Assert.NotNull(BidRules.Validate(12.345m));
}
