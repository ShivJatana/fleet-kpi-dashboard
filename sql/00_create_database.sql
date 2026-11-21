-- =====================================================================
-- STEP 0: CREATE THE DATABASE (run once)
-- 1. DB Browser for SQLite -> New Database -> save as fleet.db
-- 2. Execute SQL tab -> paste this file -> Run -> Write Changes
-- 3. File -> Import -> Table from CSV file -> select all 5 files in data/
--    (tick "Column names in first line"; import into the existing tables)
-- 4. Write Changes (Ctrl+S)
-- =====================================================================

CREATE TABLE trucks (
    truck_id     TEXT PRIMARY KEY,
    make_model   TEXT,
    model_year   INTEGER,
    odometer_km  INTEGER      -- at the start of the period
);

CREATE TABLE drivers (
    driver_id         TEXT PRIMARY KEY,
    driver_type       TEXT,   -- Long haul, Regional, Local
    years_experience  INTEGER
);

CREATE TABLE lanes (
    lane_id      TEXT PRIMARY KEY,
    origin       TEXT,
    destination  TEXT,
    distance_km  INTEGER,
    lane_type    TEXT         -- Domestic, Cross-border, Local (GTA)
);

CREATE TABLE loads (
    load_id             TEXT PRIMARY KEY,
    dispatch_date       TEXT,
    truck_id            TEXT REFERENCES trucks(truck_id),
    driver_id           TEXT REFERENCES drivers(driver_id),
    lane_id             TEXT REFERENCES lanes(lane_id),
    scheduled_delivery  TEXT,  -- YYYY-MM-DD HH:MM
    actual_delivery     TEXT,
    distance_km         INTEGER
);

CREATE TABLE maintenance_events (
    event_id        TEXT PRIMARY KEY,
    event_date      TEXT,
    truck_id        TEXT REFERENCES trucks(truck_id),
    event_type      TEXT,     -- Preventive or Unplanned
    category        TEXT,
    downtime_hours  REAL,
    cost_cad        INTEGER
);
