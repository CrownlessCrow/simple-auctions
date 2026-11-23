using SimpleAuctions.Rules;
using Xunit;

namespace SimpleAuctions.Tests;

public class BidRulesTests
{
    private static readonly DateTimeOffset End = new(2030, 1, 1, 12, 0, 0, TimeSpan.Zero);

    [Fact]
    public void First_positive_bid_is_allowed_without_start_price() =>
        Assert.Null(BidRules.Validate(0.01m, null, End, End.AddTicks(-1), 1, 2));

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    [InlineData(1.001)]
    [InlineData(10000000000)]
    public void Invalid_amount_is_rejected(double value) =>
        Assert.NotNull(BidRules.Validate((decimal)value, null, End, End.AddMinutes(-1), 1, 2));

    [Theory]
    [InlineData(99)]
    [InlineData(100)]
    public void Bid_must_exceed_highest_bid(int amount) =>
        Assert.NotNull(BidRules.Validate(amount, 100m, End, End.AddMinutes(-1), 1, 2));

    [Fact]
    public void Smallest_cent_increase_is_allowed() =>
        Assert.Null(BidRules.Validate(100.01m, 100m, End, End.AddMinutes(-1), 1, 2));

    [Theory]
    [InlineData(0)]
    [InlineData(1)]
    public void Bid_at_or_after_end_is_rejected(int seconds) =>
        Assert.NotNull(BidRules.Validate(101m, 100m, End, End.AddSeconds(seconds), 1, 2));

    [Fact]
    public void Seller_cannot_bid() =>
        Assert.NotNull(BidRules.Validate(1m, null, End, End.AddMinutes(-1), 1, 1));
}
