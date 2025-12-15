-- ============================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ============================================



-- ============================================
-- 1. B-TREE INDEXES (for searching & sorting)
-- ============================================

-- Index on sensor_readings.reading_time (TIME-SERIES QUERIES)
-- Used when: SELECT * FROM sensor_readings WHERE reading_time > '2025-11-01'
CREATE INDEX idx_reading_time ON sensor_readings(reading_time);

-- Index on sensor_readings.bandage_id (FOREIGN KEY LOOKUPS)
-- Used when: SELECT * FROM sensor_readings WHERE bandage_id = 5
CREATE INDEX idx_sensor_bandage ON sensor_readings(bandage_id);

-- Composite index for common query pattern
-- Used when: SELECT * FROM sensor_readings WHERE bandage_id = 5 AND reading_time > '2025-11-01'
CREATE INDEX idx_bandage_time ON sensor_readings(bandage_id, reading_time);

-- Index on alerts.status (FILTER ACTIVE ALERTS)
-- Used when: SELECT * FROM alerts WHERE status = 'active'
CREATE INDEX idx_alert_status ON alerts(status);

-- Index on alerts.triggered_at (RECENT ALERTS)
-- Used when: SELECT * FROM alerts WHERE triggered_at > NOW() - INTERVAL 24 HOUR
CREATE INDEX idx_alert_triggered ON alerts(triggered_at);

-- Composite index for alert queries
CREATE INDEX idx_alert_patient_status ON alerts(patient_id, status);

-- Index on bandages.patient_id (PATIENT WOUND HISTORY)
CREATE INDEX idx_bandage_patient ON bandages(patient_id);

-- Index on bandages.status (ACTIVE BANDAGES)
CREATE INDEX idx_bandage_status ON bandages(status);

-- ============================================
-- 2. HASH INDEXES (for exact lookups)
-- ============================================

-- Note: InnoDB doesn't support explicit HASH indexes, but uses hash for unique constraints
-- These are already optimized via UNIQUE constraints:
-- - users.username
-- - users.email
-- - devices.device_serial
-- - bandages.bandage_serial

-- ============================================
-- 3. FULLTEXT INDEX (for text search)
-- ============================================

-- FULLTEXT index on patients.notes (SEARCH PATIENT NOTES)
-- Used when: SELECT * FROM patients WHERE MATCH(notes) AGAINST('diabetes' IN NATURAL LANGUAGE MODE)
CREATE FULLTEXT INDEX idx_patient_notes_fulltext ON patients(notes);

-- ============================================
-- VERIFY INDEXES CREATED
-- ============================================

-- Show all indexes on sensor_readings table
SHOW INDEX FROM sensor_readings;

-- Show all indexes on alerts table
SHOW INDEX FROM alerts;

-- Show all indexes on patients table
SHOW INDEX FROM patients;