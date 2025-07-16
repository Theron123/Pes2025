import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

/// Filtros para búsqueda de notificaciones
class NotificationFilters {
  /// Filtrar por estado de notificación
  final List<EstadoNotificacion>? estados;
  
  /// Filtrar por tipo de notificación
  final List<TipoNotificacion>? tipos;
  
  /// Filtrar por canal de notificación
  final List<CanalNotificacion>? canales;
  
  /// Filtrar por rango de fechas de creación
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  
  /// Filtrar por prioridad (1 = alta, 2 = media, 3 = baja)
  final List<int>? prioridades;
  
  /// Filtrar por notificaciones no leídas
  final bool? soloNoLeidas;
  
  /// Filtrar por notificaciones que requieren acción
  final bool? soloConAccion;
  
  /// Filtrar por notificaciones asociadas a citas
  final String? citaId;
  
  /// Filtrar por notificaciones asociadas a terapeuta
  final String? terapeutaId;
  
  /// Filtrar por notificaciones asociadas a reporte
  final String? reporteId;
  
  /// Texto libre para búsqueda en título o mensaje
  final String? textoBusqueda;

  const NotificationFilters({
    this.estados,
    this.tipos,
    this.canales,
    this.fechaDesde,
    this.fechaHasta,
    this.prioridades,
    this.soloNoLeidas,
    this.soloConAccion,
    this.citaId,
    this.terapeutaId,
    this.reporteId,
    this.textoBusqueda,
  });
}

/// Parámetros para ordenamiento de notificaciones
enum NotificationSortBy {
  fechaCreacion,
  fechaProgramada,
  fechaEnvio,
  fechaLectura,
  prioridad,
  estado,
  tipo,
}

/// Dirección de ordenamiento
enum SortDirection {
  asc,
  desc,
}

/// Parámetros de paginación para notificaciones
class NotificationPagination {
  /// Número de página (comienza en 1)
  final int page;
  
  /// Cantidad de elementos por página
  final int limit;
  
  /// Campo por el cual ordenar
  final NotificationSortBy sortBy;
  
  /// Dirección de ordenamiento
  final SortDirection sortDirection;

  const NotificationPagination({
    this.page = 1,
    this.limit = 20,
    this.sortBy = NotificationSortBy.fechaCreacion,
    this.sortDirection = SortDirection.desc,
  });
}

/// Resultado paginado de notificaciones
class NotificationPaginatedResult {
  /// Lista de notificaciones
  final List<NotificationEntity> notifications;
  
  /// Número total de elementos
  final int totalCount;
  
  /// Número de página actual
  final int currentPage;
  
  /// Cantidad de elementos por página
  final int limit;
  
  /// Total de páginas disponibles
  final int totalPages;
  
  /// Si hay página anterior
  final bool hasPreviousPage;
  
  /// Si hay página siguiente
  final bool hasNextPage;

  const NotificationPaginatedResult({
    required this.notifications,
    required this.totalCount,
    required this.currentPage,
    required this.limit,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });
}

/// Estadísticas de notificaciones
class NotificationStats {
  /// Total de notificaciones
  final int total;
  
  /// Notificaciones no leídas
  final int noLeidas;
  
  /// Notificaciones enviadas
  final int enviadas;
  
  /// Notificaciones con error
  final int conError;
  
  /// Notificaciones pendientes
  final int pendientes;
  
  /// Notificaciones de alta prioridad
  final int altaPrioridad;
  
  /// Notificaciones que requieren acción
  final int requierenAccion;
  
  /// Distribución por tipo
  final Map<TipoNotificacion, int> distribucionalPorTipo;
  
  /// Distribución por canal
  final Map<CanalNotificacion, int> distribucionalPorCanal;

  const NotificationStats({
    required this.total,
    required this.noLeidas,
    required this.enviadas,
    required this.conError,
    required this.pendientes,
    required this.altaPrioridad,
    required this.requierenAccion,
    required this.distribucionalPorTipo,
    required this.distribucionalPorCanal,
  });
}

/// Repositorio abstracto para el manejo de notificaciones
/// 
/// Define todas las operaciones necesarias para el sistema de notificaciones
/// del hospital, incluyendo CRUD, filtros, paginación, estadísticas y operaciones
/// específicas del dominio hospitalario.
abstract class NotificationsRepository {
  // ==================== OPERACIONES CRUD ====================

  /// Crea una nueva notificación
  /// 
  /// [notification] - La notificación a crear
  /// 
  /// Returns: [Right] con la notificación creada o [Left] con el error
  Future<Either<Failure, NotificationEntity>> crearNotificacion(
    NotificationEntity notification,
  );

  /// Obtiene una notificación por ID
  /// 
  /// [id] - ID único de la notificación
  /// 
  /// Returns: [Right] con la notificación o [Left] con el error
  Future<Either<Failure, NotificationEntity>> obtenerNotificacionPorId(
    String id,
  );

  /// Obtiene todas las notificaciones de un usuario con filtros y paginación
  /// 
  /// [usuarioId] - ID del usuario
  /// [filters] - Filtros de búsqueda opcionales
  /// [pagination] - Parámetros de paginación
  /// 
  /// Returns: [Right] con resultado paginado o [Left] con el error
  Future<Either<Failure, NotificationPaginatedResult>> obtenerNotificacionesUsuario(
    String usuarioId, {
    NotificationFilters? filters,
    NotificationPagination? pagination,
  });

  /// Obtiene todas las notificaciones con filtros y paginación (admin)
  /// 
  /// [filters] - Filtros de búsqueda opcionales
  /// [pagination] - Parámetros de paginación
  /// 
  /// Returns: [Right] con resultado paginado o [Left] con el error
  Future<Either<Failure, NotificationPaginatedResult>> obtenerTodasLasNotificaciones({
    NotificationFilters? filters,
    NotificationPagination? pagination,
  });

  /// Actualiza una notificación existente
  /// 
  /// [notification] - La notificación con los cambios
  /// 
  /// Returns: [Right] con la notificación actualizada o [Left] con el error
  Future<Either<Failure, NotificationEntity>> actualizarNotificacion(
    NotificationEntity notification,
  );

  /// Elimina una notificación (soft delete)
  /// 
  /// [id] - ID de la notificación a eliminar
  /// 
  /// Returns: [Right] con true si se eliminó o [Left] con el error
  Future<Either<Failure, bool>> eliminarNotificacion(String id);

  // ==================== OPERACIONES ESPECÍFICAS ====================

  /// Marca una notificación como leída
  /// 
  /// [id] - ID de la notificación
  /// 
  /// Returns: [Right] con la notificación actualizada o [Left] con el error
  Future<Either<Failure, NotificationEntity>> marcarComoLeida(String id);

  /// Marca múltiples notificaciones como leídas
  /// 
  /// [ids] - Lista de IDs de notificaciones
  /// 
  /// Returns: [Right] con la lista de notificaciones actualizadas o [Left] con el error
  Future<Either<Failure, List<NotificationEntity>>> marcarVariasComoLeidas(
    List<String> ids,
  );

  /// Marca todas las notificaciones de un usuario como leídas
  /// 
  /// [usuarioId] - ID del usuario
  /// 
  /// Returns: [Right] con el número de notificaciones actualizadas o [Left] con el error
  Future<Either<Failure, int>> marcarTodasComoLeidas(String usuarioId);

  /// Marca una notificación como enviada
  /// 
  /// [id] - ID de la notificación
  /// 
  /// Returns: [Right] con la notificación actualizada o [Left] con el error
  Future<Either<Failure, NotificationEntity>> marcarComoEnviada(String id);

  /// Marca una notificación con error
  /// 
  /// [id] - ID de la notificación
  /// [error] - Mensaje de error
  /// 
  /// Returns: [Right] con la notificación actualizada o [Left] con el error
  Future<Either<Failure, NotificationEntity>> marcarConError(
    String id,
    String error,
  );

  /// Cancela una notificación
  /// 
  /// [id] - ID de la notificación
  /// 
  /// Returns: [Right] con la notificación actualizada o [Left] con el error
  Future<Either<Failure, NotificationEntity>> cancelarNotificacion(String id);

  // ==================== OPERACIONES DE BÚSQUEDA ====================

  /// Busca notificaciones por texto en título o mensaje
  /// 
  /// [usuarioId] - ID del usuario (opcional para admin)
  /// [textoBusqueda] - Texto a buscar
  /// [pagination] - Parámetros de paginación
  /// 
  /// Returns: [Right] con resultado paginado o [Left] con el error
  Future<Either<Failure, NotificationPaginatedResult>> buscarNotificaciones(
    String textoBusqueda, {
    String? usuarioId,
    NotificationPagination? pagination,
  });

  /// Obtiene notificaciones pendientes de envío
  /// 
  /// [limite] - Límite de notificaciones a obtener
  /// 
  /// Returns: [Right] con lista de notificaciones o [Left] con el error
  Future<Either<Failure, List<NotificationEntity>>> obtenerNotificacionesPendientes({
    int limite = 100,
  });

  /// Obtiene notificaciones que requieren acción
  /// 
  /// [usuarioId] - ID del usuario
  /// [pagination] - Parámetros de paginación
  /// 
  /// Returns: [Right] con resultado paginado o [Left] con el error
  Future<Either<Failure, NotificationPaginatedResult>> obtenerNotificacionesConAccion(
    String usuarioId, {
    NotificationPagination? pagination,
  });

  /// Obtiene notificaciones asociadas a una cita
  /// 
  /// [citaId] - ID de la cita
  /// 
  /// Returns: [Right] con lista de notificaciones o [Left] con el error
  Future<Either<Failure, List<NotificationEntity>>> obtenerNotificacionesPorCita(
    String citaId,
  );

  /// Obtiene notificaciones asociadas a un terapeuta
  /// 
  /// [terapeutaId] - ID del terapeuta
  /// [pagination] - Parámetros de paginación
  /// 
  /// Returns: [Right] con resultado paginado o [Left] con el error
  Future<Either<Failure, NotificationPaginatedResult>> obtenerNotificacionesPorTerapeuta(
    String terapeutaId, {
    NotificationPagination? pagination,
  });

  // ==================== ESTADÍSTICAS ====================

  /// Obtiene estadísticas de notificaciones de un usuario
  /// 
  /// [usuarioId] - ID del usuario
  /// [fechaDesde] - Fecha de inicio (opcional)
  /// [fechaHasta] - Fecha de fin (opcional)
  /// 
  /// Returns: [Right] con estadísticas o [Left] con el error
  Future<Either<Failure, NotificationStats>> obtenerEstadisticasUsuario(
    String usuarioId, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });

  /// Obtiene estadísticas generales del sistema (admin)
  /// 
  /// [fechaDesde] - Fecha de inicio (opcional)
  /// [fechaHasta] - Fecha de fin (opcional)
  /// 
  /// Returns: [Right] con estadísticas o [Left] con el error
  Future<Either<Failure, NotificationStats>> obtenerEstadisticasGenerales({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });

  // ==================== OPERACIONES EN LOTE ====================

  /// Crea múltiples notificaciones en lote
  /// 
  /// [notifications] - Lista de notificaciones a crear
  /// 
  /// Returns: [Right] con lista de notificaciones creadas o [Left] con el error
  Future<Either<Failure, List<NotificationEntity>>> crearNotificacionesLote(
    List<NotificationEntity> notifications,
  );

  /// Elimina notificaciones expiradas
  /// 
  /// [fechaLimite] - Fecha límite para eliminar notificaciones
  /// 
  /// Returns: [Right] con número de notificaciones eliminadas o [Left] con el error
  Future<Either<Failure, int>> eliminarNotificacionesExpiradas({
    DateTime? fechaLimite,
  });

  /// Cancela notificaciones asociadas a una cita
  /// 
  /// [citaId] - ID de la cita
  /// 
  /// Returns: [Right] con número de notificaciones canceladas o [Left] con el error
  Future<Either<Failure, int>> cancelarNotificacionesPorCita(String citaId);

  // ==================== STREAMS EN TIEMPO REAL ====================

  /// Stream de notificaciones de un usuario en tiempo real
  /// 
  /// [usuarioId] - ID del usuario
  /// 
  /// Returns: Stream con lista de notificaciones actualizadas
  Stream<List<NotificationEntity>> obtenerNotificacionesUsuarioStream(
    String usuarioId,
  );

  /// Stream del contador de notificaciones no leídas
  /// 
  /// [usuarioId] - ID del usuario
  /// 
  /// Returns: Stream con el número de notificaciones no leídas
  Stream<int> obtenerContadorNoLeidasStream(String usuarioId);

  /// Stream de notificaciones de alta prioridad
  /// 
  /// [usuarioId] - ID del usuario
  /// 
  /// Returns: Stream con lista de notificaciones de alta prioridad
  Stream<List<NotificationEntity>> obtenerNotificacionesAltaPrioridadStream(
    String usuarioId,
  );

  // ==================== OPERACIONES DE PROGRAMACIÓN ====================

  /// Programa una notificación para envío futuro
  /// 
  /// [notification] - La notificación a programar
  /// [fechaProgramada] - Fecha y hora programada para envío
  /// 
  /// Returns: [Right] con la notificación programada o [Left] con el error
  Future<Either<Failure, NotificationEntity>> programarNotificacion(
    NotificationEntity notification,
    DateTime fechaProgramada,
  );

  /// Obtiene notificaciones programadas para un período específico
  /// 
  /// [fechaDesde] - Fecha de inicio
  /// [fechaHasta] - Fecha de fin
  /// 
  /// Returns: [Right] con lista de notificaciones programadas o [Left] con el error
  Future<Either<Failure, List<NotificationEntity>>> obtenerNotificacionesProgramadas(
    DateTime fechaDesde,
    DateTime fechaHasta,
  );

  /// Reagenda una notificación programada
  /// 
  /// [id] - ID de la notificación
  /// [nuevaFecha] - Nueva fecha programada
  /// 
  /// Returns: [Right] con la notificación actualizada o [Left] con el error
  Future<Either<Failure, NotificationEntity>> reagendarNotificacion(
    String id,
    DateTime nuevaFecha,
  );
} 