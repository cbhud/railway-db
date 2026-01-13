SET search_path = railway;

-- Opciono: Očisti podatke ako postoje (resetuje i ID brojače)
TRUNCATE payment, ticket, passenger, train_run, timetable, route_stop, route, train, driver_train_type, train_type, medical_exam, driver, employee, fare_plan, station, audit_log RESTART IDENTITY CASCADE;

-- =============================================
-- 1. ZAPOSLENI (10 komada: 5 vozača, 5 ostalih)
-- =============================================
INSERT INTO employee (first_name, last_name, jmbg, hire_date, total_service_years) VALUES
('Marko', 'Marković', '0101980123456', '2010-05-01', 13), -- ID 1 (Vozač)
('Petar', 'Petrović', '0202985654321', '2015-03-15', 8),  -- ID 2 (Vozač)
('Jovan', 'Jovanović', '0303990112233', '2018-06-20', 5), -- ID 3 (Vozač)
('Savo', 'Savić', '0404975998877', '2005-01-10', 18),     -- ID 4 (Vozač)
('Nikola', 'Nikolić', '0505988776655', '2020-02-01', 3),  -- ID 5 (Vozač)
('Ana', 'Anić', '0606991554433', '2012-09-01', 11),       -- ID 6 (Šalter)
('Milica', 'Milić', '0707992223344', '2019-11-15', 4),    -- ID 7 (Šalter)
('Ivana', 'Ivanović', '0808983991122', '2021-05-05', 2),  -- ID 8 (Admin)
('Darko', 'Darković', '0909974885522', '2008-08-08', 15), -- ID 9 (Admin)
('Elena', 'Elenić', '1010995774411', '2022-01-10', 1);    -- ID 10 (Šalter)

-- =============================================
-- 2. VOZAČI (5 komada, vezani za Employee ID 1-5)
-- =============================================
INSERT INTO driver (employee_id, driving_hours_total) VALUES
(1, 1500.5),
(2, 850.0),
(3, 320.0),
(4, 2100.0),
(5, 120.5);

-- =============================================
-- 3. MEDICINSKI PREGLEDI (10 komada)
-- =============================================
INSERT INTO medical_exam (driver_id, exam_date, report) VALUES
(1, '2023-01-15', 'Sposoban za vožnju. Vid uredan.'),
(2, '2023-02-20', 'Sposoban. Manja dioptrija korigovana naočarima.'),
(3, '2023-03-10', 'Sposoban. Krvni pritisak u granicama normale.'),
(4, '2023-01-05', 'Sposoban. Preporučena fizička aktivnost.'),
(5, '2023-04-01', 'Sposoban bez ograničenja.'),
(1, '2024-01-10', 'Redovni godišnji pregled. Sposoban.'),
(2, '2024-02-15', 'Redovni godišnji pregled. Sposoban.'),
(3, '2024-03-05', 'Redovni godišnji pregled. Sposoban.'),
(4, '2024-01-08', 'Redovni godišnji pregled. Sposoban.'),
(5, '2024-03-25', 'Redovni godišnji pregled. Sposoban.');

-- =============================================
-- 4. TIPOVI VOZOVA (5 komada)
-- =============================================
INSERT INTO train_type (type_name) VALUES
('Putnički - Lokalni'),
('Putnički - Brzi'),
('Teretni - Standard'),
('Teretni - Teški'),
('VIP Charter');

-- =============================================
-- 5. LICENCE VOZAČA (10 komada)
-- =============================================
INSERT INTO driver_train_type (driver_id, train_type_id, authorized_from) VALUES
(1, 1, '2010-06-01'), (1, 2, '2015-01-01'), -- Vozač 1 vozi lokalni i brzi
(2, 1, '2015-04-01'), (2, 3, '2016-01-01'), -- Vozač 2 vozi lokalni i teretni
(3, 1, '2018-07-01'),
(4, 3, '2005-02-01'), (4, 4, '2010-01-01'), -- Vozač 4 je za teretne
(5, 1, '2020-03-01'), (5, 5, '2021-01-01'), -- Vozač 5 vozi lokalni i VIP
(3, 2, '2019-01-01');

-- =============================================
-- 6. VOZOVI (10 komada)
-- =============================================
INSERT INTO train (train_code, max_cars, production_year, train_type_id) VALUES
('VL-101', 4, 1985, 1), -- Lokalni
('VL-102', 4, 1990, 1),
('VB-201', 6, 2015, 2), -- Brzi (CAF)
('VB-202', 6, 2016, 2),
('VB-203', 6, 2018, 2),
('TS-301', 20, 1980, 3), -- Teretni
('TS-302', 25, 1982, 3),
('TT-401', 30, 1975, 4), -- Teški teretni
('VC-501', 3, 2020, 5),  -- VIP
('VL-103', 4, 1995, 1);

-- =============================================
-- 7. STANICE (10 komada)
-- =============================================
INSERT INTO station (station_name, city, country_code) VALUES
('Glavna Stanica', 'Podgorica', 'ME'),
('Stanica Bar', 'Bar', 'ME'),
('Stanica Nikšić', 'Nikšić', 'ME'),
('Stanica Bijelo Polje', 'Bijelo Polje', 'ME'),
('Stanica Kolašin', 'Kolašin', 'ME'),
('Stanica Mojkovac', 'Mojkovac', 'ME'),
('Stanica Spuž', 'Spuž', 'ME'),
('Stanica Virpazar', 'Virpazar', 'ME'),
('Stanica Sutomore', 'Sutomore', 'ME'),
('Glavna Stanica', 'Beograd', 'RS');

-- =============================================
-- 8. RELACIJE (10 komada)
-- =============================================
INSERT INTO route (route_code, origin_station_id, destination_station_id, distance_km) VALUES
('R-PG-BR', 1, 2, 54.0),   -- PG -> Bar
('R-BR-PG', 2, 1, 54.0),   -- Bar -> PG
('R-PG-NK', 1, 3, 53.5),   -- PG -> NK
('R-NK-PG', 3, 1, 53.5),   -- NK -> PG
('R-PG-BP', 1, 4, 120.0),  -- PG -> BP
('R-BP-PG', 4, 1, 120.0),  -- BP -> PG
('R-PG-BG', 1, 10, 470.0), -- PG -> BG
('R-BG-PG', 10, 1, 470.0), -- BG -> PG
('R-BR-BG', 2, 10, 524.0), -- Bar -> BG
('R-BG-BR', 10, 2, 524.0); -- BG -> Bar

-- =============================================
-- 9. MEĐUSTANICE (Route Stops - 10 komada)
-- =============================================
INSERT INTO route_stop (route_id, stop_no, station_id, minutes_from_start) VALUES
(1, 1, 8, 30),  -- PG->Bar staje u Virpazaru
(1, 2, 9, 45),  -- PG->Bar staje u Sutomoru
(2, 1, 9, 10),  -- Bar->PG staje u Sutomoru
(2, 2, 8, 25),  -- Bar->PG staje u Virpazaru
(3, 1, 7, 15),  -- PG->NK staje u Spužu
(4, 1, 7, 35),  -- NK->PG staje u Spužu
(5, 1, 5, 60),  -- PG->BP staje u Kolašinu
(5, 2, 6, 85),  -- PG->BP staje u Mojkovcu
(6, 1, 6, 35),  -- BP->PG staje u Mojkovcu
(6, 2, 5, 60);  -- BP->PG staje u Kolašinu

-- =============================================
-- 10. CJENOVNICI (5 komada)
-- =============================================
INSERT INTO fare_plan (regular_price, vip_price, currency, valid_from, valid_to) VALUES
(5.00, 8.00, 'EUR', '2023-01-01', '2023-12-31'),   -- Stari cjenovnik
(2.00, 3.50, 'EUR', '2023-01-01', NULL),           -- Lokal
(6.00, 10.00, 'EUR', '2024-01-01', NULL),          -- Novi standard
(25.00, 40.00, 'EUR', '2024-01-01', NULL),         -- Međunarodni
(3.00, 5.00, 'EUR', '2024-06-01', '2024-09-01');   -- Sezonski

-- =============================================
-- 11. RED VOŽNJE - TIMETABLE (5 komada)
-- =============================================
INSERT INTO timetable (created_by_employee_id, valid_from, valid_to, description) VALUES
(9, '2024-01-01', '2024-06-01', 'Zimski red vožnje 2024'),
(9, '2024-06-02', '2024-09-01', 'Ljetnji red vožnje 2024'),
(8, '2024-09-02', '2024-12-31', 'Jesenji red vožnje 2024'),
(8, '2025-01-01', '2025-06-01', 'Zimski red vožnje 2025'),
(9, '2023-01-01', '2023-12-31', 'Arhiva 2023');

-- =============================================
-- 12. KONKRETNE VOŽNJE - TRAIN RUN (10 komada)
-- =============================================
-- Povezujemo Timetable, Route, Train, Driver, FarePlan
INSERT INTO train_run (timetable_id, route_id, train_id, driver_id, departure_time, regular_seats, vip_seats, fare_plan_id, status) VALUES
(1, 1, 3, 1, '2024-02-01 08:00:00+01', 100, 20, 3, 'COMPLETED'), -- PG-BR
(1, 2, 3, 1, '2024-02-01 12:00:00+01', 100, 20, 3, 'COMPLETED'), -- BR-PG
(1, 3, 1, 2, '2024-02-02 07:30:00+01', 80, 0, 2, 'COMPLETED'),   -- PG-NK
(1, 5, 5, 1, '2024-02-03 09:00:00+01', 120, 30, 3, 'COMPLETED'), -- PG-BP
(2, 1, 9, 5, '2024-07-01 10:00:00+02', 50, 50, 5, 'COMPLETED'),  -- VIP PG-BR
(4, 1, 3, 1, NOW() + INTERVAL '2 days', 100, 20, 3, 'PLANNED'),  -- Buduća vožnja
(4, 7, 4, 3, NOW() + INTERVAL '1 day', 200, 50, 4, 'PLANNED'),   -- Buduća PG-BG
(4, 3, 2, 2, NOW() + INTERVAL '5 hours', 80, 0, 2, 'PLANNED'),   -- Buduća PG-NK
(4, 1, 3, 1, NOW() - INTERVAL '2 hours', 100, 20, 3, 'PLANNED'), -- Upravo kreće (kasni status update)
(1, 1, 1, 1, '2024-02-10 08:00:00+01', 100, 0, 3, 'CANCELLED');

-- =============================================
-- 13. PUTNICI (10 komada)
-- =============================================
INSERT INTO passenger (first_name, last_name, document_no) VALUES
('Milan', 'Milanović', 'D11111'),
('Sanja', 'Sanjić', 'D22222'),
('Ivan', 'Ivanov', 'P12345'), -- Stranac
('John', 'Smith', 'USA999'),
('Dragan', 'Dragić', 'D33333'),
('Maja', 'Majić', 'D44444'),
('Luka', 'Lukić', 'D55555'),
('Sara', 'Sarić', 'D66666'),
('Bojan', 'Bojanić', 'D77777'),
('Vesna', 'Vesnić', 'D88888');

-- =============================================
-- 14. KARTE (10 komada)
-- =============================================
INSERT INTO ticket (ticket_no, run_id, passenger_id, seat_type, seat_no, sold_by_employee_id, price_paid, currency, status) VALUES
('T-001', 1, 1, 'REGULAR', 1, 6, 6.00, 'EUR', 'ACTIVE'),
('T-002', 1, 2, 'REGULAR', 2, 6, 6.00, 'EUR', 'ACTIVE'),
('T-003', 1, 3, 'VIP', 1, 6, 10.00, 'EUR', 'ACTIVE'),
('T-004', 2, 4, 'REGULAR', 5, 7, 6.00, 'EUR', 'ACTIVE'),
('T-005', 3, 5, 'REGULAR', 10, 7, 2.00, 'EUR', 'ACTIVE'),
('T-006', 5, 1, 'VIP', 1, 10, 5.00, 'EUR', 'ACTIVE'),
('T-007', 6, 6, 'REGULAR', 15, 6, 6.00, 'EUR', 'ACTIVE'), -- Karta za buduću vožnju
('T-008', 6, 7, 'REGULAR', 16, 6, 6.00, 'EUR', 'ACTIVE'),
('T-009', 10, 8, 'REGULAR', 5, 7, 6.00, 'EUR', 'CANCELLED'), -- Za otkazani voz
('T-010', 7, 9, 'VIP', 2, 6, 40.00, 'EUR', 'ACTIVE');

-- =============================================
-- 15. PLAĆANJA (10 komada)
-- =============================================
INSERT INTO payment (ticket_id, method, amount, currency, transaction_ref) VALUES
(1, 'CASH', 6.00, 'EUR', NULL),
(2, 'CASH', 6.00, 'EUR', NULL),
(3, 'CARD', 10.00, 'EUR', 'TXN-12345'),
(4, 'ONLINE', 6.00, 'EUR', 'WEB-99999'),
(5, 'CASH', 2.00, 'EUR', NULL),
(6, 'CARD', 5.00, 'EUR', 'TXN-67890'),
(7, 'ONLINE', 6.00, 'EUR', 'WEB-88888'),
(8, 'ONLINE', 6.00, 'EUR', 'WEB-77777'),
(9, 'CASH', 6.00, 'EUR', NULL), -- Plaćeno pa otkazano (refund bi išao naknadno)
(10, 'CARD', 40.00, 'EUR', 'TXN-11122');