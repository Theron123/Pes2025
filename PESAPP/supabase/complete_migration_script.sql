-- HOSPITAL MASSAGE SYSTEM - MIGRACIÓN COMPLETA SIN ERRORES
-- ================================================================
-- Este script crea toda la estructura de base de datos necesaria
-- para el sistema hospitalario de gestión de masajes
-- ORDEN: Tablas → Datos → Triggers → RLS (para evitar errores)

-- FASE 1: CREAR TABLAS BÁSICAS
-- ================================================================

-- Tabla users (sin triggers por ahora)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    rol VARCHAR(50) NOT NULL DEFAULT 'paciente',
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    fecha_nacimiento DATE,
    direccion TEXT,
    nombre_contacto_emergencia VARCHAR(100),
    telefono_contacto_emergencia VARCHAR(20),
    activo BOOLEAN DEFAULT true,
    requiere_2fa BOOLEAN DEFAULT false,
    email_verificado BOOLEAN DEFAULT false,
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ultimo_login TIMESTAMP WITH TIME ZONE
);

-- Tabla therapists (sin triggers por ahora)
CREATE TABLE therapists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    license_number VARCHAR(100) UNIQUE NOT NULL,
    specializations TEXT[],
    available BOOLEAN DEFAULT true,
    work_schedule JSONB,
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla appointments (sin triggers por ahora)
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES users(id) ON DELETE CASCADE,
    therapist_id UUID REFERENCES therapists(id) ON DELETE CASCADE,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    duration_minutes INTEGER DEFAULT 60,
    massage_type VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    created_by UUID REFERENCES users(id),
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancelled_by UUID REFERENCES users(id),
    cancellation_reason TEXT
);

-- Tabla notifications (sin triggers por ahora)
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT false,
    appointment_id UUID REFERENCES appointments(id),
    scheduled_for TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE,
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla audit_logs (sin triggers por ahora)
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- FASE 2: CREAR ÍNDICES PARA PERFORMANCE
-- ================================================================

-- Indexes para users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_rol ON users(rol);
CREATE INDEX idx_users_activo ON users(activo);

-- Indexes para therapists
CREATE INDEX idx_therapists_user_id ON therapists(user_id);
CREATE INDEX idx_therapists_license_number ON therapists(license_number);
CREATE INDEX idx_therapists_available ON therapists(available);
CREATE INDEX idx_therapists_specializations ON therapists USING GIN(specializations);

-- Indexes para appointments
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_therapist_id ON appointments(therapist_id);
CREATE INDEX idx_appointments_appointment_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_date_time ON appointments(appointment_date, appointment_time);
CREATE INDEX idx_appointments_created_by ON appointments(created_by);

-- Indexes para notifications
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_read ON notifications(read);
CREATE INDEX idx_notifications_appointment_id ON notifications(appointment_id);
CREATE INDEX idx_notifications_scheduled_for ON notifications(scheduled_for);
CREATE INDEX idx_notifications_sent_at ON notifications(sent_at);
CREATE INDEX idx_notifications_creado_en ON notifications(creado_en);

-- Indexes para audit_logs
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX idx_audit_logs_record_id ON audit_logs(record_id);
CREATE INDEX idx_audit_logs_creado_en ON audit_logs(creado_en);

-- FASE 3: CREAR CONSTRAINTS
-- ================================================================

-- Constraint para evitar citas duplicadas
ALTER TABLE appointments ADD CONSTRAINT unique_appointment_therapist_date_time 
    UNIQUE (therapist_id, appointment_date, appointment_time);

-- FASE 4: INSERTAR DATOS DE EJEMPLO (SIN TRIGGERS ACTIVOS)
-- ================================================================

-- Insertar usuario del sistema para auditoría
INSERT INTO users (id, email, rol, nombre, apellido, telefono, activo, requiere_2fa, email_verificado) VALUES
    ('00000000-0000-0000-0000-000000000000', 'system@hospital.com', 'sistema', 'Sistema', 'Auditoría', '000-0000', true, false, true);

-- Insertar usuarios de prueba
INSERT INTO users (id, email, rol, nombre, apellido, telefono, activo, requiere_2fa, email_verificado) VALUES
    -- Admin user
    ('00000000-0000-0000-0000-000000000001', 'admin@hospital.com', 'admin', 'Juan', 'Pérez', '555-0001', true, true, true),
    -- Therapist users
    ('00000000-0000-0000-0000-000000000002', 'terapeuta1@hospital.com', 'terapeuta', 'María', 'González', '555-0002', true, true, true),
    ('00000000-0000-0000-0000-000000000003', 'terapeuta2@hospital.com', 'terapeuta', 'Carlos', 'Rodríguez', '555-0003', true, true, true),
    -- Receptionist user
    ('00000000-0000-0000-0000-000000000004', 'recepcion@hospital.com', 'recepcionista', 'Ana', 'Martínez', '555-0004', true, false, true),
    -- Patient users
    ('00000000-0000-0000-0000-000000000005', 'paciente1@hospital.com', 'paciente', 'Luis', 'García', '555-0005', true, false, true),
    ('00000000-0000-0000-0000-000000000006', 'paciente2@hospital.com', 'paciente', 'Carmen', 'López', '555-0006', true, false, true),
    ('00000000-0000-0000-0000-000000000007', 'paciente3@hospital.com', 'paciente', 'Roberto', 'Jiménez', '555-0007', true, false, true);

-- Insertar terapeutas
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

-- Insertar citas de ejemplo
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

-- Insertar notificaciones de ejemplo
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
        'Tiene una nueva cita programada para mañana a las 10:00 AM',
        false,
        '00000000-0000-0000-0000-000000000201'
    );

-- FASE 5: CREAR FUNCIONES DE UTILIDAD
-- ================================================================

-- Función para actualizar actualizado_en
CREATE OR REPLACE FUNCTION update_actualizado_en_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.actualizado_en = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Función para marcar notificaciones como leídas
CREATE OR REPLACE FUNCTION mark_notifications_as_read(user_uuid UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE notifications 
    SET read = true 
    WHERE user_id = user_uuid AND read = false;
END;
$$ LANGUAGE plpgsql;

-- Función para limpiar notificaciones antiguas
CREATE OR REPLACE FUNCTION clean_old_notifications()
RETURNS VOID AS $$
BEGIN
    DELETE FROM notifications 
    WHERE creado_en < NOW() - INTERVAL '6 months';
END;
$$ LANGUAGE plpgsql;

-- Función para limpiar logs de auditoría antiguos
CREATE OR REPLACE FUNCTION clean_old_audit_logs()
RETURNS VOID AS $$
BEGIN
    DELETE FROM audit_logs 
    WHERE creado_en < NOW() - INTERVAL '2 years';
END;
$$ LANGUAGE plpgsql;

-- Función para obtener credenciales de prueba
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
        'Hospital123!'::TEXT, 
        'Administrador del sistema'::TEXT
    UNION ALL
    SELECT 
        'therapist'::TEXT, 
        'terapeuta1@hospital.com'::TEXT, 
        'Masaje123!'::TEXT, 
        'Terapeuta - María González'::TEXT
    UNION ALL
    SELECT 
        'receptionist'::TEXT, 
        'recepcion@hospital.com'::TEXT, 
        'Recepcion123!'::TEXT, 
        'Recepcionista - Ana Martínez'::TEXT
    UNION ALL
    SELECT 
        'patient'::TEXT, 
        'paciente1@hospital.com'::TEXT, 
        'Paciente123!'::TEXT, 
        'Paciente - Luis García'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- FASE 6: CREAR TRIGGERS SEGUROS (AL FINAL)
-- ================================================================

-- Trigger para actualizar actualizado_en en users
CREATE TRIGGER trigger_update_users_actualizado_en
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_actualizado_en_column();

-- Trigger para actualizar actualizado_en en therapists
CREATE TRIGGER trigger_update_therapists_actualizado_en
    BEFORE UPDATE ON therapists
    FOR EACH ROW
    EXECUTE FUNCTION update_actualizado_en_column();

-- Trigger para actualizar actualizado_en en appointments
CREATE TRIGGER trigger_update_appointments_actualizado_en
    BEFORE UPDATE ON appointments
    FOR EACH ROW
    EXECUTE FUNCTION update_actualizado_en_column();

-- Función segura para auditoría (usa usuario del sistema si no hay usuario actual)
CREATE OR REPLACE FUNCTION safe_audit_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
    old_data JSONB;
    new_data JSONB;
    audit_user_id UUID;
BEGIN
    -- Usar usuario del sistema como fallback
    audit_user_id := COALESCE(
        NULLIF(current_setting('app.current_user_id', true), '')::UUID,
        '00000000-0000-0000-0000-000000000000'::UUID
    );
    
    -- Convertir datos a JSON
    IF TG_OP = 'DELETE' THEN
        old_data := to_jsonb(OLD);
        new_data := NULL;
    ELSIF TG_OP = 'INSERT' THEN
        old_data := NULL;
        new_data := to_jsonb(NEW);
    ELSIF TG_OP = 'UPDATE' THEN
        old_data := to_jsonb(OLD);
        new_data := to_jsonb(NEW);
    END IF;

    -- Insertar log de auditoría
    INSERT INTO audit_logs (
        user_id, action, table_name, record_id, 
        old_values, new_values
    ) VALUES (
        audit_user_id,
        TG_OP,
        TG_TABLE_NAME,
        CASE 
            WHEN TG_OP = 'DELETE' THEN OLD.id
            ELSE NEW.id
        END,
        old_data,
        new_data
    );

    -- Retornar fila apropiada
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Crear triggers de auditoría SOLO para operaciones futuras
CREATE TRIGGER audit_users_trigger
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION safe_audit_trigger_function();

CREATE TRIGGER audit_therapists_trigger
    AFTER INSERT OR UPDATE OR DELETE ON therapists
    FOR EACH ROW EXECUTE FUNCTION safe_audit_trigger_function();

CREATE TRIGGER audit_appointments_trigger
    AFTER INSERT OR UPDATE OR DELETE ON appointments
    FOR EACH ROW EXECUTE FUNCTION safe_audit_trigger_function();

CREATE TRIGGER audit_notifications_trigger
    AFTER INSERT OR UPDATE OR DELETE ON notifications
    FOR EACH ROW EXECUTE FUNCTION safe_audit_trigger_function();

-- FASE 7: CONFIGURAR ROW LEVEL SECURITY (RLS)
-- ================================================================

-- Deshabilitar RLS para permitir acceso inicial (para que la app funcione)
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE therapists DISABLE ROW LEVEL SECURITY;
ALTER TABLE appointments DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs DISABLE ROW LEVEL SECURITY;

-- Nota: Las funciones de auth se crearán más tarde cuando sea necesario
-- Por ahora, el sistema funcionará sin RLS para permitir el acceso inicial

-- FASE 8: CREAR USUARIOS DE PRUEBA EN AUTH
-- ================================================================

-- Nota: Los usuarios de prueba deben ser creados en Supabase Auth
-- Esto debe hacerse manualmente o via API, no via SQL

-- FASE 9: COMENTARIOS Y FINALIZACIÓN
-- ================================================================
COMMENT ON TABLE users IS 'Tabla de usuarios del sistema hospitalario de masajes';
COMMENT ON TABLE therapists IS 'Tabla de terapeutas certificados';
COMMENT ON TABLE appointments IS 'Tabla de citas de masajes';
COMMENT ON TABLE notifications IS 'Tabla de notificaciones del sistema';
COMMENT ON TABLE audit_logs IS 'Tabla de logs de auditoría para rastrear cambios';
COMMENT ON FUNCTION get_test_credentials() IS 'Devuelve credenciales de prueba para desarrollo';

-- Mensaje final de éxito
SELECT 'SUCCESS: ¡Migración completada exitosamente! Base de datos lista para usar con datos de prueba.' AS status;
SELECT 'INFO: RLS está deshabilitado para permitir acceso inicial.' AS security_info;
SELECT 'NEXT: Crear usuarios de prueba en Supabase Auth Dashboard.' AS next_step; 