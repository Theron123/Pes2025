part of 'notifications_bloc.dart';

/// Clase base para todos los estados de notificaciones
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial de las notificaciones
class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();

  @override
  List<Object?> get props => [];
}

/// Estado de carga de notificaciones
class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();

  @override
  List<Object?> get props => [];
}

/// Estado con notificaciones cargadas exitosamente
class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  final int conteoNoLeidas;
  final String filtrosActivos;

  const NotificationsLoaded({
    required this.notifications,
    required this.conteoNoLeidas,
    required this.filtrosActivos,
  });

  @override
  List<Object?> get props => [
        notifications,
        conteoNoLeidas,
        filtrosActivos,
      ];

  /// Crea una copia del estado con nuevos valores
  NotificationsLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? conteoNoLeidas,
    String? filtrosActivos,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      conteoNoLeidas: conteoNoLeidas ?? this.conteoNoLeidas,
      filtrosActivos: filtrosActivos ?? this.filtrosActivos,
    );
  }

  /// Obtiene las notificaciones no leídas
  List<NotificationEntity> get notificacionesNoLeidas {
    return notifications
        .where((n) => n.estado != EstadoNotificacion.leida)
        .toList();
  }

  /// Obtiene las notificaciones leídas
  List<NotificationEntity> get notificacionesLeidas {
    return notifications
        .where((n) => n.estado == EstadoNotificacion.leida)
        .toList();
  }

  /// Obtiene las notificaciones por tipo
  List<NotificationEntity> getNotificacionesPorTipo(TipoNotificacion tipo) {
    return notifications.where((n) => n.tipo == tipo).toList();
  }

  /// Obtiene las notificaciones por estado
  List<NotificationEntity> getNotificacionesPorEstado(EstadoNotificacion estado) {
    return notifications.where((n) => n.estado == estado).toList();
  }

  /// Obtiene las notificaciones por canal
  List<NotificationEntity> getNotificacionesPorCanal(CanalNotificacion canal) {
    return notifications.where((n) => n.canal == canal).toList();
  }

  /// Verifica si hay notificaciones no leídas
  bool get tieneNotificacionesNoLeidas => conteoNoLeidas > 0;

  /// Verifica si hay filtros activos
  bool get tieneFiltrosActivos => filtrosActivos != 'Sin filtros';

  /// Obtiene el total de notificaciones
  int get totalNotificaciones => notifications.length;
}

/// Estado de error en las notificaciones
class NotificationsError extends NotificationsState {
  final String message;
  final String? code;

  const NotificationsError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];

  /// Verifica si es un error de red
  bool get isNetworkError => code == 'NO_INTERNET';

  /// Verifica si es un error de servidor
  bool get isServerError => code?.contains('SERVER') ?? false;

  /// Verifica si es un error de validación
  bool get isValidationError => code?.contains('VALIDATION') ?? false;
}

/// Estado de creación de notificación
class NotificationsCreating extends NotificationsState {
  const NotificationsCreating();

  @override
  List<Object?> get props => [];
}

/// Estado de notificación creada exitosamente
class NotificationCreated extends NotificationsState {
  final NotificationEntity notification;

  const NotificationCreated({required this.notification});

  @override
  List<Object?> get props => [notification];
}

/// Estado de actualización de notificación
class NotificationsUpdating extends NotificationsState {
  const NotificationsUpdating();

  @override
  List<Object?> get props => [];
}

/// Estado de notificación actualizada exitosamente
class NotificationUpdated extends NotificationsState {
  final NotificationEntity notification;

  const NotificationUpdated({required this.notification});

  @override
  List<Object?> get props => [notification];
}

/// Estado de eliminación de notificación
class NotificationsDeleting extends NotificationsState {
  const NotificationsDeleting();

  @override
  List<Object?> get props => [];
}

/// Estado de notificación eliminada exitosamente
class NotificationDeleted extends NotificationsState {
  final String notificationId;

  const NotificationDeleted({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Estado de carga de estadísticas
class NotificationsStatsLoading extends NotificationsState {
  const NotificationsStatsLoading();

  @override
  List<Object?> get props => [];
}

/// Estado con estadísticas de notificaciones cargadas
class NotificationsStatsLoaded extends NotificationsState {
  final Map<String, dynamic> stats;

  const NotificationsStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];

  /// Obtiene el total de notificaciones
  int get total => stats['total'] ?? 0;

  /// Obtiene el número de notificaciones no leídas
  int get noLeidas => stats['noLeidas'] ?? 0;

  /// Obtiene el número de notificaciones enviadas
  int get enviadas => stats['enviadas'] ?? 0;

  /// Obtiene el número de notificaciones leídas
  int get leidas => stats['leidas'] ?? 0;

  /// Obtiene el número de notificaciones con error
  int get error => stats['error'] ?? 0;

  /// Obtiene el número de notificaciones canceladas
  int get canceladas => stats['canceladas'] ?? 0;

  /// Obtiene el porcentaje de notificaciones leídas
  double get porcentajeLeidas {
    if (total == 0) return 0.0;
    return (leidas / total) * 100;
  }

  /// Obtiene el porcentaje de notificaciones no leídas
  double get porcentajeNoLeidas {
    if (total == 0) return 0.0;
    return (noLeidas / total) * 100;
  }
}

/// Estado de marcado múltiple como leído
class NotificationsMarkingMultipleAsRead extends NotificationsState {
  final List<String> notificationIds;

  const NotificationsMarkingMultipleAsRead({required this.notificationIds});

  @override
  List<Object?> get props => [notificationIds];
}

/// Estado de múltiples notificaciones marcadas como leídas
class NotificationsMultipleMarkedAsRead extends NotificationsState {
  final List<String> notificationIds;

  const NotificationsMultipleMarkedAsRead({required this.notificationIds});

  @override
  List<Object?> get props => [notificationIds];
} 