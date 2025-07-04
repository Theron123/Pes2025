-- Migración: Crear tabla de notificaciones
-- Fecha: 2024-01-XX
-- Descripción: Tabla de notificaciones del sistema hospitalario

-- Crear tabla de notificaciones
CREATE TABLE notificaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE,
    tipo VARCHAR(50) NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    mensaje TEXT NOT NULL,
    leida BOOLEAN DEFAULT false,
    cita_id UUID REFERENCES citas(id),
    programada_para TIMESTAMP WITH TIME ZONE,
    enviada_en TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índices para mejorar rendimiento
CREATE INDEX idx_notificaciones_usuario_id ON notificaciones(usuario_id);
CREATE INDEX idx_notificaciones_tipo ON notificaciones(tipo);
CREATE INDEX idx_notificaciones_leida ON notificaciones(leida);
CREATE INDEX idx_notificaciones_cita_id ON notificaciones(cita_id);
CREATE INDEX idx_notificaciones_programada_para ON notificaciones(programada_para);
CREATE INDEX idx_notificaciones_enviada_en ON notificaciones(enviada_en);
CREATE INDEX idx_notificaciones_created_at ON notificaciones(created_at);

-- Crear función para marcar notificaciones como leídas
CREATE OR REPLACE FUNCTION marcar_notificaciones_leidas(usuario_uuid UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE notificaciones 
    SET leida = true 
    WHERE usuario_id = usuario_uuid AND leida = false;
END;
$$ LANGUAGE plpgsql;

-- Crear función para limpiar notificaciones antiguas
CREATE OR REPLACE FUNCTION limpiar_notificaciones_antiguas()
RETURNS VOID AS $$
BEGIN
    DELETE FROM notificaciones 
    WHERE created_at < NOW() - INTERVAL '6 months';
END;
$$ LANGUAGE plpgsql;

-- Comentarios descriptivos en español
COMMENT ON TABLE notificaciones IS 'Tabla de notificaciones del sistema hospitalario';
COMMENT ON COLUMN notificaciones.usuario_id IS 'Usuario destinatario de la notificación';
COMMENT ON COLUMN notificaciones.tipo IS 'Tipo de notificación: cita_confirmada, recordatorio, cancelacion, etc.';
COMMENT ON COLUMN notificaciones.titulo IS 'Título de la notificación';
COMMENT ON COLUMN notificaciones.mensaje IS 'Mensaje completo de la notificación';
COMMENT ON COLUMN notificaciones.leida IS 'Indica si la notificación ha sido leída';
COMMENT ON COLUMN notificaciones.cita_id IS 'Referencia a la cita relacionada (opcional)';
COMMENT ON COLUMN notificaciones.programada_para IS 'Fecha y hora programada para envío';
COMMENT ON COLUMN notificaciones.enviada_en IS 'Fecha y hora en que fue enviada la notificación'; 