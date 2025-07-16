-- ============================================
-- PASO 2: CREAR TABLA CITAS
-- ============================================
-- Ejecuta DESPUÉS de haber creado la tabla terapeutas ✅
-- Copia todo este contenido y pégalo en el SQL Editor de Supabase

-- Crear tabla de citas
CREATE TABLE citas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    paciente_id UUID REFERENCES usuarios(id) ON DELETE CASCADE,
    terapeuta_id UUID REFERENCES terapeutas(id) ON DELETE CASCADE,
    fecha_cita DATE NOT NULL,
    hora_cita TIME NOT NULL,
    duracion_minutos INTEGER DEFAULT 60,
    tipo_masaje VARCHAR(100) NOT NULL,
    estado VARCHAR(50) DEFAULT 'pendiente',
    notas TEXT,
    creado_por UUID REFERENCES usuarios(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    cancelado_en TIMESTAMP WITH TIME ZONE,
    cancelado_por UUID REFERENCES usuarios(id),
    razon_cancelacion TEXT
);

-- Crear índices para mejorar rendimiento
CREATE INDEX idx_citas_paciente_id ON citas(paciente_id);
CREATE INDEX idx_citas_terapeuta_id ON citas(terapeuta_id);
CREATE INDEX idx_citas_fecha_cita ON citas(fecha_cita);
CREATE INDEX idx_citas_estado ON citas(estado);
CREATE INDEX idx_citas_fecha_hora ON citas(fecha_cita, hora_cita);
CREATE INDEX idx_citas_creado_por ON citas(creado_por);

-- Crear trigger para actualizar updated_at (usa la función que ya creamos)
CREATE TRIGGER trigger_actualizar_updated_at_citas
    BEFORE UPDATE ON citas
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- Crear constraint para evitar citas duplicadas
ALTER TABLE citas ADD CONSTRAINT unique_cita_terapeuta_fecha_hora 
    UNIQUE (terapeuta_id, fecha_cita, hora_cita);

-- Comentarios descriptivos en español
COMMENT ON TABLE citas IS 'Tabla de citas del sistema de masajes hospitalario';
COMMENT ON COLUMN citas.paciente_id IS 'Referencia al usuario paciente';
COMMENT ON COLUMN citas.terapeuta_id IS 'Referencia al terapeuta asignado';
COMMENT ON COLUMN citas.fecha_cita IS 'Fecha de la cita';
COMMENT ON COLUMN citas.hora_cita IS 'Hora de la cita';
COMMENT ON COLUMN citas.duracion_minutos IS 'Duración de la cita en minutos';
COMMENT ON COLUMN citas.tipo_masaje IS 'Tipo de masaje a realizar';
COMMENT ON COLUMN citas.estado IS 'Estado de la cita: pendiente, confirmada, en_progreso, completada, cancelada, no_show';
COMMENT ON COLUMN citas.notas IS 'Notas adicionales sobre la cita';
COMMENT ON COLUMN citas.creado_por IS 'Usuario que creó la cita';
COMMENT ON COLUMN citas.razon_cancelacion IS 'Razón de la cancelación si aplica';

-- ============================================
-- FINALIZADO: TABLA CITAS CREADA ✅
-- ============================================ 