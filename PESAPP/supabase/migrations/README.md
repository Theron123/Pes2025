# Migraciones de Base de Datos - Sistema Hospitalario de Masajes

## 📋 Descripción

Este directorio contiene todas las migraciones SQL necesarias para configurar la base de datos del sistema hospitalario de masajes en Supabase.

## 🚀 Orden de Ejecución

Las migraciones deben ejecutarse en el siguiente orden:

1. **001_crear_tabla_usuarios.sql** - Crear tabla de usuarios del sistema
2. **002_crear_tabla_terapeutas.sql** - Crear tabla de terapeutas certificados
3. **003_crear_tabla_citas.sql** - Crear tabla de citas y sistema de reservas
4. **004_crear_tabla_registros_auditoria.sql** - Crear tabla de registros de auditoría
5. **005_crear_tabla_notificaciones.sql** - Crear tabla de notificaciones
6. **006_configurar_politicas_rls.sql** - Configurar políticas de seguridad RLS
7. **007_configurar_triggers_auditoria.sql** - Configurar triggers de auditoría automática

## 💻 Ejecución con MCP de Supabase

Para ejecutar las migraciones usando las herramientas MCP de Supabase:

```bash
# Ejecutar cada migración individualmente
mcp_supabase_apply_migration --name "crear_tabla_usuarios" --query "$(cat 001_crear_tabla_usuarios.sql)"
mcp_supabase_apply_migration --name "crear_tabla_terapeutas" --query "$(cat 002_crear_tabla_terapeutas.sql)"
mcp_supabase_apply_migration --name "crear_tabla_citas" --query "$(cat 003_crear_tabla_citas.sql)"
mcp_supabase_apply_migration --name "crear_tabla_registros_auditoria" --query "$(cat 004_crear_tabla_registros_auditoria.sql)"
mcp_supabase_apply_migration --name "crear_tabla_notificaciones" --query "$(cat 005_crear_tabla_notificaciones.sql)"
mcp_supabase_apply_migration --name "configurar_politicas_rls" --query "$(cat 006_configurar_politicas_rls.sql)"
mcp_supabase_apply_migration --name "configurar_triggers_auditoria" --query "$(cat 007_configurar_triggers_auditoria.sql)"
```

## ✅ Verificación de Migraciones

Después de ejecutar todas las migraciones, verificar que todo esté correcto:

```bash
# Listar todas las tablas creadas
mcp_supabase_list_tables

# Listar todas las migraciones aplicadas
mcp_supabase_list_migrations

# Verificar que no hay problemas de seguridad
mcp_supabase_get_advisors --type "security"

# Verificar rendimiento
mcp_supabase_get_advisors --type "performance"
```

## 🔐 Políticas de Seguridad Implementadas

### Usuarios
- ✅ Los usuarios pueden ver y editar su propio perfil
- ✅ Los administradores pueden gestionar todos los usuarios
- ✅ Los recepcionistas pueden ver usuarios básicos para gestión de citas

### Terapeutas
- ✅ Los terapeutas pueden gestionar su propia información
- ✅ Los administradores pueden gestionar todos los terapeutas
- ✅ Los recepcionistas pueden ver terapeutas para gestión de citas

### Citas
- ✅ Los pacientes pueden ver y crear sus propias citas
- ✅ Los terapeutas pueden ver y actualizar el estado de sus citas
- ✅ Los administradores y recepcionistas pueden gestionar todas las citas

### Auditoría
- ✅ Solo los administradores pueden ver registros de auditoría
- ✅ Auditoría automática de todas las acciones críticas

### Notificaciones
- ✅ Los usuarios pueden ver y actualizar sus propias notificaciones
- ✅ Los administradores pueden gestionar todas las notificaciones

## 📊 Tablas Creadas

### `usuarios`
- **Propósito**: Almacenar información de todos los usuarios del sistema
- **Roles**: admin, terapeuta, recepcionista, paciente
- **Seguridad**: 2FA requerido para admin y terapeuta

### `terapeutas`
- **Propósito**: Información específica de terapeutas certificados
- **Incluye**: Licencias, especializaciones, horarios de trabajo
- **Relación**: Un terapeuta por usuario

### `citas`
- **Propósito**: Gestión de citas y reservas
- **Incluye**: Paciente, terapeuta, fecha, hora, estado, notas
- **Restricciones**: No se permiten citas duplicadas

### `registros_auditoria`
- **Propósito**: Auditoría completa de todas las acciones del sistema
- **Incluye**: Usuario, acción, tabla, valores anteriores/nuevos, IP
- **Retención**: 5 años

### `notificaciones`
- **Propósito**: Sistema de notificaciones del aplicativo
- **Incluye**: Recordatorios, confirmaciones, cancelaciones
- **Funcionalidad**: Programación automática de envío

## 🛠️ Funciones Utilitarias

### Auditoría
- `registrar_auditoria()` - Registro automático de cambios
- `obtener_resumen_auditoria_usuario(UUID)` - Resumen de actividad por usuario
- `obtener_actividad_reciente(INTEGER)` - Actividad reciente del sistema
- `limpiar_auditoria_antigua()` - Limpieza de registros antiguos

### Notificaciones
- `marcar_notificaciones_leidas(UUID)` - Marcar notificaciones como leídas
- `limpiar_notificaciones_antiguas()` - Limpieza de notificaciones antiguas

### Generales
- `actualizar_updated_at()` - Actualización automática de timestamps

## 🔄 Triggers Configurados

- **Auditoría automática**: Todas las tablas principales
- **Actualización de timestamps**: Todas las tablas con `updated_at`
- **Validación de datos**: Constraints y checks automáticos

## 📈 Índices para Rendimiento

- **Usuarios**: email, rol, estado activo
- **Terapeutas**: usuario_id, licencia, disponibilidad, especializaciones
- **Citas**: paciente_id, terapeuta_id, fecha, estado, fecha+hora
- **Auditoría**: usuario_id, tabla, acción, fecha
- **Notificaciones**: usuario_id, tipo, leída, programada_para

## 🚨 Notas Importantes

1. **Orden de ejecución**: Las migraciones deben ejecutarse en el orden especificado
2. **Dependencias**: Algunas migraciones dependen de funciones creadas en migraciones anteriores
3. **Seguridad**: RLS está habilitado en todas las tablas
4. **Auditoría**: Todas las acciones críticas se auditan automáticamente
5. **Rendimiento**: Se incluyen índices optimizados para consultas frecuentes

## 🔧 Solución de Problemas

Si una migración falla:

1. Verificar que las migraciones anteriores se ejecutaron correctamente
2. Revisar los logs de Supabase: `mcp_supabase_get_logs --service "postgres"`
3. Verificar permisos y credenciales
4. Contactar al equipo de desarrollo con los detalles del error

## 📞 Soporte

Para problemas con las migraciones, revisar:
- Los logs de Supabase
- La documentación de Supabase MCP
- Los advisors de seguridad y rendimiento 