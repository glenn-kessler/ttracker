-- Enable Foreign Key Support
PRAGMA foreign_keys = ON;

-- Primary Keys Table
-- name: alphanumeric and '-_', length 1-31
-- unit: alphanumeric and '-_', length 1-3
-- counter: 0...uint32_max
CREATE TABLE primary_keys
(
    name TEXT PRIMARY KEY CHECK ((length(name) < 32) AND (length(name) > 0) AND (name GLOB '[0-9a-zA-Z_-]*'))
    ,counter INTEGER      CHECK ((counter >= 0)AND(counter <= 4294967295)) DEFAULT 0
    ,unit TEXT            CHECK ((length(name) < 4) AND (length(name) > 0) AND (name GLOB '[0-9a-zA-Z_-]*')) DEFAULT '1'
);

-- Secondary Keys Table
-- increment Must not be 0
-- Latitude: valid range (-90 to 90)
-- Longitude: valid range (-180 to 180)
-- timestamp: must be within last 12 hours
-- primary_name: Links to primary key
-- Foreign key constraint ensures the primary_key exists
CREATE TABLE secondary_keys
(
    increment INTEGER CHECK (increment != 0) NOT NULL
    ,latitude REAL CHECK ((latitude >= -90) AND (latitude <= 90))
    ,longitude REAL CHECK ((longitude >= -180) AND (longitude <= 180))
    ,timestamp DATETIME NOT NULL CHECK (timestamp >= datetime('now', '-12 hours'))
    ,primary_name TEXT NOT NULL
    ,FOREIGN KEY (primary_name) REFERENCES primary_keys(name) ON DELETE CASCADE
);

-- Trigger to ensure primary_key exists before inserting into secondary_keys
-- Abort insertion if the primary_name does not exist in primary_keys
CREATE TRIGGER validate_primary_key_exists
BEFORE INSERT ON secondary_keys
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Primary key does not exist')
    WHERE NOT EXISTS (SELECT 1 FROM primary_keys WHERE name = NEW.primary_name);
END;

-- Ensure a secondary key is provided when inserting a primary key
-- Abort insertion if no secondary key exists for the new primary key
CREATE TRIGGER enforce_secondary_key
BEFORE INSERT ON primary_keys
BEGIN
    SELECT RAISE(ABORT, 'A secondary key with increment != 0 is required')
    WHERE NOT EXISTS (SELECT 1 FROM secondary_keys WHERE primary_name = NEW.name AND increment != 0);
END;

-- Prevent secondary_key insertion if (primary_key.counter + increment) < 0
-- Check if primary_key.counter + increment would go negative
CREATE TRIGGER validate_secondary_key
BEFORE INSERT ON secondary_keys
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Invalid increment: counter + increment cannot be negative')
    FROM primary_keys WHERE (primary_keys.name = NEW.primary_name) AND (primary_keys.counter + NEW.increment) < 0;
END;
