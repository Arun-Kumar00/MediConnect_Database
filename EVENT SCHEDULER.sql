-- ============================================
-- EVENT SCHEDULER: Automatic daily cleanup
-- ============================================

USE wound_healing_db;

-- First, enable the event scheduler
SET GLOBAL event_scheduler = ON;

-- Event 1: Auto-resolve old acknowledged alerts (runs daily at 2 AM)
CREATE EVENT IF NOT EXISTS evt_auto_resolve_alerts
ON SCHEDULE EVERY 1 DAY
STARTS '2025-11-15 02:00:00'
DO
BEGIN
    -- Auto-resolve alerts that were acknowledged more than 7 days ago
    UPDATE alerts 
    SET status = 'resolved'
    WHERE status = 'acknowledged' 
    AND acknowledged_at < NOW() - INTERVAL 7 DAY;
END;

-- Event 2: Clean up old audit logs (runs weekly on Sunday at 3 AM)
CREATE EVENT IF NOT EXISTS evt_cleanup_old_logs
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-11-17 03:00:00'
DO
BEGIN
    -- Delete audit logs older than 90 days
    DELETE FROM audit_logs 
    WHERE changed_at < NOW() - INTERVAL 90 DAY;
END;

-- Verify events are created
SHOW EVENTS;