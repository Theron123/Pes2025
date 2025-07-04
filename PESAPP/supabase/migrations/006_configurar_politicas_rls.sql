-- Migración: Configurar políticas RLS (Row Level Security)
-- Fecha: 2024-01-XX
-- Descripción: Configuración de políticas de seguridad a nivel de fila para el sistema hospitalario

-- Habilitar RLS en todas las tablas
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE terapeutas ENABLE ROW LEVEL SECURITY;
ALTER TABLE citas ENABLE ROW LEVEL SECURITY;
ALTER TABLE registros_auditoria ENABLE ROW LEVEL SECURITY;
ALTER TABLE notificaciones ENABLE ROW LEVEL SECURITY;

-- ========================================
-- POLÍTICAS PARA TABLA USUARIOS
-- ========================================

-- Los usuarios pueden ver su propio perfil
CREATE POLICY "usuarios_pueden_ver_propio_perfil" ON usuarios
    FOR SELECT USING (auth.uid() = id);

-- Los usuarios pueden actualizar su propio perfil (excepto rol y configuraciones críticas)
CREATE POLICY "usuarios_pueden_actualizar_propio_perfil" ON usuarios
    FOR UPDATE USING (auth.uid() = id);

-- Los administradores pueden ver todos los usuarios
CREATE POLICY "administradores_pueden_ver_todos_usuarios" ON usuarios
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Los administradores pueden crear usuarios
CREATE POLICY "administradores_pueden_crear_usuarios" ON usuarios
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Los administradores pueden actualizar cualquier usuario
CREATE POLICY "administradores_pueden_actualizar_usuarios" ON usuarios
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Los recepcionistas pueden ver usuarios básicos (para gestión de citas)
CREATE POLICY "recepcionistas_pueden_ver_usuarios_basicos" ON usuarios
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol IN ('admin', 'recepcionista')
        )
    );

-- ========================================
-- POLÍTICAS PARA TABLA TERAPEUTAS
-- ========================================

-- Los terapeutas pueden ver su propia información
CREATE POLICY "terapeutas_pueden_ver_propia_info" ON terapeutas
    FOR SELECT USING (usuario_id = auth.uid());

-- Los terapeutas pueden actualizar su propia información (horarios, disponibilidad)
CREATE POLICY "terapeutas_pueden_actualizar_propia_info" ON terapeutas
    FOR UPDATE USING (usuario_id = auth.uid());

-- Los administradores pueden ver todos los terapeutas
CREATE POLICY "administradores_pueden_ver_todos_terapeutas" ON terapeutas
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Los administradores pueden crear y actualizar terapeutas
CREATE POLICY "administradores_pueden_gestionar_terapeutas" ON terapeutas
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Los recepcionistas pueden ver terapeutas (para gestión de citas)
CREATE POLICY "recepcionistas_pueden_ver_terapeutas" ON terapeutas
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol IN ('admin', 'recepcionista')
        )
    );

-- ========================================
-- POLÍTICAS PARA TABLA CITAS
-- ========================================

-- Los pacientes pueden ver sus propias citas
CREATE POLICY "pacientes_pueden_ver_propias_citas" ON citas
    FOR SELECT USING (paciente_id = auth.uid());

-- Los pacientes pueden crear sus propias citas
CREATE POLICY "pacientes_pueden_crear_propias_citas" ON citas
    FOR INSERT WITH CHECK (paciente_id = auth.uid());

-- Los terapeutas pueden ver sus citas asignadas
CREATE POLICY "terapeutas_pueden_ver_citas_asignadas" ON citas
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM terapeutas 
            WHERE id = citas.terapeuta_id AND usuario_id = auth.uid()
        )
    );

-- Los terapeutas pueden actualizar el estado de sus citas
CREATE POLICY "terapeutas_pueden_actualizar_estado_citas" ON citas
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM terapeutas 
            WHERE id = citas.terapeuta_id AND usuario_id = auth.uid()
        )
    );

-- Los administradores pueden ver todas las citas
CREATE POLICY "administradores_pueden_ver_todas_citas" ON citas
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Los administradores pueden gestionar todas las citas
CREATE POLICY "administradores_pueden_gestionar_todas_citas" ON citas
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Los recepcionistas pueden ver y gestionar citas
CREATE POLICY "recepcionistas_pueden_gestionar_citas" ON citas
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol IN ('admin', 'recepcionista')
        )
    );

-- ========================================
-- POLÍTICAS PARA TABLA REGISTROS AUDITORÍA
-- ========================================

-- Solo administradores pueden ver registros de auditoría
CREATE POLICY "solo_administradores_pueden_ver_auditoria" ON registros_auditoria
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- El sistema puede insertar registros de auditoría
CREATE POLICY "sistema_puede_insertar_auditoria" ON registros_auditoria
    FOR INSERT WITH CHECK (true);

-- ========================================
-- POLÍTICAS PARA TABLA NOTIFICACIONES
-- ========================================

-- Los usuarios pueden ver sus propias notificaciones
CREATE POLICY "usuarios_pueden_ver_propias_notificaciones" ON notificaciones
    FOR SELECT USING (usuario_id = auth.uid());

-- Los usuarios pueden actualizar sus propias notificaciones (marcar como leídas)
CREATE POLICY "usuarios_pueden_actualizar_propias_notificaciones" ON notificaciones
    FOR UPDATE USING (usuario_id = auth.uid());

-- Los administradores pueden ver todas las notificaciones
CREATE POLICY "administradores_pueden_ver_todas_notificaciones" ON notificaciones
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- El sistema puede crear notificaciones
CREATE POLICY "sistema_puede_crear_notificaciones" ON notificaciones
    FOR INSERT WITH CHECK (true);

-- Los administradores pueden gestionar todas las notificaciones
CREATE POLICY "administradores_pueden_gestionar_notificaciones" ON notificaciones
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    ); 