-- Migración: Crear tabla de usuarios
-- Fecha: 2024-01-XX
-- Descripción: Tabla principal de usuarios del sistema hospitalario

-- Crear tabla de usuarios
CREATE TABLE usuarios (
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ultimo_login TIMESTAMP WITH TIME ZONE
);

-- Crear índices para mejorar rendimiento
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_rol ON usuarios(rol);
CREATE INDEX idx_usuarios_activo ON usuarios(activo);

-- Crear función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para actualizar updated_at
CREATE TRIGGER trigger_actualizar_updated_at_usuarios
    BEFORE UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- Comentarios descriptivos en español
COMMENT ON TABLE usuarios IS 'Tabla de usuarios del sistema hospitalario de masajes';
COMMENT ON COLUMN usuarios.rol IS 'Rol del usuario: admin, terapeuta, recepcionista, paciente';
COMMENT ON COLUMN usuarios.requiere_2fa IS 'Indica si el usuario requiere autenticación de dos factores (requerido para admin y terapeuta)';
COMMENT ON COLUMN usuarios.email_verificado IS 'Indica si el email del usuario ha sido verificado';
COMMENT ON COLUMN usuarios.activo IS 'Indica si la cuenta del usuario está activa'; 