-- Configuración de Buckets de Storage - Sistema Hospitalario de Masajes
-- Fecha: 2024-01-XX
-- Descripción: Configuración de almacenamiento para archivos del sistema hospitalario

-- ========================================
-- CREAR BUCKETS DE STORAGE
-- ========================================

-- Bucket para imágenes de perfil de usuarios
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'imagenes-perfil',
    'imagenes-perfil',
    false,
    5242880, -- 5MB
    ARRAY['image/jpeg', 'image/png', 'image/webp']
);

-- Bucket para reportes PDF generados
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'reportes-pdf',
    'reportes-pdf',
    false,
    52428800, -- 50MB
    ARRAY['application/pdf']
);

-- Bucket para documentos del sistema (políticas, manuales, etc.)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'documentos-sistema',
    'documentos-sistema',
    false,
    10485760, -- 10MB
    ARRAY['application/pdf', 'text/plain', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
);

-- ========================================
-- POLÍTICAS DE STORAGE PARA IMÁGENES DE PERFIL
-- ========================================

-- Los usuarios pueden ver su propia imagen de perfil
CREATE POLICY "usuarios_pueden_ver_propia_imagen_perfil" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'imagenes-perfil' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Los usuarios pueden subir/actualizar su propia imagen de perfil
CREATE POLICY "usuarios_pueden_subir_propia_imagen_perfil" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'imagenes-perfil' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Los usuarios pueden actualizar su propia imagen de perfil
CREATE POLICY "usuarios_pueden_actualizar_propia_imagen_perfil" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'imagenes-perfil' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Los usuarios pueden eliminar su propia imagen de perfil
CREATE POLICY "usuarios_pueden_eliminar_propia_imagen_perfil" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'imagenes-perfil' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Los administradores pueden ver todas las imágenes de perfil
CREATE POLICY "administradores_pueden_ver_todas_imagenes_perfil" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'imagenes-perfil' AND
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- ========================================
-- POLÍTICAS DE STORAGE PARA REPORTES PDF
-- ========================================

-- Los usuarios pueden ver reportes donde aparecen (pacientes sus propios reportes)
CREATE POLICY "usuarios_pueden_ver_reportes_propios" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'reportes-pdf' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Los administradores y recepcionistas pueden ver todos los reportes
CREATE POLICY "staff_puede_ver_todos_reportes" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'reportes-pdf' AND
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol IN ('admin', 'recepcionista')
        )
    );

-- Los administradores y recepcionistas pueden crear reportes
CREATE POLICY "staff_puede_crear_reportes" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'reportes-pdf' AND
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol IN ('admin', 'recepcionista')
        )
    );

-- Los administradores pueden eliminar reportes
CREATE POLICY "administradores_pueden_eliminar_reportes" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'reportes-pdf' AND
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- ========================================
-- POLÍTICAS DE STORAGE PARA DOCUMENTOS DEL SISTEMA
-- ========================================

-- Todos los usuarios autenticados pueden ver documentos del sistema
CREATE POLICY "usuarios_pueden_ver_documentos_sistema" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'documentos-sistema' AND
        auth.uid() IS NOT NULL
    );

-- Solo administradores pueden subir documentos del sistema
CREATE POLICY "administradores_pueden_subir_documentos_sistema" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'documentos-sistema' AND
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Solo administradores pueden actualizar documentos del sistema
CREATE POLICY "administradores_pueden_actualizar_documentos_sistema" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'documentos-sistema' AND
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Solo administradores pueden eliminar documentos del sistema
CREATE POLICY "administradores_pueden_eliminar_documentos_sistema" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'documentos-sistema' AND
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- ========================================
-- FUNCIONES UTILITARIAS PARA STORAGE
-- ========================================

-- Función para obtener URL pública de imagen de perfil
CREATE OR REPLACE FUNCTION obtener_url_imagen_perfil(usuario_uuid UUID)
RETURNS TEXT AS $$
DECLARE
    file_path TEXT;
BEGIN
    -- Construir la ruta del archivo
    file_path := usuario_uuid::text || '/perfil.jpg';
    
    -- Verificar si existe el archivo
    IF EXISTS (
        SELECT 1 FROM storage.objects 
        WHERE bucket_id = 'imagenes-perfil' AND name = file_path
    ) THEN
        RETURN 'imagenes-perfil/' || file_path;
    ELSE
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Función para limpiar archivos huérfanos
CREATE OR REPLACE FUNCTION limpiar_archivos_huerfanos()
RETURNS INTEGER AS $$
DECLARE
    archivos_eliminados INTEGER := 0;
BEGIN
    -- Eliminar imágenes de perfil de usuarios que ya no existen
    DELETE FROM storage.objects 
    WHERE bucket_id = 'imagenes-perfil' 
    AND NOT EXISTS (
        SELECT 1 FROM usuarios 
        WHERE id::text = (storage.foldername(name))[1]
    );
    
    GET DIAGNOSTICS archivos_eliminados = ROW_COUNT;
    
    RETURN archivos_eliminados;
END;
$$ LANGUAGE plpgsql;

-- Función para obtener estadísticas de uso de storage
CREATE OR REPLACE FUNCTION obtener_estadisticas_storage()
RETURNS TABLE(
    bucket_id TEXT,
    total_archivos BIGINT,
    total_size_mb NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.bucket_id,
        COUNT(*) as total_archivos,
        ROUND(SUM(o.metadata->>'size')::NUMERIC / 1024 / 1024, 2) as total_size_mb
    FROM storage.objects o
    GROUP BY o.bucket_id
    ORDER BY total_size_mb DESC;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- TRIGGERS PARA AUDITORÍA DE STORAGE
-- ========================================

-- Tabla para auditar cambios en storage
CREATE TABLE IF NOT EXISTS storage_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bucket_id TEXT NOT NULL,
    object_name TEXT NOT NULL,
    action VARCHAR(50) NOT NULL,
    user_id UUID REFERENCES usuarios(id),
    file_size INTEGER,
    mime_type TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Función para auditar cambios en storage
CREATE OR REPLACE FUNCTION audit_storage_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO storage_audit_log (bucket_id, object_name, action, user_id, file_size, mime_type)
        VALUES (NEW.bucket_id, NEW.name, 'UPLOAD', auth.uid(), 
                (NEW.metadata->>'size')::INTEGER, NEW.metadata->>'mimetype');
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO storage_audit_log (bucket_id, object_name, action, user_id, file_size, mime_type)
        VALUES (OLD.bucket_id, OLD.name, 'DELETE', auth.uid(), 
                (OLD.metadata->>'size')::INTEGER, OLD.metadata->>'mimetype');
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para auditar cambios en storage
CREATE TRIGGER trigger_audit_storage_changes
    AFTER INSERT OR DELETE ON storage.objects
    FOR EACH ROW
    EXECUTE FUNCTION audit_storage_changes();

-- ========================================
-- COMENTARIOS DESCRIPTIVOS
-- ========================================

COMMENT ON TABLE storage_audit_log IS 'Registro de auditoría para cambios en storage';
COMMENT ON FUNCTION obtener_url_imagen_perfil(UUID) IS 'Obtiene la URL de la imagen de perfil de un usuario';
COMMENT ON FUNCTION limpiar_archivos_huerfanos() IS 'Limpia archivos que ya no tienen referencias válidas';
COMMENT ON FUNCTION obtener_estadisticas_storage() IS 'Obtiene estadísticas de uso de storage por bucket'; 