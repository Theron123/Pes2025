import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../shared/domain/entities/user_entity.dart';
import '../../../../shared/data/models/user_model.dart';
import '../models/auth_user_model.dart';

/// Fuente de datos remota para autenticación
abstract class AuthRemoteDataSource {
  /// Obtener usuario autenticado actual
  Future<UsuarioAutenticadoModel?> obtenerUsuarioActual();

  /// Iniciar sesión con email y contraseña
  Future<UsuarioAutenticadoModel> iniciarSesion({
    required String email,
    required String password,
  });

  /// Registrar nuevo usuario
  Future<UsuarioAutenticadoModel> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required RolUsuario rol,
    String? telefono,
    DateTime? fechaNacimiento,
  });

  /// Cerrar sesión
  Future<void> cerrarSesion();

  /// Enviar email de verificación
  Future<void> enviarEmailVerificacion();

  /// Verificar email
  Future<void> verificarEmail({required String token});

  /// Enviar email de restablecimiento
  Future<void> enviarEmailRestablecimiento({required String email});

  /// Restablecer contraseña
  Future<void> restablecerPassword({
    required String token,
    required String nuevaPassword,
  });

  /// Cambiar contraseña
  Future<void> cambiarPassword({
    required String passwordActual,
    required String nuevaPassword,
  });

  /// Configurar 2FA
  Future<Config2FAModel> configurar2FA();

  /// Verificar 2FA
  Future<void> verificar2FA({required String codigo});

  /// Deshabilitar 2FA
  Future<void> deshabilitar2FA({required String password});

  /// Verificar código de recuperación
  Future<void> verificarCodigoRecuperacion({required String codigo});

  /// Generar nuevos códigos de recuperación
  Future<List<String>> generarCodigosRecuperacion();

  /// Refrescar token
  Future<UsuarioAutenticadoModel> refrescarToken();

  /// Obtener perfil del usuario
  Future<UsuarioModel> obtenerPerfil();

  /// Actualizar perfil del usuario
  Future<UsuarioModel> actualizarPerfil({
    required String nombre,
    required String apellido,
    String? telefono,
    DateTime? fechaNacimiento,
    String? direccion,
    String? nombreContactoEmergencia,
    String? telefonoContactoEmergencia,
  });

  /// Eliminar cuenta
  Future<void> eliminarCuenta({required String password});

  /// Stream de cambios de estado de autenticación
  Stream<UsuarioAutenticadoModel?> get streamEstadoAuth;
}

/// Implementación de la fuente de datos remota
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSourceImpl({SupabaseClient? client}) 
      : _client = client ?? SupabaseConfig.client;

  @override
  Future<UsuarioAutenticadoModel?> obtenerUsuarioActual() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Obtener perfil del usuario desde la base de datos
      final perfilResponse = await _client.users
          .select()
          .eq('id', user.id)
          .maybeSingle();

      UsuarioModel? perfil;
      if (perfilResponse != null) {
        perfil = UsuarioModel.fromJson(perfilResponse);
      }

      return UsuarioAutenticadoModel.fromSupabaseUserWithProfile(
        user.toJson(),
        _client.auth.currentSession?.accessToken,
        _client.auth.currentSession?.refreshToken,
        perfil?.toEntity(),
      );
    } catch (e) {
      throw ServerException(message: 'Error al obtener usuario actual: $e');
    }
  }

  @override
  Future<UsuarioAutenticadoModel> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthenticationException(
          message: 'Credenciales inválidas',
        );
      }

      // Obtener perfil del usuario
      final perfilResponse = await _client.users
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      UsuarioModel? perfil;
      if (perfilResponse != null) {
        perfil = UsuarioModel.fromJson(perfilResponse);
      }

      return UsuarioAutenticadoModel.fromSupabaseUserWithProfile(
        response.user!.toJson(),
        response.session?.accessToken,
        response.session?.refreshToken,
        perfil?.toEntity(),
      );
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UsuarioAutenticadoModel> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required RolUsuario rol,
    String? telefono,
    DateTime? fechaNacimiento,
  }) async {
    try {
      // Registrar usuario en auth
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'rol': rol.name,
        },
      );

      if (response.user == null) {
        throw AuthenticationException(
          message: 'Error al registrar usuario',
        );
      }

      // Crear perfil en la base de datos
      final perfilData = {
        'id': response.user!.id,
        'email': email,
        'nombre': nombre,
        'apellido': apellido,
        'rol': rol.name,
        'telefono': telefono,
        'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
        'activo': true,
        'requiere_2fa': rol == RolUsuario.admin || rol == RolUsuario.terapeuta,
        'email_verificado': false,
        'creado_en': DateTime.now().toIso8601String(),
        'actualizado_en': DateTime.now().toIso8601String(),
      };

      final perfilResponse = await _client.users
          .insert(perfilData)
          .select()
          .single();

      final perfil = UsuarioModel.fromJson(perfilResponse);

      return UsuarioAutenticadoModel.fromSupabaseUserWithProfile(
        response.user!.toJson(),
        response.session?.accessToken,
        response.session?.refreshToken,
        perfil.toEntity(),
      );
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al registrar usuario: $e');
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw ServerException(message: 'Error al cerrar sesión: $e');
    }
  }

  @override
  Future<void> enviarEmailVerificacion() async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: _client.auth.currentUser?.email,
      );
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al enviar email de verificación: $e');
    }
  }

  @override
  Future<void> verificarEmail({required String token}) async {
    try {
      await _client.auth.verifyOTP(
        token: token,
        type: OtpType.signup,
      );
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al verificar email: $e');
    }
  }

  @override
  Future<void> enviarEmailRestablecimiento({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al enviar email de restablecimiento: $e');
    }
  }

  @override
  Future<void> restablecerPassword({
    required String token,
    required String nuevaPassword,
  }) async {
    try {
      await _client.auth.verifyOTP(
        token: token,
        type: OtpType.recovery,
      );
      
      await _client.auth.updateUser(
        UserAttributes(password: nuevaPassword),
      );
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al restablecer contraseña: $e');
    }
  }

  @override
  Future<void> cambiarPassword({
    required String passwordActual,
    required String nuevaPassword,
  }) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: nuevaPassword),
      );
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al cambiar contraseña: $e');
    }
  }

  @override
  Future<Config2FAModel> configurar2FA() async {
    try {
      // Supabase no tiene 2FA integrado, necesitaremos implementarlo
      // usando una solución personalizada o un proveedor externo
      throw UnimplementedError('2FA no implementado aún');
    } catch (e) {
      throw ServerException(message: 'Error al configurar 2FA: $e');
    }
  }

  @override
  Future<void> verificar2FA({required String codigo}) async {
    try {
      // Implementar verificación de 2FA
      throw UnimplementedError('2FA no implementado aún');
    } catch (e) {
      throw ServerException(message: 'Error al verificar 2FA: $e');
    }
  }

  @override
  Future<void> deshabilitar2FA({required String password}) async {
    try {
      // Implementar deshabilitación de 2FA
      throw UnimplementedError('2FA no implementado aún');
    } catch (e) {
      throw ServerException(message: 'Error al deshabilitar 2FA: $e');
    }
  }

  @override
  Future<void> verificarCodigoRecuperacion({required String codigo}) async {
    try {
      // Implementar verificación de código de recuperación
      throw UnimplementedError('2FA no implementado aún');
    } catch (e) {
      throw ServerException(message: 'Error al verificar código de recuperación: $e');
    }
  }

  @override
  Future<List<String>> generarCodigosRecuperacion() async {
    try {
      // Implementar generación de códigos de recuperación
      throw UnimplementedError('2FA no implementado aún');
    } catch (e) {
      throw ServerException(message: 'Error al generar códigos de recuperación: $e');
    }
  }

  @override
  Future<UsuarioAutenticadoModel> refrescarToken() async {
    try {
      final response = await _client.auth.refreshSession();
      
      if (response.user == null) {
        throw AuthenticationException(
          message: 'Error al refrescar token',
        );
      }

      // Obtener perfil del usuario
      final perfilResponse = await _client.users
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      UsuarioModel? perfil;
      if (perfilResponse != null) {
        perfil = UsuarioModel.fromJson(perfilResponse);
      }

      return UsuarioAutenticadoModel.fromSupabaseUserWithProfile(
        response.user!.toJson(),
        response.session?.accessToken,
        response.session?.refreshToken,
        perfil?.toEntity(),
      );
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al refrescar token: $e');
    }
  }

  @override
  Future<UsuarioModel> obtenerPerfil() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AuthenticationException(
          message: 'Usuario no autenticado',
        );
      }

      final response = await _client.users
          .select()
          .eq('id', userId)
          .single();

      return UsuarioModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Error al obtener perfil: $e');
    }
  }

  @override
  Future<UsuarioModel> actualizarPerfil({
    required String nombre,
    required String apellido,
    String? telefono,
    DateTime? fechaNacimiento,
    String? direccion,
    String? nombreContactoEmergencia,
    String? telefonoContactoEmergencia,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AuthenticationException(
          message: 'Usuario no autenticado',
        );
      }

      final updateData = {
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
        'direccion': direccion,
        'nombre_contacto_emergencia': nombreContactoEmergencia,
        'telefono_contacto_emergencia': telefonoContactoEmergencia,
        'actualizado_en': DateTime.now().toIso8601String(),
      };

      final response = await _client.users
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UsuarioModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar perfil: $e');
    }
  }

  @override
  Future<void> eliminarCuenta({required String password}) async {
    try {
      // Eliminar usuario de auth
      await _client.auth.admin.deleteUser(_client.auth.currentUser!.id);
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al eliminar cuenta: $e');
    }
  }

  @override
  Stream<UsuarioAutenticadoModel?> get streamEstadoAuth {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;

      try {
        // Obtener perfil del usuario
        final perfilResponse = await _client.users
            .select()
            .eq('id', user.id)
            .maybeSingle();

        UsuarioModel? perfil;
        if (perfilResponse != null) {
          perfil = UsuarioModel.fromJson(perfilResponse);
        }

        return UsuarioAutenticadoModel.fromSupabaseUserWithProfile(
          user.toJson(),
          event.session?.accessToken,
          event.session?.refreshToken,
          perfil?.toEntity(),
        );
      } catch (e) {
        return null;
      }
    });
  }
} 