DELIMITER $$

CREATE TRIGGER trg_sensor_alert_check
AFTER INSERT ON sensor_readings
FOR EACH ROW
BEGIN
    DECLARE v_patient_id INT;
    
    -- Get patient_id from bandage
    SELECT patient_id INTO v_patient_id
    FROM bandages
    WHERE bandage_id = NEW.bandage_id;
    
    IF v_patient_id IS NOT NULL THEN 
    
        -- Check for HIGH pH (infection risk)
        IF NEW.ph_value > 7.8 THEN
            INSERT INTO alerts (bandage_id, patient_id, alert_type, severity, message, triggered_at)
            VALUES (NEW.bandage_id, v_patient_id, 'high_ph', 'high', CONCAT('Critical pH level detected: ', NEW.ph_value, ' at ', NEW.reading_time), NEW.reading_time);
        END IF;
            
    
    -- Check for LOW oxygen (poor healing)
    IF NEW.oxygen_percent < 30 THEN
        INSERT INTO alerts (bandage_id, patient_id, alert_type, severity, message, triggered_at)
        VALUES (
            NEW.bandage_id,
            v_patient_id,
            'low_oxygen',
            CASE 
                WHEN NEW.oxygen_percent < 15 THEN 'critical'
                WHEN NEW.oxygen_percent < 25 THEN 'high'
                ELSE 'medium'
            END,
            CONCAT('Low oxygen level: ', NEW.oxygen_percent, '% at ', NEW.reading_time),
            NEW.reading_time
        );
    END IF;
    
    -- Check for HIGH temperature (infection)
    IF NEW.temperature_celsius > 38.5 THEN
        INSERT INTO alerts (bandage_id, patient_id, alert_type, severity, message, triggered_at)
        VALUES (
            NEW.bandage_id,
            v_patient_id,
            'high_temp',
            CASE 
                WHEN NEW.temperature_celsius > 40 THEN 'critical'
                WHEN NEW.temperature_celsius > 39 THEN 'high'
                ELSE 'medium'
            END,
            CONCAT('Elevated temperature: ', NEW.temperature_celsius, '°C at ', NEW.reading_time),
            NEW.reading_time
        );
    END IF;
    
    -- Check for ENZYME spike (tissue damage)
    IF NEW.enzyme_index > 500 THEN
        INSERT INTO alerts (bandage_id, patient_id, alert_type, severity, message, triggered_at)
        VALUES (
            NEW.bandage_id,
            v_patient_id,
            'enzyme_spike',
            'high',
            CONCAT('Enzyme spike detected: ', NEW.enzyme_index, ' at ', NEW.reading_time),
            NEW.reading_time
        );
    END IF;

END$$
DELIMITER ;

DELIMITER ;
-- ============================================
-- TRIGGERS FOR AUTOMATIC ALERT GENERATION
-- ============================================

USE wound_healing_db;

-- ============================================
-- TRIGGER 1: Auto-generate alerts on dangerous sensor readings
-- ============================================

DELIMITER $$

CREATE TRIGGER trg_sensor_alert_check
AFTER INSERT ON sensor_readings
FOR EACH ROW
BEGIN
    DECLARE v_patient_id INT;
    
    -- Get patient_id from bandage
    SELECT patient_id INTO v_patient_id
    FROM bandages
    WHERE bandage_id = NEW.bandage_id;
    
    -- Check for HIGH pH (infection risk)
    IF NEW.ph_value > 7.8 THEN
        INSERT INTO alerts (bandage_id, patient_id, alert_type, severity, message, triggered_at)
        VALUES (
            NEW.bandage_id,
            v_patient_id,
            'high_ph',
            'high',
            CONCAT('Critical pH level detected: ', NEW.ph_value, ' at ', NEW.reading_time),
            NEW.reading_time
        );
    END IF;
    
    -- Check for LOW oxygen (poor healing)
    IF NEW.oxygen_percent < 30 THEN
        INSERT INTO alerts (bandage_id, patient_id, alert_type, severity, message, triggered_at)
        VALUES (
            NEW.bandage_id,
            v_patient_id,
            'low_oxygen',
            CASE 
                WHEN NEW.oxygen_percent < 15 THEN 'critical'
                WHEN NEW.oxygen_percent < 25 THEN 'high'
                ELSE 'medium'
            END,
            CONCAT('Low oxygen level: ', NEW.oxygen_percent, '% at ', NEW.reading_time),
            NEW.reading_time
        );
    END IF;
    
    -- Check for HIGH temperature (infection)
    IF NEW.temperature_celsius > 38.5 THEN
        INSERT INTO alerts (bandage_id, patient_id, alert_type, severity, message, triggered_at)
        VALUES (
            NEW.bandage_id,
            v_patient_id,
            'high_temp',
            CASE 
                WHEN NEW.temperature_celsius > 40 THEN 'critical'
                WHEN NEW.temperature_celsius > 39 THEN 'high'
                ELSE 'medium'
            END,
            CONCAT('Elevated temperature: ', NEW.temperature_celsius, '°C at ', NEW.reading_time),
            NEW.reading_time
        );
    END IF;
    
    -- Check for ENZYME spike (tissue damage)
    IF NEW.enzyme_index > 500 THEN
        INSERT INTO alerts (bandage_id, patient_id, alert_type, severity, message, triggered_at)
        VALUES (
            NEW.bandage_id,
            v_patient_id,
            'enzyme_spike',
            'high',
            CONCAT('Enzyme spike detected: ', NEW.enzyme_index, ' at ', NEW.reading_time),
            NEW.reading_time
        );
    END IF;
    
END$$

DELIMITER ;

-- ============================================
-- TRIGGER 2: Audit log for patient updates
-- ============================================

DELIMITER $$

CREATE TRIGGER trg_patient_update_audit
AFTER UPDATE ON patients
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, old_value, new_value, changed_at)
    VALUES (
        'patients',
        NEW.patient_id,
        'UPDATE',
        JSON_OBJECT(
            'first_name', OLD.first_name,
            'last_name', OLD.last_name,
            'wound_type', OLD.wound_type,
            'wound_size_cm2', OLD.wound_size_cm2,
            'notes', OLD.notes
        ),
        JSON_OBJECT(
            'first_name', NEW.first_name,
            'last_name', NEW.last_name,
            'wound_type', NEW.wound_type,
            'wound_size_cm2', NEW.wound_size_cm2,
            'notes', NEW.notes
        ),
        NOW()
    );
END$$

DELIMITER ;

-- ============================================
-- TRIGGER 3: Audit log for patient deletion
-- ============================================

DELIMITER $$

CREATE TRIGGER trg_patient_delete_audit
BEFORE DELETE ON patients
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, old_value, changed_at)
    VALUES (
        'patients',
        OLD.patient_id,
        'DELETE',
        JSON_OBJECT(
            'first_name', OLD.first_name,
            'last_name', OLD.last_name,
            'date_of_birth', OLD.date_of_birth,
            'wound_type', OLD.wound_type
        ),
        NOW()
    );
END$$

DELIMITER ;

-- ============================================
-- TRIGGER 4: Auto-deactivate bandage when removed
-- ============================================

DELIMITER $$

CREATE TRIGGER trg_bandage_removal
BEFORE UPDATE ON bandages
FOR EACH ROW
BEGIN
    -- If removal_date is set, auto-change status to 'removed'
    IF NEW.removal_date IS NOT NULL AND OLD.removal_date IS NULL THEN
        SET NEW.status = 'removed';
    END IF;
END$$

DELIMITER ;

-- ============================================
-- TRIGGER 5: Audit log for drug administration
-- ============================================

DELIMITER $$

CREATE TRIGGER trg_drug_release_audit
AFTER INSERT ON drug_release_events
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_value, changed_by, changed_at)
    VALUES (
        'drug_release_events',
        NEW.event_id,
        'INSERT',
        JSON_OBJECT(
            'bandage_id', NEW.bandage_id,
            'drug_name', NEW.drug_name,
            'dosage_mg', NEW.dosage_mg,
            'release_time', NEW.release_time,
            'trigger_reason', NEW.trigger_reason
        ),
        NEW.administered_by,
        NOW()
    );
END$$

DELIMITER ;

-- ============================================
-- VERIFY TRIGGERS
-- ============================================

SHOW TRIGGERS;

-- To see details of a specific trigger:
-- SHOW CREATE TRIGGER trg_sensor_alert_check;