-- =========================
-- SCHEMA
-- =========================
CREATE SCHEMA IF NOT EXISTS railway;
SET search_path = railway;

-- =========================
-- EMPLOYEES + DRIVERS
-- =========================
CREATE TABLE employee (
  employee_id           BIGSERIAL PRIMARY KEY,
  jmbg                  CHAR(13) NOT NULL UNIQUE
                         CHECK (jmbg ~ '^[0-9]{13}$'),
  first_name            VARCHAR(50) NOT NULL,
  last_name             VARCHAR(50) NOT NULL,
  hire_date             DATE NOT NULL CHECK (hire_date <= CURRENT_DATE),
  total_service_years   INT NOT NULL CHECK (total_service_years >= 0)
);

-- specialization: driver is an employee
CREATE TABLE driver (
  employee_id           BIGINT PRIMARY KEY,
  driving_hours_total   NUMERIC(10,1) NOT NULL DEFAULT 0
                         CHECK (driving_hours_total >= 0),
  CONSTRAINT fk_driver_employee
    FOREIGN KEY (employee_id)
    REFERENCES employee(employee_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE medical_exam (
  exam_id               BIGSERIAL PRIMARY KEY,
  driver_id             BIGINT NOT NULL,
  exam_date             DATE NOT NULL CHECK (exam_date <= CURRENT_DATE),
  report                VARCHAR(250) NOT NULL,
  CONSTRAINT fk_exam_driver
    FOREIGN KEY (driver_id)
    REFERENCES driver(employee_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT uq_exam UNIQUE (driver_id, exam_date)
);

-- =========================
-- TRAIN TYPES + TRAINS
-- =========================
CREATE TABLE train_type (
  train_type_id         BIGSERIAL PRIMARY KEY,
  type_name             VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE driver_train_type (
  driver_id             BIGINT NOT NULL,
  train_type_id         BIGINT NOT NULL,
  authorized_from       DATE NOT NULL DEFAULT CURRENT_DATE,
  authorized_until      DATE,
  PRIMARY KEY (driver_id, train_type_id),
  CONSTRAINT fk_dtt_driver
    FOREIGN KEY (driver_id)
    REFERENCES driver(employee_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_dtt_type
    FOREIGN KEY (train_type_id)
    REFERENCES train_type(train_type_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT chk_auth_dates
    CHECK (authorized_until IS NULL OR authorized_until >= authorized_from)
);

CREATE TABLE train (
  train_id              BIGSERIAL PRIMARY KEY,
  train_code            VARCHAR(20) NOT NULL UNIQUE,
  max_cars              INT NOT NULL CHECK (max_cars BETWEEN 1 AND 50),
  production_year       INT NOT NULL
                         CHECK (production_year BETWEEN 1950 AND (EXTRACT(YEAR FROM CURRENT_DATE)::INT + 1)),
  train_type_id         BIGINT NOT NULL,
  CONSTRAINT fk_train_type
    FOREIGN KEY (train_type_id)
    REFERENCES train_type(train_type_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

-- =========================
-- STATIONS + ROUTES
-- =========================
CREATE TABLE station (
  station_id            BIGSERIAL PRIMARY KEY,
  station_name          VARCHAR(80) NOT NULL,
  city                  VARCHAR(80) NOT NULL,
  country_code          CHAR(2) NOT NULL CHECK (country_code ~ '^[A-Z]{2}$'),
  UNIQUE (station_name, city, country_code)
);

CREATE TABLE route (
  route_id              BIGSERIAL PRIMARY KEY,
  route_code            VARCHAR(30) NOT NULL UNIQUE,
  origin_station_id     BIGINT NOT NULL,
  destination_station_id BIGINT NOT NULL,
  distance_km           NUMERIC(7,1) NOT NULL CHECK (distance_km > 0),
  CONSTRAINT fk_route_origin
    FOREIGN KEY (origin_station_id) REFERENCES station(station_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_route_dest
    FOREIGN KEY (destination_station_id) REFERENCES station(station_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_route_diff CHECK (origin_station_id <> destination_station_id)
);

-- optional: intermediate stops for richer ER model
CREATE TABLE route_stop (
  route_id              BIGINT NOT NULL,
  stop_no               SMALLINT NOT NULL CHECK (stop_no > 0),
  station_id            BIGINT NOT NULL,
  minutes_from_start    INT NOT NULL CHECK (minutes_from_start >= 0),
  PRIMARY KEY (route_id, stop_no),
  UNIQUE (route_id, station_id),
  CONSTRAINT fk_rs_route
    FOREIGN KEY (route_id) REFERENCES route(route_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_rs_station
    FOREIGN KEY (station_id) REFERENCES station(station_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- =========================
-- FARES + TIMETABLES + RUNS
-- =========================
CREATE TABLE fare_plan (
  fare_plan_id          BIGSERIAL PRIMARY KEY,
  regular_price         NUMERIC(10,2) NOT NULL CHECK (regular_price > 0),
  vip_price             NUMERIC(10,2) NOT NULL CHECK (vip_price > regular_price),
  currency              CHAR(3) NOT NULL CHECK (currency ~ '^[A-Z]{3}$'),
  valid_from            DATE NOT NULL,
  valid_to              DATE,
  CONSTRAINT chk_fare_dates CHECK (valid_to IS NULL OR valid_to >= valid_from)
);

CREATE TABLE timetable (
  timetable_id          BIGSERIAL PRIMARY KEY,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by_employee_id BIGINT,
  valid_from            DATE NOT NULL,
  valid_to              DATE NOT NULL,
  description           TEXT,
  CONSTRAINT fk_tt_creator
    FOREIGN KEY (created_by_employee_id) REFERENCES employee(employee_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT chk_tt_dates CHECK (valid_to >= valid_from)
);

CREATE TABLE train_run (
  run_id                BIGSERIAL PRIMARY KEY,
  timetable_id          BIGINT NOT NULL,
  route_id              BIGINT NOT NULL,
  train_id              BIGINT NOT NULL,
  driver_id             BIGINT NOT NULL,
  departure_time        TIMESTAMPTZ NOT NULL,
  regular_seats         INT NOT NULL CHECK (regular_seats >= 0),
  vip_seats             INT NOT NULL CHECK (vip_seats >= 0),
  fare_plan_id          BIGINT NOT NULL,
  status                VARCHAR(12) NOT NULL DEFAULT 'PLANNED'
                         CHECK (status IN ('PLANNED','CANCELLED','COMPLETED')),
  CONSTRAINT fk_run_tt
    FOREIGN KEY (timetable_id) REFERENCES timetable(timetable_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_run_route
    FOREIGN KEY (route_id) REFERENCES route(route_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_run_train
    FOREIGN KEY (train_id) REFERENCES train(train_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_run_driver
    FOREIGN KEY (driver_id) REFERENCES driver(employee_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_run_fare
    FOREIGN KEY (fare_plan_id) REFERENCES fare_plan(fare_plan_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- =========================
-- PASSENGERS + TICKETS + PAYMENTS
-- =========================
CREATE TABLE passenger (
  passenger_id          BIGSERIAL PRIMARY KEY,
  first_name            VARCHAR(50) NOT NULL,
  last_name             VARCHAR(50) NOT NULL,
  document_no           VARCHAR(30) UNIQUE,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE ticket (
  ticket_id             BIGSERIAL PRIMARY KEY,
  ticket_no             VARCHAR(30) NOT NULL UNIQUE,
  run_id                BIGINT NOT NULL,
  passenger_id          BIGINT NOT NULL,
  seat_type             VARCHAR(10) NOT NULL CHECK (seat_type IN ('REGULAR','VIP')),
  seat_no               INT NOT NULL CHECK (seat_no > 0),
  sold_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  sold_by_employee_id   BIGINT,
  price_paid            NUMERIC(10,2) NOT NULL CHECK (price_paid > 0),
  currency              CHAR(3) NOT NULL CHECK (currency ~ '^[A-Z]{3}$'),
  status                VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'
                         CHECK (status IN ('ACTIVE','CANCELLED','REFUNDED')),
  CONSTRAINT fk_ticket_run
    FOREIGN KEY (run_id) REFERENCES train_run(run_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ticket_passenger
    FOREIGN KEY (passenger_id) REFERENCES passenger(passenger_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_ticket_seller
    FOREIGN KEY (sold_by_employee_id) REFERENCES employee(employee_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT uq_ticket_seat UNIQUE (run_id, seat_no)
);

CREATE TABLE payment (
  payment_id            BIGSERIAL PRIMARY KEY,
  ticket_id             BIGINT NOT NULL UNIQUE,
  method                VARCHAR(15) NOT NULL CHECK (method IN ('CASH','CARD','ONLINE')),
  paid_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  amount                NUMERIC(10,2) NOT NULL CHECK (amount > 0),
  currency              CHAR(3) NOT NULL CHECK (currency ~ '^[A-Z]{3}$'),
  transaction_ref       VARCHAR(60) UNIQUE,
  CONSTRAINT fk_payment_ticket
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- =========================
-- AUDIT (for trigger demo)
-- =========================
CREATE TABLE audit_log (
  audit_id              BIGSERIAL PRIMARY KEY,
  table_name            TEXT NOT NULL,
  action                TEXT NOT NULL CHECK (action IN ('INSERT','UPDATE','DELETE')),
  row_pk                TEXT NOT NULL,
  changed_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  changed_by_employee_id BIGINT,
  old_data              JSONB,
  new_data              JSONB,
  CONSTRAINT fk_audit_employee
    FOREIGN KEY (changed_by_employee_id) REFERENCES employee(employee_id)
    ON DELETE SET NULL ON UPDATE CASCADE
);

-- =========================
-- INDEXES (starter set)
-- =========================
CREATE INDEX idx_run_departure_time ON train_run(departure_time);
CREATE INDEX idx_run_route_time ON train_run(route_id, departure_time);

CREATE INDEX idx_ticket_run ON ticket(run_id);

CREATE INDEX idx_payment_paid_at ON payment(paid_at);
CREATE INDEX idx_audit_table_time ON audit_log(table_name, changed_at DESC);
