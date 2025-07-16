-- Agregar campo registration_method a la tabla users
-- Este campo ayuda a identificar cómo se registró el usuario

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS registration_method VARCHAR(50) DEFAULT 'normal';

-- Comentario para documentar el campo
COMMENT ON COLUMN users.registration_method IS 'Método de registro: normal, fallback, manual, etc.';

-- Actualizar usuarios existentes
UPDATE users 
SET registration_method = 'normal' 
WHERE registration_method IS NULL; 