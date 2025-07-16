# 🔐 Credenciales de Prueba - Sistema Hospital

## 📋 **USUARIOS DE PRUEBA**

### **Credenciales para Testing**

| Rol | Email | Contraseña | UUID |
|-----|-------|------------|------|
| **Admin** | admin@hospital.com | `Hospital123!` | 11111111-1111-1111-1111-111111111111 |
| **Terapeuta** | terapeuta1@hospital.com | `Masaje123!` | 22222222-2222-2222-2222-222222222222 |
| **Recepcionista** | recepcion@hospital.com | `Recepcion123!` | 33333333-3333-3333-3333-333333333333 |
| **Paciente** | paciente1@hospital.com | `Paciente123!` | 44444444-4444-4444-4444-444444444444 |

## 🛠️ **INSTRUCCIONES PARA CREAR USUARIOS EN SUPABASE**

### **Paso 1: Ejecutar Migración**
```bash
cd supabase
supabase migration up
```

### **Paso 2: Crear Usuarios en Supabase Auth Dashboard**

1. **Ir a Supabase Dashboard**
   - Abrir: https://app.supabase.com
   - Seleccionar tu proyecto
   - Ir a `Authentication` → `Users`

2. **Crear Usuario Admin**
   - Clic en `Add user` → `Create a new user`
   - Email: `admin@hospital.com`
   - Contraseña: `Hospital123!`
   - ✅ **IMPORTANTE**: Marcar `Auto Confirm User`
   - Clic en `Create user`

3. **Repetir para Todos los Usuarios**
   - Crear cada usuario de la tabla de arriba
   - **SIEMPRE marcar `Auto Confirm User`**

### **Paso 3: Verificar Usuarios**
```sql
-- Verificar usuarios en la tabla users
SELECT id, email, rol, nombre, apellido, email_verificado, activo 
FROM users 
ORDER BY created_at DESC;
```

## 🔧 **SOLUCIÓN SIMPLIFICADA**

### **Problemas Resueltos**
- ✅ **Eliminada toda la complejidad del rate limiting**
- ✅ **Sistema de autenticación simplificado**
- ✅ **Sin verificación de email obligatoria**
- ✅ **Usuarios marcados como verificados automáticamente**
- ✅ **URL de Supabase corregida**

### **Código Simplificado**
- **Registro**: Sin confirmación de email
- **Login**: Verificación directa con credenciales
- **Errores**: Mensajes claros y específicos

## 🚀 **TESTING**

### **Probar Login**
1. Abrir la app
2. Usar cualquier credencial de la tabla
3. Ejemplo: `admin@hospital.com` / `Hospital123!`

### **Probar Registro**
1. Ir a registro
2. Completar formulario
3. El usuario se creará automáticamente sin verificación de email

## 📝 **NOTAS IMPORTANTES**

- **Contraseñas**: Todas cumplen los requisitos de seguridad
- **UUIDs**: Fijos para facilitar testing
- **Email Verificado**: Marcado como `true` automáticamente
- **2FA**: Configurado según el rol (admin/terapeuta = true)

## 🔍 **VERIFICACIÓN**

Si tienes problemas:

1. **Verificar URL de Supabase**: `https://kvckbufndsznlcbkknv.supabase.co`
2. **Verificar usuarios en Auth**: Dashboard → Authentication → Users
3. **Verificar usuarios en tabla**: SQL Editor → `SELECT * FROM users;`

## ⚡ **ESTADO ACTUAL**

### ✅ **FUNCIONANDO CORRECTAMENTE**
- **URL de Supabase**: `https://kvcbafrudpznlkcbkbnv.supabase.co` ✅
- **API Key**: Actualizada y funcional ✅
- **Usuario Admin**: `admin@hospital.com` / `Hospital123!` ✅
- **Autenticación**: Probada via API REST ✅

### 🚀 **PRÓXIMOS PASOS**

1. **Probar login en la app Flutter** con `admin@hospital.com` / `Hospital123!`
2. **Crear usuarios adicionales** si es necesario
3. **Continuar desarrollo** sin problemas de autenticación

---

**¡El sistema de autenticación está completamente funcional!** 