import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/email_service.dart';
import '../../../../shared/domain/entities/user_entity.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementación del repositorio de autenticación
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Result<UsuarioAutenticadoEntity?>> obtenerUsuarioActual() async {
    try {
      final usuario = await remoteDataSource.getCurrentUser();
      return Result.success(usuario?.toEntity());
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<UsuarioAutenticadoEntity>> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      final usuario = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.success(usuario.toEntity());
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<UsuarioAutenticadoEntity>> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required RolUsuario rol,
    String? telefono,
    DateTime? fechaNacimiento,
  }) async {
    try {
      final usuario = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        firstName: nombre,
        lastName: apellido,
        role: rol.name, // Convertir enum a string
        phone: telefono,
      );

      // Enviar correo de bienvenida automáticamente usando el servicio independiente
      await EmailService.enviarCorreoBienvenida(
        destinatario: email,
        nombre: nombre,
        apellido: apellido,
        rol: rol.name,
      );

      return Result.success(usuario.toEntity());
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> cerrarSesion() async {
    try {
      await remoteDataSource.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> enviarEmailVerificacion() async {
    try {
      // Email verification no longer needed - users are auto-verified
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> verificarEmail({required String token}) async {
    try {
      // Email verification no longer needed - users are auto-verified
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> enviarEmailRestablecimiento({required String email}) async {
    try {
      await remoteDataSource.enviarEmailRestablecimiento(email: email);
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> restablecerPassword({
    required String token,
    required String nuevaPassword,
  }) async {
    try {
      await remoteDataSource.restablecerPassword(
        token: token,
        nuevaPassword: nuevaPassword,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> cambiarPassword({
    required String passwordActual,
    required String nuevaPassword,
  }) async {
    try {
      await remoteDataSource.cambiarPassword(
        passwordActual: passwordActual,
        nuevaPassword: nuevaPassword,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<Config2FAEntity>> configurar2FA() async {
    try {
      // 2FA no implementado aún, retornar error temporal
      throw UnimplementedError('2FA no implementado aún');
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> verificar2FA({required String codigo}) async {
    try {
      // 2FA no implementado aún, retornar error temporal
      throw UnimplementedError('2FA no implementado aún');
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> deshabilitar2FA({required String password}) async {
    try {
      // 2FA no implementado aún, retornar error temporal
      throw UnimplementedError('2FA no implementado aún');
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> verificarCodigoRecuperacion({required String codigo}) async {
    try {
      // 2FA no implementado aún, retornar error temporal
      throw UnimplementedError('2FA no implementado aún');
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<List<String>>> generarCodigosRecuperacion() async {
    try {
      // 2FA no implementado aún, retornar error temporal
      throw UnimplementedError('2FA no implementado aún');
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<UsuarioAutenticadoEntity>> refrescarToken() async {
    try {
      // Token refresh is handled automatically by Supabase
      final usuario = await remoteDataSource.getCurrentUser();
      if (usuario == null) {
        throw Exception('Usuario no autenticado');
      }
      return Result.success(usuario.toEntity());
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<bool>> estaAutenticado() async {
    try {
      final usuario = await remoteDataSource.getCurrentUser();
      return Result.success(usuario != null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<UsuarioEntity>> obtenerPerfil() async {
    try {
      final usuario = await remoteDataSource.getCurrentUser();
      if (usuario == null) {
        throw Exception('Usuario no autenticado');
      }
      
      // Si el usuario tiene perfil, devolverlo
      if (usuario.perfil != null) {
        return Result.success(usuario.perfil!);
      }
      
      // Si no tiene perfil, crear uno básico con la información disponible
      final perfilBasico = UsuarioEntity(
        id: usuario.id,
        email: usuario.email,
        rol: RolUsuario.paciente, // Rol por defecto
        nombre: 'Usuario',
        apellido: 'Sin Nombre',
        telefono: null,
        fechaNacimiento: null,
        direccion: null,
        nombreContactoEmergencia: null,
        telefonoContactoEmergencia: null,
        activo: true,
        emailVerificado: usuario.emailVerificado,
        requiere2FA: false,
        creadoEn: usuario.creadoEn,
        actualizadoEn: usuario.actualizadoEn,
        ultimoLogin: null,
      );
      
      return Result.success(perfilBasico);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<UsuarioEntity>> actualizarPerfil({
    required String nombre,
    required String apellido,
    String? telefono,
    DateTime? fechaNacimiento,
    String? direccion,
    String? nombreContactoEmergencia,
    String? telefonoContactoEmergencia,
  }) async {
    try {
      // Profile update not implemented in simplified datasource
      throw UnimplementedError('Actualización de perfil no implementada aún');
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> eliminarCuenta({required String password}) async {
    try {
      // Account deletion not implemented in simplified datasource
      throw UnimplementedError('Eliminación de cuenta no implementada aún');
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Stream<UsuarioAutenticadoEntity?> get streamEstadoAuth {
    // Auth state stream not implemented in simplified datasource
    // Return empty stream for now
    return Stream.value(null);
  }

  @override
  Future<Result<bool>> verificarSesionValida() async {
    try {
      // Session validation simplified - just check if user exists
      final usuario = await remoteDataSource.getCurrentUser();
      return Result.success(usuario != null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> obtenerMetadatosSesion() async {
    try {
      final usuario = await remoteDataSource.getCurrentUser();
      if (usuario == null) {
        return Result.failure(const AuthenticationFailure(
          message: 'Usuario no autenticado',
        ));
      }

      final metadatos = {
        'user_id': usuario.id,
        'email': usuario.email,
        'email_verificado': usuario.emailVerificado,
        'token_expira_en': usuario.expiraEn?.toIso8601String(),
        'creado_en': usuario.creadoEn.toIso8601String(),
        'actualizado_en': usuario.actualizadoEn.toIso8601String(),
        'metadatos_adicionales': usuario.metadatos,
      };

      return Result.success(metadatos);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }



  /// Mapear excepción a failure
  Failure _mapExceptionToFailure(dynamic exception) {
    final message = exception.toString();
    
    if (message.contains('Authentication') || message.contains('auth')) {
      return AuthenticationFailure(message: message);
    }
    
    if (message.contains('Network') || message.contains('network')) {
      return NetworkFailure(message: message);
    }
    
    if (message.contains('Server') || message.contains('server')) {
      return ServerFailure(message: message);
    }
    
    if (message.contains('Validation') || message.contains('validation')) {
      return ValidationFailure(message: message);
    }
    
    if (message.contains('2FA') || message.contains('two-factor')) {
      return TwoFactorAuthFailure(message: message);
    }
    
    if (message.contains('Session') || message.contains('session')) {
      return SessionTimeoutFailure(message: message);
    }
    
    if (message.contains('Permission') || message.contains('permission')) {
      return PermissionFailure(message: message);
    }

    return UnexpectedFailure(message: message);
  }
} 