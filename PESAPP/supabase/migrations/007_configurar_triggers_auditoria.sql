-- Migración: Configurar triggers de auditoría
-- Fecha: 2024-01-XX
-- Descripción: Configuración de triggers para auditoría automática en el sistema hospitalario

-- ========================================
-- TRIGGERS DE AUDITORÍA PARA TABLA USUARIOS
-- ========================================

-- Trigger para auditar cambios en usuarios
CREATE TRIGGER trigger_auditoria_usuarios
    AFTER INSERT OR UPDATE OR DELETE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION registrar_auditoria();

-- ========================================
-- TRIGGERS DE AUDITORÍA PARA TABLA TERAPEUTAS
-- ========================================

-- Trigger para auditar cambios en terapeutas
CREATE TRIGGER trigger_auditoria_terapeutas
    AFTER INSERT OR UPDATE OR DELETE ON terapeutas
    FOR EACH ROW
    EXECUTE FUNCTION registrar_auditoria();

-- ========================================
-- TRIGGERS DE AUDITORÍA PARA TABLA CITAS
-- ========================================

-- Trigger para auditar cambios en citas
CREATE TRIGGER trigger_auditoria_citas
    AFTER INSERT OR UPDATE OR DELETE ON citas
    FOR EACH ROW
    EXECUTE FUNCTION registrar_auditoria();

-- ========================================
-- FUNCIONES ADICIONALES PARA AUDITORÍA
-- ========================================

-- Función para obtener resumen de auditoría por usuario
CREATE OR REPLACE FUNCTION obtener_resumen_auditoria_usuario(usuario_uuid UUID)
RETURNS TABLE(
    accion VARCHAR(100),
    tabla_nombre VARCHAR(100),
    contador BIGINT,
    ultima_accion TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ra.accion,
        ra.tabla_nombre,
        COUNT(*) as contador,
        MAX(ra.created_at) as ultima_accion
    FROM registros_auditoria ra
    WHERE ra.usuario_id = usuario_uuid
    GROUP BY ra.accion, ra.tabla_nombre
    ORDER BY ultima_accion DESC;
END;
$$ LANGUAGE plpgsql;

-- Función para obtener actividad reciente
CREATE OR REPLACE FUNCTION obtener_actividad_reciente(limite INTEGER DEFAULT 50)
RETURNS TABLE(
    id UUID,
    usuario_nombre VARCHAR(201),
    usuario_rol VARCHAR(50),
    accion VARCHAR(100),
    tabla_nombre VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ra.id,
        CONCAT(u.nombre, ' ', u.apellido) as usuario_nombre,
        u.rol as usuario_rol,
        ra.accion,
        ra.tabla_nombre,
        ra.created_at
    FROM registros_auditoria ra
    LEFT JOIN usuarios u ON ra.usuario_id = u.id
    ORDER BY ra.created_at DESC
    LIMIT limite;
END;
$$ LANGUAGE plpgsql;

-- Función para limpiar registros de auditoría antiguos (retención de 5 años)
CREATE OR REPLACE FUNCTION limpiar_auditoria_antigua()
RETURNS VOID AS $$
BEGIN
    DELETE FROM registros_auditoria 
    WHERE created_at < NOW() - INTERVAL '5 years';
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- ÍNDICES ADICIONALES PARA RENDIMIENTO
-- ========================================

-- Índice compuesto para búsquedas de auditoría por usuario y fecha
CREATE INDEX idx_registros_auditoria_usuario_fecha 
    ON registros_auditoria(usuario_id, created_at DESC);

-- Índice para búsquedas por tabla y acción
CREATE INDEX idx_registros_auditoria_tabla_accion 
    ON registros_auditoria(tabla_nombre, accion);

-- Comentarios adicionales
COMMENT ON FUNCTION obtener_resumen_auditoria_usuario(UUID) IS 'Obtiene resumen de acciones de auditoría para un usuario específico';
COMMENT ON FUNCTION obtener_actividad_reciente(INTEGER) IS 'Obtiene la actividad reciente del sistema con límite configurable';
COMMENT ON FUNCTION limpiar_auditoria_antigua() IS 'Limpia registros de auditoría más antiguos de 5 años para cumplir con políticas de retención'; 