-- Migration: Create audit triggers
-- Date: 2024-01-XX
-- Description: Audit triggers for the hospital massage system

-- Create audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit_logs (
            user_id, action, table_name, record_id, old_values
        ) VALUES (
            auth.uid()::text::uuid,
            'DELETE',
            TG_TABLE_NAME,
            OLD.id,
            row_to_json(OLD)
        );
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_logs (
            user_id, action, table_name, record_id, old_values, new_values
        ) VALUES (
            auth.uid()::text::uuid,
            'UPDATE',
            TG_TABLE_NAME,
            NEW.id,
            row_to_json(OLD),
            row_to_json(NEW)
        );
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit_logs (
            user_id, action, table_name, record_id, new_values
        ) VALUES (
            auth.uid()::text::uuid,
            'INSERT',
            TG_TABLE_NAME,
            NEW.id,
            row_to_json(NEW)
        );
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create audit triggers for all main tables
CREATE TRIGGER audit_users_trigger
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_therapists_trigger
    AFTER INSERT OR UPDATE OR DELETE ON therapists
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_appointments_trigger
    AFTER INSERT OR UPDATE OR DELETE ON appointments
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_notifications_trigger
    AFTER INSERT OR UPDATE OR DELETE ON notifications
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- Create function to automatically set therapist role
CREATE OR REPLACE FUNCTION set_therapist_role()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE users 
    SET role = 'therapist' 
    WHERE id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically set therapist role
CREATE TRIGGER set_therapist_role_trigger
    AFTER INSERT ON therapists
    FOR EACH ROW EXECUTE FUNCTION set_therapist_role();

-- Create function to validate appointment times
CREATE OR REPLACE FUNCTION validate_appointment_time()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if appointment is in the past
    IF NEW.appointment_date < CURRENT_DATE OR 
       (NEW.appointment_date = CURRENT_DATE AND NEW.appointment_time < CURRENT_TIME) THEN
        RAISE EXCEPTION 'Cannot create appointment in the past';
    END IF;
    
    -- Check if therapist is available
    IF NOT EXISTS (
        SELECT 1 FROM therapists 
        WHERE id = NEW.therapist_id AND available = true
    ) THEN
        RAISE EXCEPTION 'Therapist is not available';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to validate appointment times
CREATE TRIGGER validate_appointment_time_trigger
    BEFORE INSERT OR UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION validate_appointment_time();

-- Create function to send notification on appointment changes
CREATE OR REPLACE FUNCTION create_appointment_notification()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Create notification for new appointment
        INSERT INTO notifications (user_id, type, title, message, appointment_id)
        VALUES (
            NEW.patient_id,
            'appointment_created',
            'Nueva Cita Creada',
            'Su cita de ' || NEW.massage_type || ' ha sido creada para el ' || NEW.appointment_date,
            NEW.id
        );
    ELSIF TG_OP = 'UPDATE' THEN
        -- Create notification for status change
        IF OLD.status != NEW.status THEN
            INSERT INTO notifications (user_id, type, title, message, appointment_id)
            VALUES (
                NEW.patient_id,
                'appointment_status_changed',
                'Estado de Cita Actualizado',
                'Su cita del ' || NEW.appointment_date || ' ha cambiado a: ' || NEW.status,
                NEW.id
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for appointment notifications
CREATE TRIGGER appointment_notification_trigger
    AFTER INSERT OR UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION create_appointment_notification();

-- Comments
COMMENT ON FUNCTION audit_trigger_function() IS 'Function to automatically create audit logs for table changes';
COMMENT ON FUNCTION set_therapist_role() IS 'Function to automatically set user role to therapist when therapist record is created';
COMMENT ON FUNCTION validate_appointment_time() IS 'Function to validate appointment times and therapist availability';
COMMENT ON FUNCTION create_appointment_notification() IS 'Function to automatically create notifications for appointment changes'; 