namespace SimpleAuctions.Rules;

// Ren logik: inga HTTP-anrop, databasanslutningar eller dolda klockberoenden.
public static class BidRules
{
    public static string? Validate(decimal amount, decimal? highestAmount,
        DateTimeOffset endTime, DateTimeOffset now, int sellerId, int buyerId)
    {
        if (amount <= 0 || amount > 9999999999.99m || decimal.Round(amount, 2) != amount)
            return "Bid must be positive, within range and have at most two decimal places.";
        if (now >= endTime)
            return "Auction has ended.";
        if (sellerId == buyerId)
            return "Seller cannot bid on their own auction.";
        if (highestAmount.HasValue && amount <= highestAmount.Value)
            return "Bid must be higher than the current highest bid.";
        return null;
    }
}
