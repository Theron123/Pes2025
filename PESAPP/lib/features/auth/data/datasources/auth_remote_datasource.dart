import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../models/auth_user_model.dart';

/// Fuente de datos remota para autenticación - SIMPLIFICADA
class AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSource({SupabaseClient? client}) 
      : _client = client ?? SupabaseConfig.client;

  /// Iniciar sesión con email y contraseña
  Future<UsuarioAutenticadoModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const ServerException(message: 'Credenciales inválidas');
      }

      // Obtener datos del perfil del usuario - CORREGIDO: usar nombres de columnas en inglés
      final perfilResponse = await _client
          .from('users')
          .select('*')
          .eq('id', response.user!.id)
          .maybeSingle(); // Cambiar a maybeSingle para evitar error si no existe

      return UsuarioAutenticadoModel.fromJson({
        'auth_user': response.user!.toJson(),
        'profile': perfilResponse, // Puede ser null si no existe perfil
      });
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw const ServerException(message: 'Email o contraseña incorrectos');
      }
      throw ServerException(message: 'Error al iniciar sesión: ${e.message}');
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al obtener perfil: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  /// Registrar nuevo usuario - SIMPLIFICADO SIN VERIFICACIÓN DE EMAIL
  Future<UsuarioAutenticadoModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required String role,
  }) async {
    try {
      // Registrar usuario en Supabase Auth
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const ServerException(message: 'Error al crear usuario');
      }

      // Crear perfil del usuario en la tabla users - CORREGIDO: usar nombres en español
      await _client.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'nombre': firstName,
        'apellido': lastName,
        'telefono': phone,
        'rol': role,
        'activo': true,
        'email_verificado': false,
        'requiere_2fa': false,
        'creado_en': DateTime.now().toIso8601String(),
        'actualizado_en': DateTime.now().toIso8601String(),
      });

      // Obtener el perfil recién creado
      final perfilResponse = await _client
          .from('users')
          .select('*')
          .eq('id', response.user!.id)
          .single();

      return UsuarioAutenticadoModel.fromJson({
        'auth_user': response.user!.toJson(),
        'profile': perfilResponse,
      });
    } on AuthException catch (e) {
      if (e.message.contains('User already registered')) {
        throw const ServerException(message: 'Este email ya está registrado');
      }
      throw ServerException(message: 'Error al registrar usuario: ${e.message}');
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al crear perfil: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(message: 'Error al cerrar sesión: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  /// Obtener usuario actual
  Future<UsuarioAutenticadoModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // CORREGIDO: usar maybeSingle para evitar error si no existe perfil
      final perfilResponse = await _client
          .from('users')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      return UsuarioAutenticadoModel.fromJson({
        'auth_user': user.toJson(),
        'profile': perfilResponse, // Puede ser null si no existe perfil
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al obtener usuario: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  /// Configurar 2FA
  Future<void> configurar2FA({required String token}) async {
    try {
      // Implementar lógica de 2FA aquí
      throw const ServerException(message: 'Funcionalidad de 2FA no implementada aún');
    } catch (e) {
      throw ServerException(message: 'Error al configurar 2FA: $e');
    }
  }

  /// Verificar 2FA
  Future<bool> verificar2FA({required String token}) async {
    try {
      // Implementar lógica de verificación 2FA aquí
      throw const ServerException(message: 'Funcionalidad de verificación 2FA no implementada aún');
    } catch (e) {
      throw ServerException(message: 'Error al verificar 2FA: $e');
    }
  }

  /// Deshabilitar 2FA
  Future<void> deshabilitar2FA() async {
    try {
      // Implementar lógica para deshabilitar 2FA aquí
      throw const ServerException(message: 'Funcionalidad de deshabilitación 2FA no implementada aún');
    } catch (e) {
      throw ServerException(message: 'Error al deshabilitar 2FA: $e');
    }
  }

  /// Enviar email de restablecimiento de contraseña
  Future<void> enviarEmailRestablecimiento({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw ServerException(message: 'Error al enviar email de restablecimiento: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  /// Restablecer contraseña
  Future<void> restablecerPassword({
    required String token,
    required String nuevaPassword,
  }) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: nuevaPassword),
      );
    } on AuthException catch (e) {
      throw ServerException(message: 'Error al restablecer contraseña: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  /// Cambiar contraseña
  Future<void> cambiarPassword({
    required String passwordActual,
    required String nuevaPassword,
  }) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: nuevaPassword),
      );
    } on AuthException catch (e) {
      throw ServerException(message: 'Error al cambiar contraseña: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }
} 