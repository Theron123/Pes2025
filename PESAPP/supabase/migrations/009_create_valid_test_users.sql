-- Migración: Crear usuarios de prueba con contraseñas válidas
-- Fecha: 2024-01-XX
-- Descripción: Usuarios de prueba con contraseñas que cumplen los nuevos requisitos de seguridad

-- IMPORTANTE: Estos usuarios deben ser creados MANUALMENTE en Supabase Auth Dashboard
-- porque las contraseñas necesitan ser hasheadas correctamente por el sistema de autenticación

-- ========================================
-- USUARIOS DE PRUEBA CON CONTRASEÑAS VÁLIDAS
-- ========================================

-- Función para mostrar credenciales de prueba válidas
CREATE OR REPLACE FUNCTION get_valid_test_credentials()
RETURNS TABLE (
    role TEXT,
    email TEXT,
    password TEXT,
    description TEXT,
    requirements_met TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'admin'::TEXT, 
        'admin@hospital.com'::TEXT, 
        'Hospital123!'::TEXT, 
        'Administrador del sistema'::TEXT,
        '✅ 8+ chars, mayúscula, minúscula, número, especial'::TEXT
    UNION ALL
    SELECT 
        'therapist'::TEXT, 
        'terapeuta1@hospital.com'::TEXT, 
        'Masaje123!'::TEXT, 
        'Terapeuta - María González'::TEXT,
        '✅ 8+ chars, mayúscula, minúscula, número, especial'::TEXT
    UNION ALL
    SELECT 
        'therapist'::TEXT, 
        'terapeuta2@hospital.com'::TEXT, 
        'Terapia456@'::TEXT, 
        'Terapeuta - Carlos Ruiz'::TEXT,
        '✅ 8+ chars, mayúscula, minúscula, número, especial'::TEXT
    UNION ALL
    SELECT 
        'receptionist'::TEXT, 
        'recepcion@hospital.com'::TEXT, 
        'Recepcion123!'::TEXT, 
        'Recepcionista - Ana Martínez'::TEXT,
        '✅ 8+ chars, mayúscula, minúscula, número, especial'::TEXT
    UNION ALL
    SELECT 
        'patient'::TEXT, 
        'paciente1@hospital.com'::TEXT, 
        'Paciente123!'::TEXT, 
        'Paciente - Luis García'::TEXT,
        '✅ 8+ chars, mayúscula, minúscula, número, especial'::TEXT
    UNION ALL
    SELECT 
        'patient'::TEXT, 
        'paciente2@hospital.com'::TEXT, 
        'Citas456@'::TEXT, 
        'Paciente - María López'::TEXT,
        '✅ 8+ chars, mayúscula, minúscula, número, especial'::TEXT
    UNION ALL
    SELECT 
        'patient'::TEXT, 
        'paciente3@hospital.com'::TEXT, 
        'Salud789#'::TEXT, 
        'Paciente - José Martín'::TEXT,
        '✅ 8+ chars, mayúscula, minúscula, número, especial'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Función para mostrar instrucciones de creación
CREATE OR REPLACE FUNCTION show_user_creation_instructions()
RETURNS TABLE (
    step INTEGER,
    instruction TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        1, 'Ir a Supabase Dashboard → Authentication → Users'::TEXT
    UNION ALL
    SELECT 
        2, 'Hacer clic en "Add user" → "Create a new user"'::TEXT
    UNION ALL
    SELECT 
        3, 'Ingresar email y contraseña de la lista de arriba'::TEXT
    UNION ALL
    SELECT 
        4, 'Marcar "Auto Confirm User" para evitar verificación de email'::TEXT
    UNION ALL
    SELECT 
        5, 'Repetir para todos los usuarios de la lista'::TEXT
    UNION ALL
    SELECT 
        6, 'Los perfiles se crearán automáticamente al registrarse en la app'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- ACTUALIZAR CONTRASEÑAS DE USUARIOS EXISTENTES
-- ========================================

-- Función para mostrar cómo actualizar contraseñas existentes
CREATE OR REPLACE FUNCTION show_password_update_instructions()
RETURNS TABLE (
    step INTEGER,
    instruction TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        1, 'Para usuarios existentes en Auth, ir a Authentication → Users'::TEXT
    UNION ALL
    SELECT 
        2, 'Hacer clic en el usuario → "Send magic link"'::TEXT
    UNION ALL
    SELECT 
        3, 'O usar "Reset password" para enviar email de restablecimiento'::TEXT
    UNION ALL
    SELECT 
        4, 'El usuario puede cambiar su contraseña desde la app'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- VERIFICAR REQUISITOS DE CONTRASEÑA
-- ========================================

-- Función para verificar si una contraseña cumple los requisitos
CREATE OR REPLACE FUNCTION verify_password_requirements(password_text TEXT)
RETURNS TABLE (
    requirement TEXT,
    meets_requirement BOOLEAN,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'Mínimo 8 caracteres'::TEXT,
        LENGTH(password_text) >= 8,
        CASE WHEN LENGTH(password_text) >= 8 THEN '✅' ELSE '❌' END
    UNION ALL
    SELECT 
        'Al menos una mayúscula (A-Z)'::TEXT,
        password_text ~ '[A-Z]',
        CASE WHEN password_text ~ '[A-Z]' THEN '✅' ELSE '❌' END
    UNION ALL
    SELECT 
        'Al menos una minúscula (a-z)'::TEXT,
        password_text ~ '[a-z]',
        CASE WHEN password_text ~ '[a-z]' THEN '✅' ELSE '❌' END
    UNION ALL
    SELECT 
        'Al menos un número (0-9)'::TEXT,
        password_text ~ '[0-9]',
        CASE WHEN password_text ~ '[0-9]' THEN '✅' ELSE '❌' END
    UNION ALL
    SELECT 
        'Al menos un carácter especial'::TEXT,
        password_text ~ '[!@#$%^&*(),.?":{}|<>]',
        CASE WHEN password_text ~ '[!@#$%^&*(),.?":{}|<>]' THEN '✅' ELSE '❌' END;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- COMANDOS ÚTILES PARA PRUEBAS
-- ========================================

-- Mostrar credenciales válidas
COMMENT ON FUNCTION get_valid_test_credentials() IS 'Muestra lista de usuarios de prueba con contraseñas válidas';

-- Mostrar instrucciones
COMMENT ON FUNCTION show_user_creation_instructions() IS 'Muestra pasos para crear usuarios en Supabase Auth Dashboard';

-- Verificar contraseña
COMMENT ON FUNCTION verify_password_requirements(TEXT) IS 'Verifica si una contraseña cumple todos los requisitos de seguridad';

-- Mensaje de información
SELECT 'INFO: Ejecutar SELECT * FROM get_valid_test_credentials(); para ver credenciales válidas' AS message;
SELECT 'INFO: Ejecutar SELECT * FROM show_user_creation_instructions(); para ver instrucciones' AS message;
SELECT 'INFO: Ejecutar SELECT * FROM verify_password_requirements(''tu_contraseña''); para verificar contraseña' AS message; 