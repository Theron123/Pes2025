# 🚀 Hospital Massage System - Setup Supabase Guide

## 📋 **RESUMEN**
Este archivo te guiará paso a paso para hacer la aplicación **completamente funcional** con Supabase.

## 🔧 **PASO 1: Crear Proyecto Supabase**

1. Ve a [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Crea un nuevo proyecto:
   - **Name**: Hospital Massage System
   - **Database Password**: (Guarda esta contraseña)
   - **Region**: Selecciona la más cercana
3. Espera a que se complete la configuración

## 🛠️ **PASO 2: Aplicar Migraciones**

### **Migración 1: Users Table**
```sql
-- Migration: Create users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'patient',
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    birth_date DATE,
    address TEXT,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    active BOOLEAN DEFAULT true,
    requires_2fa BOOLEAN DEFAULT false,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE
);

-- Create indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(active);

-- Create function to automatically update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update updated_at
CREATE TRIGGER trigger_update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### **Migración 2: Therapists Table**
```sql
-- Migration: Create therapists table
CREATE TABLE therapists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    license_number VARCHAR(100) UNIQUE NOT NULL,
    specializations TEXT[],
    available BOOLEAN DEFAULT true,
    work_schedule JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_therapists_user_id ON therapists(user_id);
CREATE INDEX idx_therapists_license_number ON therapists(license_number);
CREATE INDEX idx_therapists_available ON therapists(available);
CREATE INDEX idx_therapists_specializations ON therapists USING GIN(specializations);

-- Create trigger to update updated_at
CREATE TRIGGER trigger_update_therapists_updated_at
    BEFORE UPDATE ON therapists
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### **Migración 3: Appointments Table**
```sql
-- Migration: Create appointments table
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancelled_by UUID REFERENCES users(id),
    cancellation_reason TEXT
);

-- Create indexes for performance
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_therapist_id ON appointments(therapist_id);
CREATE INDEX idx_appointments_appointment_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_date_time ON appointments(appointment_date, appointment_time);
CREATE INDEX idx_appointments_created_by ON appointments(created_by);

-- Create trigger to update updated_at
CREATE TRIGGER trigger_update_appointments_updated_at
    BEFORE UPDATE ON appointments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create constraint to prevent duplicate appointments
ALTER TABLE appointments ADD CONSTRAINT unique_appointment_therapist_date_time 
    UNIQUE (therapist_id, appointment_date, appointment_time);
```

### **Migración 4: Notifications Table**
```sql
-- Migration: Create notifications table
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_read ON notifications(read);
CREATE INDEX idx_notifications_appointment_id ON notifications(appointment_id);
CREATE INDEX idx_notifications_scheduled_for ON notifications(scheduled_for);
CREATE INDEX idx_notifications_sent_at ON notifications(sent_at);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
```

### **Migración 5: Audit Logs Table**
```sql
-- Migration: Create audit logs table
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX idx_audit_logs_record_id ON audit_logs(record_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
```

## 🔐 **PASO 3: Configurar Políticas de Seguridad (RLS)**

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE therapists ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id::text::uuid);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id::text::uuid);

CREATE POLICY "Admins can manage all users" ON users
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid()::text::uuid 
            AND role = 'admin'
        )
    );

-- Therapists table policies
CREATE POLICY "Therapists can view their own profile" ON therapists
    FOR SELECT USING (user_id = auth.uid()::text::uuid);

CREATE POLICY "Admins can manage all therapists" ON therapists
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid()::text::uuid 
            AND role = 'admin'
        )
    );

-- Appointments table policies
CREATE POLICY "Patients can view their own appointments" ON appointments
    FOR SELECT USING (patient_id = auth.uid()::text::uuid);

CREATE POLICY "Therapists can view their appointments" ON appointments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM therapists 
            WHERE user_id = auth.uid()::text::uuid 
            AND id = appointments.therapist_id
        )
    );

CREATE POLICY "Staff can manage all appointments" ON appointments
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid()::text::uuid 
            AND role IN ('admin', 'receptionist')
        )
    );

-- Notifications table policies
CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (user_id = auth.uid()::text::uuid);

CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE USING (user_id = auth.uid()::text::uuid);

-- Audit logs table policies
CREATE POLICY "Admins can view all audit logs" ON audit_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid()::text::uuid 
            AND role = 'admin'
        )
    );
```

## 📊 **PASO 4: Insertar Datos de Prueba**

```sql
-- Insert sample users
INSERT INTO users (id, email, role, first_name, last_name, phone, active, requires_2fa, email_verified) VALUES
  ('00000000-0000-0000-0000-000000000001', 'admin@hospital.com', 'admin', 'Juan', 'Pérez', '555-0001', true, true, true),
  ('00000000-0000-0000-0000-000000000002', 'terapeuta1@hospital.com', 'therapist', 'María', 'González', '555-0002', true, true, true),
  ('00000000-0000-0000-0000-000000000003', 'terapeuta2@hospital.com', 'therapist', 'Carlos', 'Rodríguez', '555-0003', true, true, true),
  ('00000000-0000-0000-0000-000000000004', 'recepcion@hospital.com', 'receptionist', 'Ana', 'Martínez', '555-0004', true, false, true),
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
  );
```

## 🎯 **PASO 5: Configurar Autenticación**

1. En Supabase Dashboard, ve a **Authentication** → **Settings**
2. Configura:
   - **Site URL**: `http://localhost:3000` (para desarrollo)
   - **Redirect URLs**: `http://localhost:3000/**`
3. Habilita **Email confirmation** (opcional para desarrollo)

## 🔑 **PASO 6: Obtener Credenciales**

1. En Supabase Dashboard, ve a **Settings** → **API**
2. Copia:
   - **Project URL**: `https://tu-proyecto.supabase.co`
   - **Anon (public) Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

## 📱 **PASO 7: Configurar la Aplicación**

Actualiza el archivo `lib/app/constants/api_constants.dart`:

```dart
static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
static const String supabaseAnonKey = 'tu-anon-key-aqui';
```

## 🧪 **PASO 8: Credenciales de Prueba**

Una vez configurado, puedes usar estas credenciales para probar:

| Rol | Email | Password | Descripción |
|-----|-------|----------|-------------|
| Admin | admin@hospital.com | 123456 | Administrador del sistema |
| Therapist | terapeuta1@hospital.com | 123456 | Terapeuta - María González |
| Receptionist | recepcion@hospital.com | 123456 | Recepcionista - Ana Martínez |
| Patient | paciente1@hospital.com | 123456 | Paciente - Luis García |

## ✅ **PASO 9: Probar la Aplicación**

1. Ejecuta: `flutter run`
2. Inicia sesión con cualquiera de las credenciales de prueba
3. Verifica que puedas:
   - Ver el dashboard según tu rol
   - Navegar entre secciones
   - Crear/ver citas
   - Recibir notificaciones
   - Gestionar perfil

## 🎉 **¡LISTO!**

Tu aplicación ahora está **completamente funcional** con:
- ✅ Base de datos configurada
- ✅ Autenticación funcionando
- ✅ Datos de prueba cargados
- ✅ Políticas de seguridad activas
- ✅ Todas las funcionalidades operativas

## 🚨 **IMPORTANTE PARA PRODUCCIÓN**

Para uso en producción, recuerda:
1. Cambiar las contraseñas de los usuarios de prueba
2. Configurar variables de entorno seguras
3. Habilitar 2FA para administradores
4. Revisar las políticas de seguridad
5. Configurar backups automáticos 