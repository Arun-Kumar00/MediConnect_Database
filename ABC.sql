-- ============================================
-- SMART WOUND HEALING DATA INTELLIGENCE SYSTEM
-- DATABASE SCHEMA - CORRECTED VERSION
-- ============================================

-- Drop tables if they exist (for clean re-runs)
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS alerts;
DROP TABLE IF EXISTS drug_release_events;
DROP TABLE IF EXISTS sensor_readings;
DROP TABLE IF EXISTS bandages;
DROP TABLE IF EXISTS devices;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS users;

-- ============================================
-- TABLE 1: Users
-- ============================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'doctor', 'nurse') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL
) ENGINE=InnoDB;

-- ============================================
-- TABLE 2: Patients
-- ============================================
CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('M', 'F', 'Other') NOT NULL,
    contact_number VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    wound_type VARCHAR(100) NOT NULL,
    wound_location VARCHAR(100) NOT NULL,
    wound_size_cm2 DECIMAL(5,2),
    admission_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================
-- TABLE 3: Devices
-- ============================================
CREATE TABLE devices (
    device_id INT PRIMARY KEY AUTO_INCREMENT,
    device_serial VARCHAR(50) NOT NULL UNIQUE,
    device_model VARCHAR(50) NOT NULL,
    manufacture_date DATE,
    last_calibration DATETIME,
    status ENUM('active', 'maintenance', 'retired') DEFAULT 'active',
    firmware_version VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================
-- TABLE 4: Bandages
-- ============================================
CREATE TABLE bandages (
    bandage_id INT PRIMARY KEY AUTO_INCREMENT,
    bandage_serial VARCHAR(50) NOT NULL UNIQUE,
    patient_id INT NOT NULL,
    device_id INT NOT NULL,
    application_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    removal_date DATETIME NULL,
    status ENUM('active', 'removed', 'expired') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- TABLE 5: Sensor Readings (TIME-SERIES DATA)
-- ============================================
CREATE TABLE sensor_readings (
    reading_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    bandage_id INT NOT NULL,
    reading_time DATETIME NOT NULL,
    ph_value DECIMAL(3,2) CHECK(ph_value BETWEEN 0 AND 14),
    oxygen_percent DECIMAL(5,2) CHECK(oxygen_percent BETWEEN 0 AND 100),
    temperature_celsius DECIMAL(4,2) CHECK(temperature_celsius BETWEEN 20 AND 45),
    enzyme_index DECIMAL(6,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bandage_id) REFERENCES bandages(bandage_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- TABLE 6: Drug Release Events
-- ============================================
CREATE TABLE drug_release_events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    bandage_id INT NOT NULL,
    release_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    drug_name VARCHAR(100) NOT NULL,
    dosage_mg DECIMAL(8,2) NOT NULL,
    trigger_reason VARCHAR(255),
    administered_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bandage_id) REFERENCES bandages(bandage_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (administered_by) REFERENCES users(user_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- TABLE 7: Alerts
-- ============================================
CREATE TABLE alerts (
    alert_id INT PRIMARY KEY AUTO_INCREMENT,
    bandage_id INT NOT NULL,
    patient_id INT NOT NULL,
    alert_type ENUM('high_ph', 'low_oxygen', 'high_temp', 'infection_risk', 'enzyme_spike') NOT NULL,
    severity ENUM('low', 'medium', 'high', 'critical') NOT NULL,
    message TEXT NOT NULL,
    triggered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    acknowledged_by INT,
    acknowledged_at DATETIME NULL,
    status ENUM('active', 'acknowledged', 'resolved') DEFAULT 'active',
    FOREIGN KEY (bandage_id) REFERENCES bandages(bandage_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (acknowledged_by) REFERENCES users(user_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- TABLE 8: Audit Logs
-- ============================================
CREATE TABLE audit_logs (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    old_value JSON NULL,
    new_value JSON NULL,
    changed_by INT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    FOREIGN KEY (changed_by) REFERENCES users(user_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- VERIFY TABLE CREATION
-- ============================================
SHOW TABLES;