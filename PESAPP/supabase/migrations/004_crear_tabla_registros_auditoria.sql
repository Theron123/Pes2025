-- Migración: Crear tabla de registros de auditoría
-- Fecha: 2024-01-XX
-- Descripción: Tabla de registros de auditoría para el sistema hospitalario

-- Crear tabla de registros de auditoría
CREATE TABLE registros_auditoria (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID REFERENCES usuarios(id),
    accion VARCHAR(100) NOT NULL,
    tabla_nombre VARCHAR(100),
    registro_id UUID,
    valores_anteriores JSONB,
    valores_nuevos JSONB,
    direccion_ip INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índices para mejorar rendimiento
CREATE INDEX idx_registros_auditoria_usuario_id ON registros_auditoria(usuario_id);
CREATE INDEX idx_registros_auditoria_accion ON registros_auditoria(accion);
CREATE INDEX idx_registros_auditoria_tabla_nombre ON registros_auditoria(tabla_nombre);
CREATE INDEX idx_registros_auditoria_registro_id ON registros_auditoria(registro_id);
CREATE INDEX idx_registros_auditoria_created_at ON registros_auditoria(created_at);

-- Crear función para registrar auditoría automáticamente
CREATE OR REPLACE FUNCTION registrar_auditoria()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO registros_auditoria (
            usuario_id, accion, tabla_nombre, registro_id, valores_anteriores, direccion_ip
        ) VALUES (
            auth.uid(), 'DELETE', TG_TABLE_NAME, OLD.id, row_to_json(OLD), inet_client_addr()
        );
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO registros_auditoria (
            usuario_id, accion, tabla_nombre, registro_id, valores_anteriores, valores_nuevos, direccion_ip
        ) VALUES (
            auth.uid(), 'UPDATE', TG_TABLE_NAME, NEW.id, row_to_json(OLD), row_to_json(NEW), inet_client_addr()
        );
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO registros_auditoria (
            usuario_id, accion, tabla_nombre, registro_id, valores_nuevos, direccion_ip
        ) VALUES (
            auth.uid(), 'INSERT', TG_TABLE_NAME, NEW.id, row_to_json(NEW), inet_client_addr()
        );
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Comentarios descriptivos en español
COMMENT ON TABLE registros_auditoria IS 'Tabla de registros de auditoría del sistema hospitalario';
COMMENT ON COLUMN registros_auditoria.usuario_id IS 'Usuario que realizó la acción';
COMMENT ON COLUMN registros_auditoria.accion IS 'Tipo de acción realizada: INSERT, UPDATE, DELETE';
COMMENT ON COLUMN registros_auditoria.tabla_nombre IS 'Nombre de la tabla afectada';
COMMENT ON COLUMN registros_auditoria.registro_id IS 'ID del registro afectado';
COMMENT ON COLUMN registros_auditoria.valores_anteriores IS 'Valores antes del cambio (JSON)';
COMMENT ON COLUMN registros_auditoria.valores_nuevos IS 'Valores después del cambio (JSON)';
COMMENT ON COLUMN registros_auditoria.direccion_ip IS 'Dirección IP del cliente';
COMMENT ON COLUMN registros_auditoria.user_agent IS 'User Agent del cliente'; 