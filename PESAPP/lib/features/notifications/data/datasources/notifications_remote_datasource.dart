import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

/// Fuente de datos remota para notificaciones
/// 
/// Maneja todas las operaciones CRUD con Supabase para notificaciones
abstract class NotificationsRemoteDataSource {
  /// Crear una nueva notificación
  Future<NotificationModel> crearNotificacion(NotificationModel notificacion);
  
  /// Obtener notificaciones por usuario
  Future<List<NotificationModel>> obtenerNotificacionesUsuario(String usuarioId);
  
  /// Obtener notificación por ID
  Future<NotificationModel?> obtenerNotificacionPorId(String id);
  
  /// Marcar notificación como leída
  Future<void> marcarComoLeida(String id);
  
  /// Actualizar notificación
  Future<NotificationModel> actualizarNotificacion(NotificationModel notificacion);
  
  /// Eliminar notificación
  Future<void> eliminarNotificacion(String id);
  
  /// Obtener conteo de notificaciones no leídas
  Future<int> obtenerConteoNoLeidas(String usuarioId);
}

/// Implementación del data source remoto usando Supabase
class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final SupabaseClient _supabase;
  
  static const String _tableName = 'notificaciones';
  
  NotificationsRemoteDataSourceImpl(this._supabase);

  @override
  Future<NotificationModel> crearNotificacion(NotificationModel notificacion) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(notificacion.toJson())
          .select()
          .single();
      
      return NotificationModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Error al crear notificación: ${e.message}',
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado al crear notificación: $e',
        code: null,
      );
    }
  }

  @override
  Future<List<NotificationModel>> obtenerNotificacionesUsuario(String usuarioId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('usuario_id', usuarioId)
          .order('fecha_creacion', ascending: false);
      
      return response
          .map<NotificationModel>((json) => NotificationModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Error al obtener notificaciones: ${e.message}',
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado al obtener notificaciones: $e',
        code: null,
      );
    }
  }

  @override
  Future<NotificationModel?> obtenerNotificacionPorId(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) {
        return null;
      }
      
      return NotificationModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Error al obtener notificación: ${e.message}',
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado al obtener notificación: $e',
        code: null,
      );
    }
  }

  @override
  Future<void> marcarComoLeida(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .update({
            'estado': 'leida',
            'fecha_lectura': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Error al marcar notificación como leída: ${e.message}',
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado al marcar notificación como leída: $e',
        code: null,
      );
    }
  }

  @override
  Future<NotificationModel> actualizarNotificacion(NotificationModel notificacion) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update(notificacion.toJson())
          .eq('id', notificacion.id)
          .select()
          .single();
      
      return NotificationModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Error al actualizar notificación: ${e.message}',
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado al actualizar notificación: $e',
        code: null,
      );
    }
  }

  @override
  Future<void> eliminarNotificacion(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Error al eliminar notificación: ${e.message}',
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado al eliminar notificación: $e',
        code: null,
      );
    }
  }

  @override
  Future<int> obtenerConteoNoLeidas(String usuarioId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('usuario_id', usuarioId)
          .neq('estado', 'leida');
      
      return response.length;
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Error al obtener conteo de no leídas: ${e.message}',
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado al obtener conteo de no leídas: $e',
        code: null,
      );
    }
  }
} 