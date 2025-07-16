import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/usecases/crear_notificacion_usecase.dart';
import '../../domain/usecases/obtener_notificaciones_usuario_usecase.dart';
import '../../domain/usecases/marcar_como_leida_usecase.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

/// BLoC para gestionar el estado de las notificaciones
/// 
/// Maneja todas las operaciones relacionadas con notificaciones
/// incluyendo creación, obtención, marcado como leída y filtros
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final CrearNotificacionUseCase _crearNotificacionUseCase;
  final ObtenerNotificacionesUsuarioUseCase _obtenerNotificacionesUsuarioUseCase;
  final MarcarComoLeidaUseCase _marcarComoLeidaUseCase;

  NotificationsBloc({
    required CrearNotificacionUseCase crearNotificacionUseCase,
    required ObtenerNotificacionesUsuarioUseCase obtenerNotificacionesUsuarioUseCase,
    required MarcarComoLeidaUseCase marcarComoLeidaUseCase,
  })  : _crearNotificacionUseCase = crearNotificacionUseCase,
        _obtenerNotificacionesUsuarioUseCase = obtenerNotificacionesUsuarioUseCase,
        _marcarComoLeidaUseCase = marcarComoLeidaUseCase,
        super(NotificationsInitial()) {
    on<NotificationsEvent>((event, emit) async {
      switch (event.runtimeType) {
        case LoadNotifications:
          await _onLoadNotifications(event as LoadNotifications, emit);
          break;
        case CreateNotification:
          await _onCreateNotification(event as CreateNotification, emit);
          break;
        case MarkAsRead:
          await _onMarkAsRead(event as MarkAsRead, emit);
          break;
        case FilterNotifications:
          await _onFilterNotifications(event as FilterNotifications, emit);
          break;
        case RefreshNotifications:
          await _onRefreshNotifications(event as RefreshNotifications, emit);
          break;
        case ClearNotifications:
          await _onClearNotifications(event as ClearNotifications, emit);
          break;
        default:
          break;
      }
    });
  }

  /// Cargar notificaciones del usuario
  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    
    try {
      final result = await _obtenerNotificacionesUsuarioUseCase(
        ObtenerNotificacionesUsuarioParams(
          usuarioId: event.usuarioId,
          filters: NotificationFilters(
            tipos: event.tipos,
            estados: event.estados,
            fechaDesde: event.desde,
            fechaHasta: event.hasta,
            textoBusqueda: event.busqueda,
          ),
        ),
      );
      
      if (result.isSuccess) {
        final paginatedResult = result.value!;
        final notificacionesNoLeidas = paginatedResult.notifications
            .where((n) => n.estado != EstadoNotificacion.leida)
            .length;
        
        emit(NotificationsLoaded(
          notifications: paginatedResult.notifications,
          conteoNoLeidas: notificacionesNoLeidas,
          filtrosActivos: _buildFilterSummary(event),
        ));
      } else {
        emit(NotificationsError(result.error?.message ?? 'Error desconocido'));
      }
    } catch (e) {
      emit(NotificationsError('Error inesperado: ${e.toString()}'));
    }
  }

  /// Crear nueva notificación
  Future<void> _onCreateNotification(
    CreateNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is NotificationsLoaded) {
      emit(NotificationsCreating());
      
      try {
        final result = await _crearNotificacionUseCase(
          CrearNotificacionParams(
            usuarioId: event.usuarioId,
            tipo: event.tipo,
            titulo: event.titulo,
            mensaje: event.mensaje,
            canal: event.canal,
            citaId: event.citaId,
            terapeutaId: event.terapeutaId,
            reporteId: event.reporteId,
            datosAdicionales: event.datosAdicionales,
            fechaProgramada: event.fechaProgramada,
            requiereAccion: event.requiereAccion,
            accion: event.accion,
            cancelable: event.cancelable,
            fechaExpiracion: event.fechaExpiracion,
          ),
        );
        
        if (result.isSuccess) {
          // Recargar las notificaciones después de crear una nueva
          add(LoadNotifications(usuarioId: event.usuarioId));
        } else {
          emit(NotificationsError(result.error?.message ?? 'Error al crear notificación'));
        }
      } catch (e) {
        emit(NotificationsError('Error al crear notificación: ${e.toString()}'));
      }
    }
  }

  /// Marcar notificación como leída
  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      
      try {
        final result = await _marcarComoLeidaUseCase(
          MarcarComoLeidaParams(notificationId: event.notificacionId),
        );
        
        if (result.isSuccess) {
          // Actualizar la notificación en el estado actual
          final updatedNotifications = currentState.notifications.map((n) {
            if (n.id == event.notificacionId) {
              return n.copyWith(
                estado: EstadoNotificacion.leida,
                fechaLectura: DateTime.now(),
              );
            }
            return n;
          }).toList();
          
          final notificacionesNoLeidas = updatedNotifications
              .where((n) => n.estado != EstadoNotificacion.leida)
              .length;
          
          emit(NotificationsLoaded(
            notifications: updatedNotifications,
            conteoNoLeidas: notificacionesNoLeidas,
            filtrosActivos: currentState.filtrosActivos,
          ));
        } else {
          emit(NotificationsError(result.error?.message ?? 'Error al marcar como leída'));
        }
      } catch (e) {
        emit(NotificationsError('Error al marcar como leída: ${e.toString()}'));
      }
    }
  }

  /// Filtrar notificaciones
  Future<void> _onFilterNotifications(
    FilterNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    // Recargar con los nuevos filtros
    add(LoadNotifications(
      usuarioId: event.usuarioId,
      tipos: event.tipos,
      estados: event.estados,
      desde: event.desde,
      hasta: event.hasta,
      busqueda: event.busqueda,
    ));
  }

  /// Refrescar notificaciones
  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      
      // Mantener los filtros actuales al refrescar
      add(LoadNotifications(
        usuarioId: event.usuarioId,
        tipos: _extractTiposFromFilters(currentState.filtrosActivos),
        estados: _extractEstadosFromFilters(currentState.filtrosActivos),
        desde: _extractDesdeFromFilters(currentState.filtrosActivos),
        hasta: _extractHastaFromFilters(currentState.filtrosActivos),
        busqueda: _extractBusquedaFromFilters(currentState.filtrosActivos),
      ));
    } else {
      add(LoadNotifications(usuarioId: event.usuarioId));
    }
  }

  /// Limpiar notificaciones
  Future<void> _onClearNotifications(
    ClearNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsInitial());
  }

  // ==================== MÉTODOS AUXILIARES ====================

  /// Construir resumen de filtros activos
  String _buildFilterSummary(LoadNotifications event) {
    final filtros = <String>[];
    
    if (event.tipos != null && event.tipos!.isNotEmpty) {
      filtros.add('${event.tipos!.length} tipo(s)');
    }
    
    if (event.estados != null && event.estados!.isNotEmpty) {
      filtros.add('${event.estados!.length} estado(s)');
    }
    
    if (event.desde != null) {
      filtros.add('desde ${event.desde!.day}/${event.desde!.month}');
    }
    
    if (event.hasta != null) {
      filtros.add('hasta ${event.hasta!.day}/${event.hasta!.month}');
    }
    
    if (event.busqueda != null && event.busqueda!.isNotEmpty) {
      filtros.add('búsqueda: "${event.busqueda}"');
    }
    
    return filtros.isEmpty ? 'Sin filtros' : filtros.join(', ');
  }

  /// Extraer tipos de los filtros activos
  List<TipoNotificacion>? _extractTiposFromFilters(String filtros) {
    // Por simplicidad, retornamos null
    // En una implementación completa, parseariamos el string
    return null;
  }

  /// Extraer estados de los filtros activos
  List<EstadoNotificacion>? _extractEstadosFromFilters(String filtros) {
    // Por simplicidad, retornamos null
    // En una implementación completa, parseariamos el string
    return null;
  }

  /// Extraer fecha desde de los filtros activos
  DateTime? _extractDesdeFromFilters(String filtros) {
    // Por simplicidad, retornamos null
    // En una implementación completa, parseariamos el string
    return null;
  }

  /// Extraer fecha hasta de los filtros activos
  DateTime? _extractHastaFromFilters(String filtros) {
    // Por simplicidad, retornamos null
    // En una implementación completa, parseariamos el string
    return null;
  }

  /// Extraer búsqueda de los filtros activos
  String? _extractBusquedaFromFilters(String filtros) {
    // Por simplicidad, retornamos null
    // En una implementación completa, parseariamos el string
    return null;
  }
} 