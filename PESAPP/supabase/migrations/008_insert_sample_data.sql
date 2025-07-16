-- Migration: Insert sample data
-- Date: 2024-01-XX
-- Description: Sample data for testing the hospital massage system

-- Insert sample users
INSERT INTO users (id, email, role, first_name, last_name, phone, active, requires_2fa, email_verified) VALUES
  -- Admin user
  ('00000000-0000-0000-0000-000000000001', 'admin@hospital.com', 'admin', 'Juan', 'Pérez', '555-0001', true, true, true),
  -- Therapist users
  ('00000000-0000-0000-0000-000000000002', 'terapeuta1@hospital.com', 'therapist', 'María', 'González', '555-0002', true, true, true),
  ('00000000-0000-0000-0000-000000000003', 'terapeuta2@hospital.com', 'therapist', 'Carlos', 'Rodríguez', '555-0003', true, true, true),
  -- Receptionist user
  ('00000000-0000-0000-0000-000000000004', 'recepcion@hospital.com', 'receptionist', 'Ana', 'Martínez', '555-0004', true, false, true),
  -- Patient users
  ('00000000-0000-0000-0000-000000000005', 'paciente1@hospital.com', 'patient', 'Luis', 'García', '555-0005', true, false, true),
  ('00000000-0000-0000-0000-000000000006', 'paciente2@hospital.com', 'patient', 'Carmen', 'López', '555-0006', true, false, true),
  ('00000000-0000-0000-0000-000000000007', 'paciente3@hospital.com', 'patient', 'Roberto', 'Jiménez', '555-0007', true, false, true);

-- Insert sample therapists
INSERT INTO therapists (id, user_id, license_number, specializations, available, work_schedule) VALUES
  (
    '00000000-0000-0000-0000-000000000101',
    '00000000-0000-0000-0000-000000000002',
    'LIC-MASSAGE-001',
    ARRAY['Swedish', 'Deep Tissue', 'Hot Stone'],
    true,
    '{"monday": {"start": "09:00", "end": "17:00"}, "tuesday": {"start": "09:00", "end": "17:00"}, "wednesday": {"start": "09:00", "end": "17:00"}, "thursday": {"start": "09:00", "end": "17:00"}, "friday": {"start": "09:00", "end": "17:00"}}'::jsonb
  ),
  (
    '00000000-0000-0000-0000-000000000102',
    '00000000-0000-0000-0000-000000000003',
    'LIC-MASSAGE-002',
    ARRAY['Sports', 'Trigger Point', 'Aromatherapy'],
    true,
    '{"monday": {"start": "10:00", "end": "18:00"}, "tuesday": {"start": "10:00", "end": "18:00"}, "wednesday": {"start": "10:00", "end": "18:00"}, "thursday": {"start": "10:00", "end": "18:00"}, "friday": {"start": "10:00", "end": "18:00"}}'::jsonb
  );

-- Insert sample appointments
INSERT INTO appointments (id, patient_id, therapist_id, appointment_date, appointment_time, duration_minutes, massage_type, status, created_by) VALUES
  (
    '00000000-0000-0000-0000-000000000201',
    '00000000-0000-0000-0000-000000000005',
    '00000000-0000-0000-0000-000000000101',
    CURRENT_DATE + INTERVAL '1 day',
    '10:00:00',
    60,
    'Swedish',
    'confirmed',
    '00000000-0000-0000-0000-000000000005'
  ),
  (
    '00000000-0000-0000-0000-000000000202',
    '00000000-0000-0000-0000-000000000006',
    '00000000-0000-0000-0000-000000000102',
    CURRENT_DATE + INTERVAL '2 days',
    '14:00:00',
    90,
    'Deep Tissue',
    'pending',
    '00000000-0000-0000-0000-000000000006'
  ),
  (
    '00000000-0000-0000-0000-000000000203',
    '00000000-0000-0000-0000-000000000007',
    '00000000-0000-0000-0000-000000000101',
    CURRENT_DATE + INTERVAL '3 days',
    '11:00:00',
    60,
    'Hot Stone',
    'pending',
    '00000000-0000-0000-0000-000000000007'
  );

-- Insert sample notifications
INSERT INTO notifications (id, user_id, type, title, message, read, appointment_id) VALUES
  (
    '00000000-0000-0000-0000-000000000301',
    '00000000-0000-0000-0000-000000000005',
    'appointment_confirmed',
    'Cita Confirmada',
    'Su cita de masaje sueco ha sido confirmada para mañana a las 10:00 AM',
    false,
    '00000000-0000-0000-0000-000000000201'
  ),
  (
    '00000000-0000-0000-0000-000000000302',
    '00000000-0000-0000-0000-000000000006',
    'appointment_created',
    'Nueva Cita Creada',
    'Su cita de masaje de tejido profundo ha sido creada para pasado mañana a las 2:00 PM',
    false,
    '00000000-0000-0000-0000-000000000202'
  ),
  (
    '00000000-0000-0000-0000-000000000303',
    '00000000-0000-0000-0000-000000000002',
    'new_appointment',
    'Nueva Cita Asignada',
    'Tiene una nueva cita programada para el ' || (CURRENT_DATE + INTERVAL '1 day') || ' a las 10:00 AM',
    false,
    '00000000-0000-0000-0000-000000000201'
  );

-- Create a function to generate test login credentials
CREATE OR REPLACE FUNCTION get_test_credentials()
RETURNS TABLE (
    role TEXT,
    email TEXT,
    password TEXT,
    description TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'admin'::TEXT, 
        'admin@hospital.com'::TEXT, 
        '123456'::TEXT, 
        'Administrador del sistema'::TEXT
    UNION ALL
    SELECT 
        'therapist'::TEXT, 
        'terapeuta1@hospital.com'::TEXT, 
        '123456'::TEXT, 
        'Terapeuta - María González'::TEXT
    UNION ALL
    SELECT 
        'receptionist'::TEXT, 
        'recepcion@hospital.com'::TEXT, 
        '123456'::TEXT, 
        'Recepcionista - Ana Martínez'::TEXT
    UNION ALL
    SELECT 
        'patient'::TEXT, 
        'paciente1@hospital.com'::TEXT, 
        '123456'::TEXT, 
        'Paciente - Luis García'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Comments
COMMENT ON FUNCTION get_test_credentials() IS 'Returns test login credentials for development';
COMMENT ON TABLE users IS 'Sample users include admin, therapists, receptionist, and patients';
COMMENT ON TABLE therapists IS 'Sample therapists with different specializations and schedules';
COMMENT ON TABLE appointments IS 'Sample appointments for testing the booking system';
COMMENT ON TABLE notifications IS 'Sample notifications for testing the notification system'; 