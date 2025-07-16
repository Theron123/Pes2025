part of 'notifications_bloc.dart';

/// Clase base para todos los eventos de notificaciones
abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar notificaciones del usuario
class LoadNotifications extends NotificationsEvent {
  final String usuarioId;
  final List<TipoNotificacion>? tipos;
  final List<EstadoNotificacion>? estados;
  final DateTime? desde;
  final DateTime? hasta;
  final String? busqueda;

  const LoadNotifications({
    required this.usuarioId,
    this.tipos,
    this.estados,
    this.desde,
    this.hasta,
    this.busqueda,
  });

  @override
  List<Object?> get props => [
        usuarioId,
        tipos,
        estados,
        desde,
        hasta,
        busqueda,
      ];
}

/// Evento para crear una nueva notificación
class CreateNotification extends NotificationsEvent {
  final String usuarioId;
  final TipoNotificacion tipo;
  final String titulo;
  final String mensaje;
  final CanalNotificacion canal;
  final String? citaId;
  final String? terapeutaId;
  final String? reporteId;
  final Map<String, dynamic>? datosAdicionales;
  final DateTime? fechaProgramada;
  final bool requiereAccion;
  final String? accion;
  final bool cancelable;
  final DateTime? fechaExpiracion;

  const CreateNotification({
    required this.usuarioId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.canal,
    this.citaId,
    this.terapeutaId,
    this.reporteId,
    this.datosAdicionales,
    this.fechaProgramada,
    this.requiereAccion = false,
    this.accion,
    this.cancelable = true,
    this.fechaExpiracion,
  });

  @override
  List<Object?> get props => [
        usuarioId,
        tipo,
        titulo,
        mensaje,
        canal,
        citaId,
        terapeutaId,
        reporteId,
        datosAdicionales,
        fechaProgramada,
        requiereAccion,
        accion,
        cancelable,
        fechaExpiracion,
      ];
}

/// Evento para marcar una notificación como leída
class MarkAsRead extends NotificationsEvent {
  final String notificacionId;

  const MarkAsRead({required this.notificacionId});

  @override
  List<Object?> get props => [notificacionId];
}

/// Evento para filtrar notificaciones
class FilterNotifications extends NotificationsEvent {
  final String usuarioId;
  final List<TipoNotificacion>? tipos;
  final List<EstadoNotificacion>? estados;
  final DateTime? desde;
  final DateTime? hasta;
  final String? busqueda;

  const FilterNotifications({
    required this.usuarioId,
    this.tipos,
    this.estados,
    this.desde,
    this.hasta,
    this.busqueda,
  });

  @override
  List<Object?> get props => [
        usuarioId,
        tipos,
        estados,
        desde,
        hasta,
        busqueda,
      ];
}

/// Evento para refrescar notificaciones
class RefreshNotifications extends NotificationsEvent {
  final String usuarioId;

  const RefreshNotifications({required this.usuarioId});

  @override
  List<Object?> get props => [usuarioId];
}

/// Evento para limpiar notificaciones
class ClearNotifications extends NotificationsEvent {
  const ClearNotifications();

  @override
  List<Object?> get props => [];
}

/// Evento para marcar múltiples notificaciones como leídas
class MarkMultipleAsRead extends NotificationsEvent {
  final List<String> notificacionIds;

  const MarkMultipleAsRead({required this.notificacionIds});

  @override
  List<Object?> get props => [notificacionIds];
}

/// Evento para eliminar una notificación
class DeleteNotification extends NotificationsEvent {
  final String notificacionId;

  const DeleteNotification({required this.notificacionId});

  @override
  List<Object?> get props => [notificacionId];
}

/// Evento para actualizar una notificación
class UpdateNotification extends NotificationsEvent {
  final NotificationEntity notificacion;

  const UpdateNotification({required this.notificacion});

  @override
  List<Object?> get props => [notificacion];
} 