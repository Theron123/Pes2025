-- Crear usuarios de prueba SIMPLES para testing
-- Estos usuarios tendrán UUIDs fijos para facilitar las pruebas

-- Limpiar usuarios existentes si existen
DELETE FROM users WHERE email IN (
  'admin@hospital.com',
  'terapeuta1@hospital.com',
  'recepcion@hospital.com',
  'paciente1@hospital.com'
);

-- Insertar usuarios de prueba con UUIDs fijos
INSERT INTO users (
  id,
  email,
  rol,
  nombre,
  apellido,
  telefono,
  fecha_nacimiento,
  activo,
  email_verificado,
  requiere_2fa,
  created_at,
  registration_method
) VALUES 
-- Administrador
(
  '11111111-1111-1111-1111-111111111111',
  'admin@hospital.com',
  'admin',
  'Admin',
  'Hospital',
  '+1234567890',
  '1980-01-01',
  true,
  true,
  true,
  NOW(),
  'manual'
),
-- Terapeuta
(
  '22222222-2222-2222-2222-222222222222',
  'terapeuta1@hospital.com',
  'terapeuta',
  'María',
  'González',
  '+1234567891',
  '1985-05-15',
  true,
  true,
  true,
  NOW(),
  'manual'
),
-- Recepcionista
(
  '33333333-3333-3333-3333-333333333333',
  'recepcion@hospital.com',
  'recepcionista',
  'Ana',
  'Martínez',
  '+1234567892',
  '1990-03-20',
  true,
  true,
  false,
  NOW(),
  'manual'
),
-- Paciente
(
  '44444444-4444-4444-4444-444444444444',
  'paciente1@hospital.com',
  'paciente',
  'Luis',
  'García',
  '+1234567893',
  '1992-07-10',
  true,
  true,
  false,
  NOW(),
  'manual'
);

-- Mensaje de confirmación
SELECT 'Usuarios de prueba creados exitosamente' as message; 