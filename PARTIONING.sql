-- ============================================
-- PARTITIONED sensor_readings - FIXED VERSION
-- ============================================



-- Drop existing table


-- Recreate with COMPOSITE primary key (includes partitioning column)
CREATE TABLE sensor_readings (
    reading_id BIGINT AUTO_INCREMENT,
    bandage_id INT NOT NULL,
    reading_time DATETIME NOT NULL,
    ph_value DECIMAL(3,2) CHECK(ph_value BETWEEN 0 AND 14),
    oxygen_percent DECIMAL(5,2) CHECK(oxygen_percent BETWEEN 0 AND 100),
    temperature_celsius DECIMAL(4,2) CHECK(temperature_celsius BETWEEN 20 AND 45),
    enzyme_index DECIMAL(6,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (reading_id, reading_time),  -- COMPOSITE KEY including partition column
    INDEX idx_bandage_id (bandage_id),
    INDEX idx_reading_time (reading_time)
) ENGINE=InnoDB
PARTITION BY RANGE (YEAR(reading_time) * 100 + MONTH(reading_time)) (
    PARTITION p_2025_01 VALUES LESS THAN (202502),
    PARTITION p_2025_02 VALUES LESS THAN (202503),
    PARTITION p_2025_03 VALUES LESS THAN (202504),
    PARTITION p_2025_04 VALUES LESS THAN (202505),
    PARTITION p_2025_05 VALUES LESS THAN (202506),
    PARTITION p_2025_06 VALUES LESS THAN (202507),
    PARTITION p_2025_07 VALUES LESS THAN (202508),
    PARTITION p_2025_08 VALUES LESS THAN (202509),
    PARTITION p_2025_09 VALUES LESS THAN (202510),
    PARTITION p_2025_10 VALUES LESS THAN (202511),
    PARTITION p_2025_11 VALUES LESS THAN (202512),
    PARTITION p_2025_12 VALUES LESS THAN (202513),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Verify partitions were created
SELECT 
    PARTITION_NAME, 
    PARTITION_METHOD,
    PARTITION_EXPRESSION,
    TABLE_ROWS 
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_SCHEMA = 'wound_healing_db' 
AND TABLE_NAME = 'sensor_readings'
ORDER BY PARTITION_ORDINAL_POSITION;