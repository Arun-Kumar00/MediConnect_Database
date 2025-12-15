-- ============================================
-- STORED PROCEDURES
-- ============================================

USE wound_healing_db;

-- ============================================
-- PROCEDURE 1: Calculate Healing Score for a Patient
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_calculate_healing_score(
    IN p_patient_id INT,
    OUT p_healing_score DECIMAL(5,2),
    OUT p_status VARCHAR(20)
)
BEGIN
    DECLARE v_avg_ph DECIMAL(3,2);
    DECLARE v_avg_oxygen DECIMAL(5,2);
    DECLARE v_avg_temp DECIMAL(4,2);
    DECLARE v_alert_count INT;
    
    -- Get average sensor values for last 24 hours
    SELECT 
        AVG(sr.ph_value),
        AVG(sr.oxygen_percent),
        AVG(sr.temperature_celsius)
    INTO 
        v_avg_ph,
        v_avg_oxygen,
        v_avg_temp
    FROM sensor_readings sr
    JOIN bandages b ON sr.bandage_id = b.bandage_id
    WHERE b.patient_id = p_patient_id
    AND sr.reading_time > NOW() - INTERVAL 24 HOUR;
    
    -- Count active alerts
    SELECT COUNT(*) INTO v_alert_count
    FROM alerts
    WHERE patient_id = p_patient_id
    AND status = 'active';
    
    -- Calculate healing score (0-100)
    -- Good pH = 7.0-7.4 (neutral to slightly alkaline for healing)
    -- Good oxygen = > 80%
    -- Good temp = 36-37°C
    SET p_healing_score = 
        CASE 
            WHEN v_avg_ph IS NULL THEN 0
            ELSE
                (CASE 
                    WHEN v_avg_ph BETWEEN 7.0 AND 7.4 THEN 30
                    WHEN v_avg_ph BETWEEN 6.5 AND 7.8 THEN 20
                    ELSE 10
                END) +
                (CASE 
                    WHEN v_avg_oxygen >= 80 THEN 40
                    WHEN v_avg_oxygen >= 60 THEN 25
                    ELSE 10
                END) +
                (CASE 
                    WHEN v_avg_temp BETWEEN 36.0 AND 37.5 THEN 30
                    WHEN v_avg_temp BETWEEN 35.5 AND 38.0 THEN 20
                    ELSE 10
                END) -
                (v_alert_count * 5)  -- Subtract 5 points per alert
        END;
    
    -- Ensure score is between 0-100
    SET p_healing_score = GREATEST(0, LEAST(100, p_healing_score));
    
    -- Determine status
    SET p_status = CASE 
        WHEN p_healing_score >= 80 THEN 'Excellent'
        WHEN p_healing_score >= 60 THEN 'Good'
        WHEN p_healing_score >= 40 THEN 'Fair'
        WHEN p_healing_score >= 20 THEN 'Poor'
        ELSE 'Critical'
    END;
    
END$$

DELIMITER ;

-- ============================================
-- PROCEDURE 2: Generate Daily Summary Report
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_daily_summary_report(IN p_date DATE)
BEGIN
    SELECT 
        p.patient_id,
        CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        p.wound_type,
        b.bandage_serial,
        COUNT(sr.reading_id) AS total_readings,
        AVG(sr.ph_value) AS avg_ph,
        AVG(sr.oxygen_percent) AS avg_oxygen,
        AVG(sr.temperature_celsius) AS avg_temp,
        MAX(sr.enzyme_index) AS max_enzyme,
        COUNT(DISTINCT a.alert_id) AS alert_count
    FROM patients p
    JOIN bandages b ON p.patient_id = b.patient_id
    LEFT JOIN sensor_readings sr ON b.bandage_id = sr.bandage_id 
        AND DATE(sr.reading_time) = p_date
    LEFT JOIN alerts a ON b.bandage_id = a.bandage_id 
        AND DATE(a.triggered_at) = p_date
    WHERE b.status = 'active'
    GROUP BY p.patient_id, b.bandage_id
    ORDER BY alert_count DESC, avg_ph DESC;
END$$

DELIMITER ;

-- ============================================
-- PROCEDURE 3: Get Patient Wound History
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_patient_wound_history(IN p_patient_id INT)
BEGIN
    -- Patient basic info
    SELECT 
        patient_id,
        CONCAT(first_name, ' ', last_name) AS full_name,
        wound_type,
        wound_location,
        wound_size_cm2,
        admission_date,
        DATEDIFF(NOW(), admission_date) AS days_admitted
    FROM patients
    WHERE patient_id = p_patient_id;
    
    -- Active bandages
    SELECT 
        bandage_id,
        bandage_serial,
        application_date,
        status,
        DATEDIFF(NOW(), application_date) AS days_active
    FROM bandages
    WHERE patient_id = p_patient_id;
    
    -- Recent sensor readings (last 10)
    SELECT 
        sr.reading_time,
        sr.ph_value,
        sr.oxygen_percent,
        sr.temperature_celsius,
        sr.enzyme_index
    FROM sensor_readings sr
    JOIN bandages b ON sr.bandage_id = b.bandage_id
    WHERE b.patient_id = p_patient_id
    ORDER BY sr.reading_time DESC
    LIMIT 10;
    
    -- Active alerts
    SELECT 
        alert_type,
        severity,
        message,
        triggered_at
    FROM alerts
    WHERE patient_id = p_patient_id
    AND status = 'active'
    ORDER BY triggered_at DESC;
END$$

DELIMITER ;

-- ============================================
-- PROCEDURE 4: Archive Old Sensor Data
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_archive_old_readings(IN p_days_old INT)
BEGIN
    DECLARE v_archived_count INT;
    
    -- Count records to be archived
    SELECT COUNT(*) INTO v_archived_count
    FROM sensor_readings
    WHERE reading_time < NOW() - INTERVAL p_days_old DAY;
    
    -- In real scenario, you'd move to archive table
    -- For now, we'll just delete
    DELETE FROM sensor_readings
    WHERE reading_time < NOW() - INTERVAL p_days_old DAY;
    
    -- Log the archival
    SELECT CONCAT('Archived ', v_archived_count, ' readings older than ', p_days_old, ' days') AS result;
END$$

DELIMITER ;

-- ============================================
-- PROCEDURE 5: Get Active Alerts Summary
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_active_alerts_summary()
BEGIN
    SELECT 
        a.alert_type,
        a.severity,
        COUNT(*) AS alert_count,
        GROUP_CONCAT(CONCAT(p.first_name, ' ', p.last_name) SEPARATOR ', ') AS affected_patients
    FROM alerts a
    JOIN patients p ON a.patient_id = p.patient_id
    WHERE a.status = 'active'
    GROUP BY a.alert_type, a.severity
    ORDER BY 
        FIELD(a.severity, 'critical', 'high', 'medium', 'low'),
        alert_count DESC;
END$$

DELIMITER ;

-- ============================================
-- VERIFY PROCEDURES
-- ============================================

SHOW PROCEDURE STATUS WHERE Db = 'wound_healing_db';