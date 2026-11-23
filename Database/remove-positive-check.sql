-- Kör ENDAST om databasen skapades med den tidigare versionens positive_amount-regel.
-- Tabeller och data bevaras.
USE simple_auctions;
ALTER TABLE bids DROP CHECK positive_amount;
