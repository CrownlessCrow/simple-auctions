# Auktionsregler – grupp MAGI

## Auktionstyp
Rekommenderat **engelsk auktion (stigande)**. Budgivarna höjer öppet, och det högsta giltiga budet vinner när tiden går ut. 


**Väntar på gruppens godkännande**




### Varför engelsk auktion?
- **Effektivitet:** Den befintliga koden är redan byggd som en engelsk auktion. Vi bygger vidare i stället för att bygga om.
- **Kvalitet:** Tydliga regler med mätbara gränsvärden gör att varje regel kan testas grundligt.
- **Säkerhet:** Buden är öppna, så det finns ingen hemlig data som kan läcka.

### Bortvalda alternativ
| Typ | Varför vi valde bort den |
|---|---|
| Holländsk | Priset måste sänkas automatiskt över tid, vilket ger mer komplex logik |
| Förseglat bud / Vickrey | Bud måste döljas för andra, vilket ger en större säkerhetsrisk |
| Omvänd | Vänder på hela modellen och kräver omskrivning av koden |
| Köp nu / förlängning | Bygger på engelsk auktion. Kan läggas till senare om tid finns |

## Budregler
| Id | Regel | Gränsvärden att testa | Status |
|---|---|---|---|
| R1 | Ett bud måste vara större än 0 | 0 nekas, 0,01 godkänns | ✅ Klar |
| R2 | Högst två decimaler | 100,01 godkänns, 100,001 nekas | ✅ Fanns redan |
| R3 | Första budet måste vara minst startpriset | startpris − 0,01 nekas, startpris godkänns | ⬜ |
| R4 | Ett nytt bud måste vara minst 1 kr högre än högsta budet | +0,99 nekas, +1,00 godkänns | ⬜ |
| R5 | Säljaren får inte buda på sin egen auktion | – | ⬜ |
| R6 | Bud nekas när sluttiden är nådd | 1 sekund före godkänns, exakt sluttid nekas | ⬜ |

## Auktionens tillstånd
Ej påbörjad → Aktiv → Avslutad. En admin kan avbryta en aktiv auktion (→ Avbruten).
Bud tillåts bara när auktionen är **Aktiv**.

## Resultat
- Vinnaren är den med högsta giltiga bud när sluttiden har passerats.
- Inga bud betyder ingen vinnare.

## Behörighet
- Man måste vara inloggad för att skapa auktioner och lägga bud (annars 401).
- Bara admin får avbryta en auktion (annars 403).