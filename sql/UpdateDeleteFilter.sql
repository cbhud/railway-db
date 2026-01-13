SET search_path = railway;

-- ====================================================================
-- 1. IZMJENA PODATAKA (UPDATE)
-- ====================================================================

-- SCENARIO: Povećanje plate/bonusa (simulirano kroz staž)
-- ŠTA RADIMO: Ažuriramo radni staž za zaposlenog sa ID-jem 1 (Marko Marković).
-- KAKO: Koristimo aritmetički operator '+' da uvećamo trenutnu vrijednost.
UPDATE employee
SET total_service_years = total_service_years + 1
WHERE employee_id = 1;

-- SCENARIO: Ažuriranje statusa vožnje
-- ŠTA RADIMO: Sve vožnje koje su bile planirane ('PLANNED'), a čije je vrijeme 
-- polaska prošlo (manje od TRENUTNOG vremena), prebacujemo u status 'COMPLETED'.
-- KAKO: Filtriramo po dva uslova koristeći operator AND.
UPDATE train_run
SET status = 'COMPLETED'
WHERE departure_time < NOW() 
  AND status = 'PLANNED';

-- SCENARIO: Promjena cijene karte
-- ŠTA RADIMO: Zbog greške operatera, mijenjamo sjedište i cijenu za konkretnu kartu (T-007).
-- KAKO: Identifikujemo red jedinstvenim brojem karte (ticket_no).
UPDATE ticket
SET seat_no = 18, 
    price_paid = 5.50
WHERE ticket_no = 'T-007';

-- ====================================================================
-- 2. BRISANJE PODATAKA (DELETE)
-- ====================================================================

-- SCENARIO: Brisanje otkazanih karata radi čišćenja baze
-- ŠTA RADIMO: Brišemo sve karte koje imaju status 'CANCELLED'.
-- KAKO: Jednostavno filtriranje po stringu statusa.
-- NAPOMENA: Zbog 'ON DELETE CASCADE' u tabeli 'payment', obrisaće se i uplate vezane za te karte.
DELETE FROM ticket
WHERE status = 'CANCELLED';

-- SCENARIO: Arhiviranje starih medicinskih pregleda
-- ŠTA RADIMO: Brišemo preglede koji su stariji od 1. januara 2015.
-- KAKO: Filtriramo datum (exam_date) koristeći operator '<'.
DELETE FROM medical_exam
WHERE exam_date < '2015-01-01';

-- ====================================================================
-- 3. PREGLED I FILTRIRANJE PODATAKA (SELECT)
-- ====================================================================

-- PRIMJER 1: Osnovno filtriranje (WHERE i OR)
-- CILJ: Pronaći sve vozače koji su veoma iskusni ILI voze jako dugo.
-- FILTRIRANJE: 
-- 1. Spajamo tabelu 'driver' sa 'employee' (JOIN) da dobijemo imena.
-- 2. Uslov: Sati vožnje > 2000 ILI staž > 15 godina.
SELECT 
    e.first_name, 
    e.last_name, 
    d.driving_hours_total,
    e.total_service_years
FROM driver d
JOIN employee e ON d.employee_id = e.employee_id
WHERE d.driving_hours_total > 2000 
   OR e.total_service_years > 15;

-- PRIMJER 2: Filtriranje po datumu i stringu (LIKE)
-- CILJ: Prikazati sve polaske vozova prema Baru za tekuću godinu.
-- FILTRIRANJE:
-- 1. Spajamo 'train_run' sa 'route' i 'station'.
-- 2. Uslov 1: Ime grada odredišta počinje sa 'Bar' (LIKE 'Bar%').
-- 3. Uslov 2: Datum polaska je u 2024. godini.
SELECT 
    r.route_code,
    tr.departure_time,
    s_dest.city AS destination,
    tr.status
FROM train_run tr
JOIN route r ON tr.route_id = r.route_id
JOIN station s_dest ON r.destination_station_id = s_dest.station_id
WHERE s_dest.city LIKE 'Bar%'
  AND tr.departure_time BETWEEN '2024-01-01' AND '2024-12-31';

-- PRIMJER 3: Agregacija i sortiranje (GROUP BY, HAVING, ORDER BY)
-- CILJ: Prikazati ukupnu zaradu od prodatih karata po zaposlenom, ali samo za one koji su prodali više od 10 EUR.
-- FILTRIRANJE:
-- 1. Sumiramo 'price_paid'.
-- 2. Grupišemo po imenu zaposlenog.
-- 3. HAVING: Filtriramo grupe (zaposlene) čija je suma manja od 10.
-- 4. ORDER BY: Sortiramo od najveće zarade ka najmanjoj.
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    COUNT(t.ticket_id) AS tickets_sold,
    SUM(t.price_paid) AS total_revenue
FROM ticket t
JOIN employee e ON t.sold_by_employee_id = e.employee_id
WHERE t.status = 'ACTIVE' -- Gledamo samo validne karte
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING SUM(t.price_paid) > 10
ORDER BY total_revenue DESC;

-- PRIMJER 4: Podupiti (Subqueries)
-- CILJ: Pronaći sve vozove koji NIKADA nisu bili raspoređeni na vožnju.
-- FILTRIRANJE:
-- Koristimo 'NOT IN' da nađemo train_id koji se ne nalazi u listi ID-jeva iz tabele train_run.
SELECT 
    t.train_code, 
    tt.type_name, 
    t.production_year
FROM train t
JOIN train_type tt ON t.train_type_id = tt.train_type_id
WHERE t.train_id NOT IN (
    SELECT DISTINCT train_id FROM train_run
);