import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user_entity.dart';
import '../../../../shared/domain/entities/user_entity.dart';

/// Repositorio abstracto para operaciones de autenticación
abstract class AuthRepository {
  /// Obtener el usuario autenticado actual
  Future<Result<UsuarioAutenticadoEntity?>> obtenerUsuarioActual();

  /// Iniciar sesión con credenciales
  Future<Result<UsuarioAutenticadoEntity>> iniciarSesion({
    required String email,
    required String password,
  });

  /// Registrar nuevo usuario
  Future<Result<UsuarioAutenticadoEntity>> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required RolUsuario rol,
    String? telefono,
    DateTime? fechaNacimiento,
  });

  /// Cerrar sesión
  Future<Result<void>> cerrarSesion();

  /// Enviar email de verificación
  Future<Result<void>> enviarEmailVerificacion();

  /// Verificar email con token
  Future<Result<void>> verificarEmail({
    required String token,
  });

  /// Enviar email de restablecimiento de contraseña
  Future<Result<void>> enviarEmailRestablecimiento({
    required String email,
  });

  /// Restablecer contraseña con token
  Future<Result<void>> restablecerPassword({
    required String token,
    required String nuevaPassword,
  });

  /// Cambiar contraseña (usuario autenticado)
  Future<Result<void>> cambiarPassword({
    required String passwordActual,
    required String nuevaPassword,
  });

  /// Configurar autenticación de dos factores
  Future<Result<Config2FAEntity>> configurar2FA();

  /// Verificar código de dos factores
  Future<Result<void>> verificar2FA({
    required String codigo,
  });

  /// Deshabilitar autenticación de dos factores
  Future<Result<void>> deshabilitar2FA({
    required String password,
  });

  /// Verificar código de recuperación de 2FA
  Future<Result<void>> verificarCodigoRecuperacion({
    required String codigo,
  });

  /// Generar nuevos códigos de recuperación
  Future<Result<List<String>>> generarCodigosRecuperacion();

  /// Refrescar token de acceso
  Future<Result<UsuarioAutenticadoEntity>> refrescarToken();

  /// Verificar si el usuario está autenticado
  Future<Result<bool>> estaAutenticado();

  /// Obtener el perfil del usuario autenticado
  Future<Result<UsuarioEntity>> obtenerPerfil();

  /// Actualizar perfil del usuario
  Future<Result<UsuarioEntity>> actualizarPerfil({
    required String nombre,
    required String apellido,
    String? telefono,
    DateTime? fechaNacimiento,
    String? direccion,
    String? nombreContactoEmergencia,
    String? telefonoContactoEmergencia,
  });

  /// Eliminar cuenta del usuario
  Future<Result<void>> eliminarCuenta({
    required String password,
  });

  /// Stream de cambios de estado de autenticación
  Stream<UsuarioAutenticadoEntity?> get streamEstadoAuth;

  /// Verificar si la sesión es válida
  Future<Result<bool>> verificarSesionValida();

  /// Obtener metadatos de la sesión
  Future<Result<Map<String, dynamic>>> obtenerMetadatosSesion();
} 