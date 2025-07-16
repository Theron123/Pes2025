-- ============================================
-- PASO 1: CREAR TABLA TERAPEUTAS (VERSIÓN SIMPLE)
-- ============================================
-- Copia todo este contenido y pégalo en el SQL Editor de Supabase
-- Dashboard: https://supabase.com/dashboard/project/kvcbafrudpznlkcbkbnv

-- Primero, crear la función actualizar_updated_at si no existe
CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear tabla de terapeutas
CREATE TABLE terapeutas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE,
    numero_licencia VARCHAR(100) UNIQUE NOT NULL,
    especializaciones TEXT[],
    disponible BOOLEAN DEFAULT true,
    horario_trabajo JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índices para mejorar rendimiento
CREATE INDEX idx_terapeutas_usuario_id ON terapeutas(usuario_id);
CREATE INDEX idx_terapeutas_numero_licencia ON terapeutas(numero_licencia);
CREATE INDEX idx_terapeutas_disponible ON terapeutas(disponible);
CREATE INDEX idx_terapeutas_especializaciones ON terapeutas USING GIN(especializaciones);

-- Crear trigger para actualizar updated_at
CREATE TRIGGER trigger_actualizar_updated_at_terapeutas
    BEFORE UPDATE ON terapeutas
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- Comentarios descriptivos en español
COMMENT ON TABLE terapeutas IS 'Tabla de terapeutas certificados del sistema hospitalario';
COMMENT ON COLUMN terapeutas.usuario_id IS 'Referencia al usuario asociado al terapeuta';
COMMENT ON COLUMN terapeutas.numero_licencia IS 'Número único de licencia profesional del terapeuta';
COMMENT ON COLUMN terapeutas.especializaciones IS 'Array de especializaciones del terapeuta (Swedish, Deep Tissue, etc.)';
COMMENT ON COLUMN terapeutas.disponible IS 'Indica si el terapeuta está disponible para recibir citas';
COMMENT ON COLUMN terapeutas.horario_trabajo IS 'Horario de trabajo del terapeuta en formato JSON';

-- ============================================
-- FINALIZADO: TABLA TERAPEUTAS CREADA ✅
-- ============================================ 