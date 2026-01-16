-- Prvo brišemo postojeće indekse nad datumom prodaje da bismo mjerili 'sporo' stanje
DROP INDEX IF EXISTS idx_ticket_sold_at;

-- Generisanje 100.000 nasumičnih karata
-- Ovo može potrajati par sekundi
INSERT INTO ticket (ticket_no, run_id, passenger_id, seat_type, seat_no, sold_by_employee_id, price_paid, currency, status, sold_at)
SELECT 
    'GEN-' || i,             -- ticket_no
    1,                       -- run_id (vežemo sve za prvu vožnju radi jednostavnosti)
    1,                       -- passenger_id
    CASE WHEN i % 10 = 0 THEN 'VIP' ELSE 'REGULAR' END, -- svaki 10. je VIP
    i + 100,                 -- seat_no (da ne bude duplikata)
    6,                       -- sold_by_employee_id
    5.00, 
    'EUR', 
    'ACTIVE',
    -- Nasumičan datum u toku 2023. i 2024. godine
    '2023-01-01'::timestamptz + (random() * (interval '2 years'))
FROM generate_series(1, 100000) AS i;