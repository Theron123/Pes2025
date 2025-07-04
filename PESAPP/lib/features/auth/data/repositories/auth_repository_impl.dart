import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
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
      final usuario = await remoteDataSource.obtenerUsuarioActual();
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
      final usuario = await remoteDataSource.iniciarSesion(
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
      final usuario = await remoteDataSource.registrarUsuario(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        rol: rol,
        telefono: telefono,
        fechaNacimiento: fechaNacimiento,
      );
      return Result.success(usuario.toEntity());
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> cerrarSesion() async {
    try {
      await remoteDataSource.cerrarSesion();
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> enviarEmailVerificacion() async {
    try {
      await remoteDataSource.enviarEmailVerificacion();
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> verificarEmail({required String token}) async {
    try {
      await remoteDataSource.verificarEmail(token: token);
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
      final config = await remoteDataSource.configurar2FA();
      return Result.success(config.toEntity());
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> verificar2FA({required String codigo}) async {
    try {
      await remoteDataSource.verificar2FA(codigo: codigo);
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> deshabilitar2FA({required String password}) async {
    try {
      await remoteDataSource.deshabilitar2FA(password: password);
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> verificarCodigoRecuperacion({required String codigo}) async {
    try {
      await remoteDataSource.verificarCodigoRecuperacion(codigo: codigo);
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<List<String>>> generarCodigosRecuperacion() async {
    try {
      final codigos = await remoteDataSource.generarCodigosRecuperacion();
      return Result.success(codigos);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<UsuarioAutenticadoEntity>> refrescarToken() async {
    try {
      final usuario = await remoteDataSource.refrescarToken();
      return Result.success(usuario.toEntity());
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<bool>> estaAutenticado() async {
    try {
      final usuario = await remoteDataSource.obtenerUsuarioActual();
      return Result.success(usuario?.estaAutenticado ?? false);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<UsuarioEntity>> obtenerPerfil() async {
    try {
      final perfil = await remoteDataSource.obtenerPerfil();
      return Result.success(perfil.toEntity());
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
      final perfil = await remoteDataSource.actualizarPerfil(
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        fechaNacimiento: fechaNacimiento,
        direccion: direccion,
        nombreContactoEmergencia: nombreContactoEmergencia,
        telefonoContactoEmergencia: telefonoContactoEmergencia,
      );
      return Result.success(perfil.toEntity());
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> eliminarCuenta({required String password}) async {
    try {
      await remoteDataSource.eliminarCuenta(password: password);
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Stream<UsuarioAutenticadoEntity?> get streamEstadoAuth {
    return remoteDataSource.streamEstadoAuth.map(
      (usuario) => usuario?.toEntity(),
    );
  }

  @override
  Future<Result<bool>> verificarSesionValida() async {
    try {
      final usuario = await remoteDataSource.obtenerUsuarioActual();
      if (usuario == null) {
        return Result.success(false);
      }
      
      final esValida = usuario.estaAutenticado && !usuario.tokenExpirado;
      return Result.success(esValida);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> obtenerMetadatosSesion() async {
    try {
      final usuario = await remoteDataSource.obtenerUsuarioActual();
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