-- Testdata för simple_auctions (påhittade användare, inga riktiga uppgifter)
-- Kör som administratör (t.ex. root) i DBeaver med Alt+X (Execute script).
-- Skriptet kan köras om: det rensar först bara de id-intervall som det själv skapar.
-- Alla tider är relativa till körningstillfället och lagras i UTC.

USE simple_auctions;

-- ---------- Rensa tidigare testdata (endast våra id-intervall) ----------
DELETE FROM bids     WHERE id BETWEEN 1001 AND 1999;
DELETE FROM auctions WHERE id BETWEEN 101 AND 199;
DELETE FROM users    WHERE id BETWEEN 101 AND 199;

-- ---------- Användare (20 st) ----------
-- OBS: password_hash är en platshållare, inte en riktig hash. Dessa användare
-- kan inte logga in. Registrera de användare du vill logga in med via POST /api/users.
INSERT INTO users (id, email, password_hash) VALUES
(101, 'user01@example.test', 'SEED-NOT-A-REAL-HASH'),
(102, 'user02@example.test', 'SEED-NOT-A-REAL-HASH'),
(103, 'user03@example.test', 'SEED-NOT-A-REAL-HASH'),
(104, 'user04@example.test', 'SEED-NOT-A-REAL-HASH'),
(105, 'user05@example.test', 'SEED-NOT-A-REAL-HASH'),
(106, 'user06@example.test', 'SEED-NOT-A-REAL-HASH'),
(107, 'user07@example.test', 'SEED-NOT-A-REAL-HASH'),
(108, 'user08@example.test', 'SEED-NOT-A-REAL-HASH'),
(109, 'user09@example.test', 'SEED-NOT-A-REAL-HASH'),
(110, 'user10@example.test', 'SEED-NOT-A-REAL-HASH'),
(111, 'user11@example.test', 'SEED-NOT-A-REAL-HASH'),
(112, 'user12@example.test', 'SEED-NOT-A-REAL-HASH'),
(113, 'user13@example.test', 'SEED-NOT-A-REAL-HASH'),
(114, 'user14@example.test', 'SEED-NOT-A-REAL-HASH'),
(115, 'user15@example.test', 'SEED-NOT-A-REAL-HASH'),
(116, 'user16@example.test', 'SEED-NOT-A-REAL-HASH'),
(117, 'user17@example.test', 'SEED-NOT-A-REAL-HASH'),
(118, 'user18@example.test', 'SEED-NOT-A-REAL-HASH'),
(119, 'user19@example.test', 'SEED-NOT-A-REAL-HASH'),
(120, 'user20@example.test', 'SEED-NOT-A-REAL-HASH');

-- ---------- Auktioner ----------
-- 101-110 pågående (sluttid i framtiden), 111-115 avslutade (sluttid i det förflutna)
INSERT INTO auctions (id, name, end_time, seller_id) VALUES
(101, 'Vintage synthesizer',    DATE_ADD(UTC_TIMESTAMP(), INTERVAL 2 DAY),   101),
(102, 'Cykel, 3 växlar',        DATE_ADD(UTC_TIMESTAMP(), INTERVAL 5 DAY),   102),
(103, 'Bokhylla i ek',          DATE_ADD(UTC_TIMESTAMP(), INTERVAL 1 DAY),   103),
(104, 'Kaffekvarn',             DATE_ADD(UTC_TIMESTAMP(), INTERVAL 10 DAY),  104),
(105, 'Gitarrförstärkare',      DATE_ADD(UTC_TIMESTAMP(), INTERVAL 3 HOUR),  105),
(106, 'Skrivbord',              DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 DAY),   106),
(107, 'Retrokonsol',            DATE_ADD(UTC_TIMESTAMP(), INTERVAL 14 DAY),  107),
(108, 'Trädgårdsstol',          DATE_ADD(UTC_TIMESTAMP(), INTERVAL 20 DAY),  108),
(109, 'Kamera med objektiv',    DATE_ADD(UTC_TIMESTAMP(), INTERVAL 30 DAY),  109),
(110, 'Lampa från 60-talet',    DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 DAY),   110),
(111, 'Två mattor',             DATE_SUB(UTC_TIMESTAMP(), INTERVAL 1 DAY),   111),
(112, 'Brädspelssamling',       DATE_SUB(UTC_TIMESTAMP(), INTERVAL 3 DAY),   112),
(113, 'Vinylskivor',            DATE_SUB(UTC_TIMESTAMP(), INTERVAL 7 DAY),   113),
(114, 'Cykelhjälm',             DATE_SUB(UTC_TIMESTAMP(), INTERVAL 10 DAY),  114),
(115, 'Armbandsur',             DATE_SUB(UTC_TIMESTAMP(), INTERVAL 2 DAY),   115);

-- ---------- Bud ----------
-- Gränsfall som finns med:
--   103 (pågående) och 114 (avslutad): inga bud
--   104, 108 (pågående) och 115 (avslutad): ett enda bud
--   110: två lika höga bud (olika tid)
--   105: slutar om 3 timmar, bra för tidsgränser
-- Budtiderna ligger alltid före auktionens sluttid.
INSERT INTO bids (id, amount, `time`, buyer_id, auction_id) VALUES
-- Pågående
(1001, 100.00, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 20 HOUR), 111, 101),
(1002, 120.00, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 12 HOUR), 112, 101),
(1003, 150.50, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 3 HOUR),  113, 101),
(1004, 250.00, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 2 DAY),   103, 102),
(1005, 275.00, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 1 DAY),   104, 102),
(1006, 80.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 5 HOUR),  105, 104),
(1007, 300.00, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 10 HOUR), 106, 105),
(1008, 310.00, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 6 HOUR),  107, 105),
(1009, 325.00, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 1 HOUR),  106, 105),
(1010, 500.00, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 2 DAY),   108, 106),
(1011, 550.00, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 1 DAY),   109, 106),
(1012, 45.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 4 DAY),   110, 107),
(1013, 50.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 3 DAY),   111, 107),
(1014, 55.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 2 DAY),   112, 107),
(1015, 60.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 1 DAY),   113, 107),
(1016, 30.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 8 HOUR),  114, 108),
(1017, 1200.00, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 3 DAY),  115, 109),
(1018, 1250.00, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 2 DAY),  116, 109),
(1019, 1300.00, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 1 DAY),  117, 109),
(1020, 99.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 6 HOUR),  118, 110),
(1021, 99.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 4 HOUR),  119, 110),
-- Avslutade
(1022, 40.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 3 DAY),   112, 111),
(1023, 55.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 2 DAY),   113, 111),
(1024, 70.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 30 HOUR), 112, 111),
(1025, 20.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 5 DAY),   114, 112),
(1026, 25.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 4 DAY),   115, 112),
(1027, 15.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 10 DAY),  116, 113),
(1028, 18.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 9 DAY),   117, 113),
(1029, 22.50,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 8 DAY),   118, 113),
(1030, 30.00,  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 170 HOUR), 117, 113),
(1031, 750.00, DATE_SUB(UTC_TIMESTAMP(), INTERVAL 4 DAY),   120, 115);

-- Kontroll
SELECT (SELECT COUNT(*) FROM users    WHERE id BETWEEN 101 AND 199) AS users,
       (SELECT COUNT(*) FROM auctions WHERE id BETWEEN 101 AND 199) AS auctions,
       (SELECT COUNT(*) FROM bids     WHERE id BETWEEN 1001 AND 1999) AS bids;
