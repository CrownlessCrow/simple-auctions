using System.Data;
using MySqlConnector;
using SimpleAuctions.Models;
using SimpleAuctions.Rules;

namespace SimpleAuctions.Repositories;

public class BidRepository(IConfiguration configuration)
{
    private readonly string connectionString = configuration.GetConnectionString("AuctionDatabase")
        ?? throw new InvalidOperationException("Missing ConnectionStrings:AuctionDatabase.");

    public async Task<List<Bid>> GetByAuction(int auctionId)
    {
        await using var connection = new MySqlConnection(connectionString);
        await connection.OpenAsync();
        await using var command = new MySqlCommand("""
            SELECT id, amount, time, buyer_id, auction_id FROM bids
            WHERE auction_id = @auction ORDER BY amount DESC, id;
            """, connection);
        command.Parameters.AddWithValue("@auction", auctionId);
        await using var reader = await command.ExecuteReaderAsync();
        List<Bid> bids = [];
        while (await reader.ReadAsync())
            bids.Add(new Bid(reader.GetInt32("id"), reader.GetDecimal("amount"),
                new DateTimeOffset(DateTime.SpecifyKind(reader.GetDateTime("time"), DateTimeKind.Utc)),
                reader.GetInt32("buyer_id"), reader.GetInt32("auction_id")));
        return bids;
    }

    // Samma transaktion måste omfatta kontroll OCH lagring.
    public async Task<(Bid? Bid, string? Error, bool Found)> Create(int auctionId, decimal amount, int buyerId)
    {
        await using var connection = new MySqlConnection(connectionString);
        await connection.OpenAsync();
        await using var transaction = await connection.BeginTransactionAsync(IsolationLevel.ReadCommitted);
        DateTimeOffset endTime;
        int sellerId;
        // Alla bud på samma auktion köar här. Även en auktion utan bud har en rad att låsa.
        await using (var command = new MySqlCommand(
            "SELECT end_time, seller_id FROM auctions WHERE id = @id FOR UPDATE;", connection, transaction))
        {
            command.Parameters.AddWithValue("@id", auctionId);
            await using var reader = await command.ExecuteReaderAsync();
            if (!await reader.ReadAsync())
                return (null, "Auction not found.", false);
            endTime = new DateTimeOffset(DateTime.SpecifyKind(reader.GetDateTime("end_time"), DateTimeKind.Utc));
            sellerId = reader.GetInt32("seller_id");
        }
        decimal? highest;
        await using (var command = new MySqlCommand(
            "SELECT MAX(amount) FROM bids WHERE auction_id = @id;", connection, transaction))
        {
            command.Parameters.AddWithValue("@id", auctionId);
            object? value = await command.ExecuteScalarAsync();
            highest = value is null or DBNull ? null : Convert.ToDecimal(value);
        }
        // Hämta tiden EFTER att radlåset erhållits, så väntande bud inte använder gammal tid.
        DateTimeOffset now;
        await using (var command = new MySqlCommand("SELECT UTC_TIMESTAMP(6);", connection, transaction))
        {
            var value = (DateTime)(await command.ExecuteScalarAsync())!;
            now = new DateTimeOffset(DateTime.SpecifyKind(value, DateTimeKind.Utc));
        }
        string? error = BidRules.Validate(amount, highest, endTime, now, sellerId, buyerId);
        if (error is not null)
            return (null, error, true); // Dispose rullar tillbaka transaktionen.
        await using var insert = new MySqlCommand("""
            INSERT INTO bids (amount, time, buyer_id, auction_id)
            VALUES (@amount, @time, @buyer, @auction);
            """, connection, transaction);
        insert.Parameters.AddWithValue("@amount", amount);
        insert.Parameters.AddWithValue("@time", now.UtcDateTime);
        insert.Parameters.AddWithValue("@buyer", buyerId);
        insert.Parameters.AddWithValue("@auction", auctionId);
        await insert.ExecuteNonQueryAsync();
        var bid = new Bid(checked((int)insert.LastInsertedId), amount, now, buyerId, auctionId);
        await transaction.CommitAsync();
        return (bid, null, true);
    }
}
