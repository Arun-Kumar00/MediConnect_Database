-- ============================================
-- COMPREHENSIVE DATASET FOR WOUND HEALING SYSTEM
-- Includes: 15 Patients, 12 Devices, 200+ Sensor Readings
-- Automatic Alerts via Triggers
-- ============================================


USE SWHDIS;
-- Clear existing data
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE audit_logs;
TRUNCATE TABLE alerts;
TRUNCATE TABLE drug_release_events;
TRUNCATE TABLE sensor_readings;
TRUNCATE TABLE bandages;
TRUNCATE TABLE devices;
TRUNCATE TABLE patients;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- 1. USERS (7 users)
-- Password for all: "password123"
-- ============================================
INSERT INTO users (username, password_hash, email, full_name, role, is_active, last_login) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin@hospital.com', 'System Administrator', 'admin', true, '2025-11-17 08:00:00'),
('dr_smith', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'john.smith@hospital.com', 'Dr. John Smith', 'doctor', true, '2025-11-17 07:30:00'),
('dr_jones', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'sarah.jones@hospital.com', 'Dr. Sarah Jones', 'doctor', true, '2025-11-17 08:15:00'),
('dr_patel', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'raj.patel@hospital.com', 'Dr. Raj Patel', 'doctor', true, '2025-11-17 07:45:00'),
('nurse_alice', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'alice.brown@hospital.com', 'Alice Brown', 'nurse', true, '2025-11-17 06:30:00'),
('nurse_bob', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'bob.wilson@hospital.com', 'Bob Wilson', 'nurse', true, '2025-11-17 06:45:00'),
('nurse_carol', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'carol.davis@hospital.com', 'Carol Davis', 'nurse', true, '2025-11-17 07:00:00');

-- ============================================
-- 2. PATIENTS (15 diverse patients)
-- ============================================
INSERT INTO patients (first_name, last_name, date_of_birth, gender, contact_number, email, wound_type, wound_location, wound_size_cm2, admission_date, notes) VALUES
-- Critical cases (will trigger multiple alerts)
('Robert', 'Anderson', '1955-08-25', 'M', '555-1001', 'robert.anderson@email.com', 'Diabetic Ulcer', 'Right Foot', 14.50, '2025-10-20 08:30:00', 'Type 2 diabetes, hypertension. Severe infection risk. Neuropathic complications. Critical monitoring required.'),
('Maria', 'Garcia', '1968-03-12', 'F', '555-1002', 'maria.garcia@email.com', 'Pressure Ulcer', 'Lower Back', 18.75, '2025-10-25 10:15:00', 'Stage 4 pressure ulcer. Bedridden for 6 months. Sepsis risk. Requires intensive care and frequent monitoring.'),
('James', 'Thompson', '1972-11-08', 'M', '555-1003', 'james.thompson@email.com', 'Burn Wound', 'Left Arm', 22.30, '2025-11-01 14:20:00', 'Third-degree burn from industrial accident. Severe tissue damage. High infection probability. Daily debridement.'),

-- High risk cases (will trigger several alerts)
('Linda', 'Martinez', '1965-05-30', 'F', '555-1004', 'linda.martinez@email.com', 'Venous Ulcer', 'Left Ankle', 11.20, '2025-11-05 09:00:00', 'Chronic venous insufficiency. Poor circulation. History of DVT. Slow healing expected. Compression therapy required.'),
('Michael', 'Wilson', '1980-09-12', 'M', '555-1005', 'michael.wilson@email.com', 'Traumatic Wound', 'Right Thigh', 16.80, '2025-11-08 16:45:00', 'Motor vehicle accident. Deep laceration with muscle involvement. Risk of necrotizing fasciitis. Under close observation.'),
('Patricia', 'Moore', '1958-12-15', 'F', '555-1006', 'patricia.moore@email.com', 'Surgical Wound', 'Abdomen', 13.40, '2025-11-10 11:00:00', 'Post-abdominal surgery. Obese patient with compromised immunity. Wound dehiscence risk. Prophylactic antibiotics.'),

-- Moderate risk cases (occasional alerts)
('David', 'Taylor', '1975-02-28', 'M', '555-1007', 'david.taylor@email.com', 'Diabetic Ulcer', 'Left Heel', 9.60, '2025-11-12 13:30:00', 'Type 1 diabetes. Generally well-controlled. Minor neuropathy. Regular wound care showing improvement.'),
('Jennifer', 'Thomas', '1990-06-18', 'F', '555-1008', 'jennifer.thomas@email.com', 'Burn Wound', 'Right Hand', 7.20, '2025-11-13 09:45:00', 'Second-degree burn from cooking oil. Partial thickness. Good healing response. Pain management effective.'),
('William', 'Jackson', '1962-08-05', 'M', '555-1009', 'william.jackson@email.com', 'Pressure Ulcer', 'Right Heel', 8.90, '2025-11-14 10:20:00', 'Stage 2 pressure ulcer. Limited mobility post-stroke. Repositioning protocol in place. Steady improvement.'),

-- Low risk / healing well (minimal alerts)
('Elizabeth', 'White', '1985-04-10', 'F', '555-1010', 'elizabeth.white@email.com', 'Surgical Wound', 'Right Knee', 10.50, '2025-11-15 15:00:00', 'ACL reconstruction. Young, healthy patient. Excellent healing trajectory. No complications. Early discharge expected.'),
('Charles', 'Harris', '1995-07-22', 'M', '555-1011', 'charles.harris@email.com', 'Traumatic Wound', 'Left Forearm', 6.30, '2025-11-16 08:30:00', 'Sports injury. Clean laceration. No underlying conditions. Healing ahead of schedule. Minimal scarring expected.'),
('Barbara', 'Martin', '1978-01-14', 'F', '555-1012', 'barbara.martin@email.com', 'Surgical Wound', 'Chest', 8.70, '2025-11-16 11:15:00', 'Post-mastectomy wound. Oncology clearance obtained. No infection signs. Emotional support provided.'),
('Joseph', 'Lee', '1988-09-30', 'M', '555-1013', 'joseph.lee@email.com', 'Burn Wound', 'Left Leg', 12.10, '2025-11-16 14:00:00', 'Electrical burn. Superficial entry/exit wounds. No nerve damage. Good prognosis. Physical therapy scheduled.'),
('Susan', 'Walker', '1992-03-25', 'F', '555-1014', 'susan.walker@email.com', 'Diabetic Ulcer', 'Right Toe', 4.20, '2025-11-16 16:30:00', 'Early-stage diabetic foot ulcer. Caught early. Patient compliant with care. Good glycemic control. Healing well.'),
('Thomas', 'Hall', '1970-11-18', 'M', '555-1015', 'thomas.hall@email.com', 'Venous Ulcer', 'Right Calf', 9.80, '2025-11-17 09:00:00', 'Chronic venous disease. Third occurrence. Compression therapy compliance improved. Moderate healing progress.');

-- ============================================
-- 3. DEVICES (12 devices with varied status)
-- ============================================
INSERT INTO devices (device_serial, device_model, manufacture_date, last_calibration, status, firmware_version) VALUES
('SC-2025-001', 'SmartClip Pro v2', '2025-01-15', '2025-11-01 10:00:00', 'active', 'v2.3.1'),
('SC-2025-002', 'SmartClip Pro v2', '2025-01-20', '2025-11-01 10:30:00', 'active', 'v2.3.1'),
('SC-2025-003', 'SmartClip Pro v3', '2025-02-10', '2025-11-05 11:00:00', 'active', 'v3.0.1'),
('SC-2025-004', 'SmartClip Basic', '2024-12-05', '2025-09-15 14:00:00', 'maintenance', 'v2.2.5'),
('SC-2025-005', 'SmartClip Pro v2', '2025-03-01', '2025-11-01 11:30:00', 'active', 'v2.3.1'),
('SC-2025-006', 'SmartClip Pro v3', '2025-04-12', '2025-11-08 09:00:00', 'active', 'v3.0.2'),
('SC-2025-007', 'SmartClip Pro v2', '2025-02-28', '2025-11-01 12:00:00', 'active', 'v2.3.1'),
('SC-2025-008', 'SmartClip Basic', '2024-11-20', '2025-10-20 15:00:00', 'retired', 'v2.1.0'),
('SC-2025-009', 'SmartClip Pro v3', '2025-05-15', '2025-11-10 10:00:00', 'active', 'v3.0.2'),
('SC-2025-010', 'SmartClip Pro v2', '2025-03-22', '2025-11-01 12:30:00', 'active', 'v2.3.1'),
('SC-2025-011', 'SmartClip Pro v3', '2025-06-08', '2025-11-12 08:00:00', 'active', 'v3.0.2'),
('SC-2025-012', 'SmartClip Pro v2', '2025-04-30', '2025-11-01 13:00:00', 'active', 'v2.3.1');

-- ============================================
-- 4. BANDAGES (15 bandages - one per patient)
-- ============================================
INSERT INTO bandages (bandage_serial, patient_id, device_id, application_date, removal_date, status) VALUES
('BAND-2025-0001', 1, 1, '2025-10-20 09:00:00', NULL, 'active'),
('BAND-2025-0002', 2, 2, '2025-10-25 11:00:00', NULL, 'active'),
('BAND-2025-0003', 3, 3, '2025-11-01 15:00:00', NULL, 'active'),
('BAND-2025-0004', 4, 5, '2025-11-05 10:00:00', NULL, 'active'),
('BAND-2025-0005', 5, 6, '2025-11-08 17:00:00', NULL, 'active'),
('BAND-2025-0006', 6, 7, '2025-11-10 12:00:00', NULL, 'active'),
('BAND-2025-0007', 7, 9, '2025-11-12 14:00:00', NULL, 'active'),
('BAND-2025-0008', 8, 10, '2025-11-13 10:00:00', NULL, 'active'),
('BAND-2025-0009', 9, 11, '2025-11-14 11:00:00', NULL, 'active'),
('BAND-2025-0010', 10, 12, '2025-11-15 16:00:00', NULL, 'active'),
('BAND-2025-0011', 11, 1, '2025-11-16 09:00:00', NULL, 'active'),
('BAND-2025-0012', 12, 2, '2025-11-16 12:00:00', NULL, 'active'),
('BAND-2025-0013', 13, 3, '2025-11-16 14:30:00', NULL, 'active'),
('BAND-2025-0014', 14, 5, '2025-11-16 17:00:00', NULL, 'active'),
('BAND-2025-0015', 15, 6, '2025-11-17 09:30:00', NULL, 'active');

-- ============================================
-- 5. SENSOR READINGS (220+ readings with TRIGGER ALERTS)
-- This will automatically create alerts via triggers!
-- ============================================

-- Patient 1: CRITICAL - Severe infection (triggers MULTIPLE alerts)
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(1, '2025-11-16 06:00:00', 7.6, 72.0, 37.8, 280.0),
(1, '2025-11-16 08:00:00', 7.8, 68.0, 38.2, 320.0),
(1, '2025-11-16 10:00:00', 8.1, 65.0, 38.8, 380.0),
(1, '2025-11-16 12:00:00', 8.4, 62.0, 39.2, 450.0),
(1, '2025-11-16 14:00:00', 8.6, 58.0, 39.6, 520.0),
(1, '2025-11-16 16:00:00', 8.8, 55.0, 40.0, 580.0),
(1, '2025-11-16 18:00:00', 9.0, 52.0, 40.5, 650.0),
(1, '2025-11-16 20:00:00', 9.1, 50.0, 40.8, 720.0),
(1, '2025-11-16 22:00:00', 9.2, 48.0, 41.0, 780.0),
(1, '2025-11-17 00:00:00', 9.3, 45.0, 41.2, 850.0),
(1, '2025-11-17 02:00:00', 9.2, 46.0, 41.0, 820.0),
(1, '2025-11-17 04:00:00', 9.1, 47.0, 40.8, 790.0),
(1, '2025-11-17 06:00:00', 9.0, 48.0, 40.5, 760.0),
(1, '2025-11-17 08:00:00', 8.9, 50.0, 40.2, 730.0),
(1, '2025-11-17 10:00:00', 8.8, 52.0, 40.0, 700.0);

-- Patient 2: CRITICAL - Sepsis risk (triggers MULTIPLE alerts)
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(2, '2025-11-16 06:00:00', 7.7, 65.0, 38.0, 350.0),
(2, '2025-11-16 08:00:00', 8.0, 60.0, 38.5, 420.0),
(2, '2025-11-16 10:00:00', 8.3, 55.0, 39.0, 490.0),
(2, '2025-11-16 12:00:00', 8.6, 50.0, 39.5, 560.0),
(2, '2025-11-16 14:00:00', 8.8, 45.0, 40.0, 630.0),
(2, '2025-11-16 16:00:00', 9.0, 42.0, 40.5, 700.0),
(2, '2025-11-16 18:00:00', 9.1, 40.0, 41.0, 750.0),
(2, '2025-11-16 20:00:00', 9.2, 38.0, 41.3, 800.0),
(2, '2025-11-16 22:00:00', 9.3, 36.0, 41.5, 850.0),
(2, '2025-11-17 00:00:00', 9.4, 34.0, 41.8, 900.0),
(2, '2025-11-17 02:00:00', 9.3, 35.0, 41.5, 880.0),
(2, '2025-11-17 04:00:00', 9.2, 37.0, 41.2, 860.0),
(2, '2025-11-17 06:00:00', 9.1, 39.0, 41.0, 830.0),
(2, '2025-11-17 08:00:00', 9.0, 41.0, 40.8, 800.0),
(2, '2025-11-17 10:00:00', 8.9, 43.0, 40.5, 770.0);

-- Patient 3: HIGH RISK - Burn infection (triggers alerts)
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(3, '2025-11-16 08:00:00', 7.5, 70.0, 37.5, 280.0),
(3, '2025-11-16 10:00:00', 7.7, 68.0, 37.8, 320.0),
(3, '2025-11-16 12:00:00', 7.9, 65.0, 38.2, 360.0),
(3, '2025-11-16 14:00:00', 8.1, 62.0, 38.6, 400.0),
(3, '2025-11-16 16:00:00', 8.3, 60.0, 39.0, 450.0),
(3, '2025-11-16 18:00:00', 8.5, 58.0, 39.4, 490.0),
(3, '2025-11-16 20:00:00', 8.6, 56.0, 39.8, 530.0),
(3, '2025-11-16 22:00:00', 8.7, 54.0, 40.0, 570.0),
(3, '2025-11-17 00:00:00', 8.6, 55.0, 39.8, 550.0),
(3, '2025-11-17 02:00:00', 8.5, 57.0, 39.5, 530.0),
(3, '2025-11-17 04:00:00', 8.4, 59.0, 39.2, 510.0),
(3, '2025-11-17 06:00:00', 8.3, 61.0, 39.0, 490.0),
(3, '2025-11-17 08:00:00', 8.2, 63.0, 38.8, 470.0),
(3, '2025-11-17 10:00:00', 8.1, 65.0, 38.5, 450.0);

-- Patient 4: MODERATE - Poor circulation (triggers some alerts)
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(4, '2025-11-16 08:00:00', 7.3, 55.0, 36.8, 220.0),
(4, '2025-11-16 10:00:00', 7.4, 52.0, 36.9, 240.0),
(4, '2025-11-16 12:00:00', 7.5, 48.0, 37.0, 260.0),
(4, '2025-11-16 14:00:00', 7.6, 45.0, 37.2, 280.0),
(4, '2025-11-16 16:00:00', 7.7, 42.0, 37.4, 300.0),
(4, '2025-11-16 18:00:00', 7.8, 40.0, 37.6, 320.0),
(4, '2025-11-16 20:00:00', 7.9, 38.0, 37.8, 340.0),
(4, '2025-11-16 22:00:00', 8.0, 36.0, 38.0, 360.0),
(4, '2025-11-17 00:00:00', 7.9, 38.0, 37.9, 350.0),
(4, '2025-11-17 02:00:00', 7.8, 40.0, 37.7, 330.0),
(4, '2025-11-17 04:00:00', 7.7, 42.0, 37.5, 310.0),
(4, '2025-11-17 06:00:00', 7.6, 45.0, 37.3, 290.0),
(4, '2025-11-17 08:00:00', 7.5, 48.0, 37.1, 270.0),
(4, '2025-11-17 10:00:00', 7.4, 50.0, 37.0, 250.0);

-- Patient 5: HIGH RISK - Trauma with inflammation (triggers alerts)
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(5, '2025-11-16 08:00:00', 7.4, 68.0, 37.6, 320.0),
(5, '2025-11-16 10:00:00', 7.6, 65.0, 38.0, 380.0),
(5, '2025-11-16 12:00:00', 7.8, 62.0, 38.4, 440.0),
(5, '2025-11-16 14:00:00', 8.0, 60.0, 38.8, 500.0),
(5, '2025-11-16 16:00:00', 8.2, 58.0, 39.2, 560.0),
(5, '2025-11-16 18:00:00', 8.3, 56.0, 39.5, 600.0),
(5, '2025-11-16 20:00:00', 8.4, 54.0, 39.8, 640.0),
(5, '2025-11-16 22:00:00', 8.3, 55.0, 39.6, 620.0),
(5, '2025-11-17 00:00:00', 8.2, 57.0, 39.4, 590.0),
(5, '2025-11-17 02:00:00', 8.1, 59.0, 39.1, 560.0),
(5, '2025-11-17 04:00:00', 8.0, 61.0, 38.9, 530.0),
(5, '2025-11-17 06:00:00', 7.9, 63.0, 38.6, 500.0),
(5, '2025-11-17 08:00:00', 7.8, 65.0, 38.3, 470.0),
(5, '2025-11-17 10:00:00', 7.7, 67.0, 38.0, 440.0);

-- Patient 6: MODERATE - Post-surgical with mild complications
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(6, '2025-11-16 08:00:00', 7.3, 75.0, 37.2, 180.0),
(6, '2025-11-16 10:00:00', 7.4, 74.0, 37.3, 190.0),
(6, '2025-11-16 12:00:00', 7.5, 73.0, 37.4, 200.0),
(6, '2025-11-16 14:00:00', 7.6, 72.0, 37.5, 210.0),
(6, '2025-11-16 16:00:00', 7.7, 71.0, 37.6, 220.0),
(6, '2025-11-16 18:00:00', 7.8, 70.0, 37.7, 230.0),
(6, '2025-11-16 20:00:00', 7.9, 69.0, 37.8, 240.0),
(6, '2025-11-16 22:00:00', 7.8, 70.0, 37.7, 235.0),
(6, '2025-11-17 00:00:00', 7.7, 71.0, 37.6, 228.0),
(6, '2025-11-17 02:00:00', 7.6, 72.0, 37.5, 220.0),
(6, '2025-11-17 04:00:00', 7.5, 73.0, 37.4, 210.0),
(6, '2025-11-17 06:00:00', 7.4, 74.0, 37.3, 200.0),
(6, '2025-11-17 08:00:00', 7.3, 75.0, 37.2, 190.0),
(6, '2025-11-17 10:00:00', 7.2, 76.0, 37.1, 180.0);

-- Patient 7-15: NORMAL to GOOD healing (minimal or no alerts)
-- Patient 7: Stable diabetic ulcer
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(7, '2025-11-16 08:00:00', 7.2, 80.0, 36.7, 150.0),
(7, '2025-11-16 12:00:00', 7.3, 81.0, 36.8, 148.0),
(7, '2025-11-16 16:00:00', 7.2, 82.0, 36.7, 145.0),
(7, '2025-11-16 20:00:00', 7.3, 83.0, 36.8, 142.0),
(7, '2025-11-17 00:00:00', 7.2, 84.0, 36.7, 140.0),
(7, '2025-11-17 04:00:00', 7.3, 85.0, 36.8, 138.0),
(7, '2025-11-17 08:00:00', 7.2, 86.0, 36.7, 135.0),
(7, '2025-11-17 10:00:00', 7.3, 87.0, 36.8, 132.0);

-- Patient 8: Minor burn healing well
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(8, '2025-11-16 08:00:00', 7.3, 85.0, 36.8, 135.0),
(8, '2025-11-16 12:00:00', 7.4, 86.0, 36.9, 132.0),
(8, '2025-11-16 16:00:00', 7.3, 87.0, 36.8, 130.0),
(8, '2025-11-16 20:00:00', 7.4, 88.0, 36.9, 128.0),
(8, '2025-11-17 00:00:00', 7.3, 89.0, 36.8, 125.0),
(8, '2025-11-17 04:00:00', 7.4, 90.0, 36.9, 122.0),
(8, '2025-11-17 08:00:00', 7.3, 91.0, 36.8, 120.0),
(8, '2025-11-17 10:00:00', 7.4, 92.0, 36.9, 118.0);

-- Patient 9: Pressure ulcer improving
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(9, '2025-11-16 08:00:00', 7.2, 78.0, 36.6, 145.0),
(9, '2025-11-16 12:00:00', 7.3, 79.0, 36.7, 142.0),
(9, '2025-11-16 16:00:00', 7.2, 80.0, 36.6, 140.0),
(9, '2025-11-16 20:00:00', 7.3, 81.0, 36.7, 138.0),
(9, '2025-11-17 00:00:00', 7.2, 82.0, 36.6, 135.0),
(9, '2025-11-17 04:00:00', 7.3, 83.0, 36.7, 132.0),
(9, '2025-11-17 08:00:00', 7.2, 84.0, 36.6, 130.0),
(9, '2025-11-17 10:00:00', 7.3, 85.0, 36.7, 128.0);

-- Patient 10: ACL surgery excellent recovery
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(10, '2025-11-16 08:00:00', 7.3, 88.0, 36.7, 115.0),
(10, '2025-11-16 12:00:00', 7.4, 89.0, 36.8, 112.0),
(10, '2025-11-16 16:00:00', 7.3, 90.0, 36.7, 110.0),
(10, '2025-11-16 20:00:00', 7.4, 91.0, 36.8, 108.0),
(10, '2025-11-17 00:00:00', 7.3, 92.0, 36.7, 105.0),
(10, '2025-11-17 04:00:00', 7.4, 93.0, 36.8, 102.0),
(10, '2025-11-17 08:00:00', 7.3, 94.0, 36.7, 100.0),
(10, '2025-11-17 10:00:00', 7.4, 95.0, 36.8, 98.0);

-- Patient 11: Sports injury clean healing
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(11, '2025-11-16 08:00:00', 7.2, 86.0, 36.6, 120.0),
(11, '2025-11-16 12:00:00', 7.3, 87.0, 36.7, 118.0),
(11, '2025-11-16 16:00:00', 7.2, 88.0, 36.6, 115.0),
(11, '2025-11-16 20:00:00', 7.3, 89.0, 36.7, 112.0),
(11, '2025-11-17 00:00:00', 7.2, 90.0, 36.6, 110.0),
(11, '2025-11-17 04:00:00', 7.3, 91.0, 36.7, 108.0),
(11, '2025-11-17 08:00:00', 7.2, 92.0, 36.6, 105.0),
(11, '2025-11-17 10:00:00', 7.3, 93.0, 36.7, 102.0);

-- Patient 12: Post-mastectomy normal healing
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(12, '2025-11-16 08:00:00', 7.3, 83.0, 36.7, 130.0),
(12, '2025-11-16 12:00:00', 7.4, 84.0, 36.8, 128.0),
(12, '2025-11-16 16:00:00', 7.3, 85.0, 36.7, 125.0),
(12, '2025-11-16 20:00:00', 7.4, 86.0, 36.8, 122.0),
(12, '2025-11-17 00:00:00', 7.3, 87.0, 36.7, 120.0),
(12, '2025-11-17 04:00:00', 7.4, 88.0, 36.8, 118.0),
(12, '2025-11-17 08:00:00', 7.3, 89.0, 36.7, 115.0),
(12, '2025-11-17 10:00:00', 7.4, 90.0, 36.8, 112.0);

-- Patient 13: Electrical burn recovering
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(13, '2025-11-16 08:00:00', 7.2, 81.0, 36.6, 140.0),
(13, '2025-11-16 12:00:00', 7.3, 82.0, 36.7, 138.0),
(13, '2025-11-16 16:00:00', 7.2, 83.0, 36.6, 135.0),
(13, '2025-11-16 20:00:00', 7.3, 84.0, 36.7, 132.0),
(13, '2025-11-17 00:00:00', 7.2, 85.0, 36.6, 130.0),
(13, '2025-11-17 04:00:00', 7.3, 86.0, 36.7, 128.0),
(13, '2025-11-17 08:00:00', 7.2, 87.0, 36.6, 125.0),
(13, '2025-11-17 10:00:00', 7.3, 88.0, 36.7, 122.0);

-- Patient 14: Early diabetic ulcer excellent response
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(14, '2025-11-16 08:00:00', 7.3, 87.0, 36.7, 118.0),
(14, '2025-11-16 12:00:00', 7.4, 88.0, 36.8, 115.0),
(14, '2025-11-16 16:00:00', 7.3, 89.0, 36.7, 112.0),
(14, '2025-11-16 20:00:00', 7.4, 90.0, 36.8, 110.0),
(14, '2025-11-17 00:00:00', 7.3, 91.0, 36.7, 108.0),
(14, '2025-11-17 04:00:00', 7.4, 92.0, 36.8, 105.0),
(14, '2025-11-17 08:00:00', 7.3, 93.0, 36.7, 102.0),
(14, '2025-11-17 10:00:00', 7.4, 94.0, 36.8, 100.0);

-- Patient 15: Venous ulcer moderate progress
INSERT INTO sensor_readings (bandage_id, reading_time, ph_value, oxygen_percent, temperature_celsius, enzyme_index) VALUES
(15, '2025-11-17 08:00:00', 7.2, 75.0, 36.6, 155.0),
(15, '2025-11-17 09:00:00', 7.3, 76.0, 36.7, 152.0),
(15, '2025-11-17 10:00:00', 7.2, 77.0, 36.6, 150.0);

-- ============================================
-- 6. DRUG RELEASE EVENTS (12 events)
-- ============================================
INSERT INTO drug_release_events (bandage_id, release_time, drug_name, dosage_mg, trigger_reason, administered_by) VALUES
-- Critical patients - multiple interventions
(1, '2025-11-16 12:30:00', 'Silver Sulfadiazine', 75.00, 'High pH detected - automatic release', NULL),
(1, '2025-11-16 18:30:00', 'Broad Spectrum Antibiotic', 100.00, 'Critical infection markers - doctor ordered', 2),
(1, '2025-11-17 00:30:00', 'Anti-inflammatory Agent', 50.00, 'High temperature - automatic release', NULL),

(2, '2025-11-16 14:00:00', 'Antiseptic Solution', 80.00, 'Sepsis prevention - prophylactic', 3),
(2, '2025-11-16 20:00:00', 'Silver Sulfadiazine', 75.00, 'High pH and temperature - automatic', NULL),
(2, '2025-11-17 02:00:00', 'Antibiotic Gel', 90.00, 'Critical status - emergency intervention', 2),

(3, '2025-11-16 16:00:00', 'Burn Cream with Antibiotics', 85.00, 'Burn infection prevention', 4),
(3, '2025-11-17 00:00:00', 'Pain Relief Gel', 40.00, 'Patient discomfort - scheduled dose', 5),

(4, '2025-11-16 22:00:00', 'Antibiotic Gel', 70.00, 'Low oxygen level - infection risk', 3),

(5, '2025-11-16 20:00:00', 'Anti-inflammatory', 60.00, 'High enzyme levels - tissue damage', NULL),

-- Moderate patients - preventive care
(6, '2025-11-17 08:00:00', 'Antiseptic Wash', 30.00, 'Routine wound care - scheduled', 5),

(7, '2025-11-17 06:00:00', 'Diabetic Wound Gel', 45.00, 'Diabetic ulcer management - scheduled', 6);

-- ============================================
-- 7. CHECK ALERTS (SHOULD BE AUTO-CREATED!)
-- ============================================


   