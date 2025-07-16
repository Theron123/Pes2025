import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';
import '../models/notification_model.dart';

/// Implementación concreta del repositorio de notificaciones
/// 
/// Maneja la lógica de acceso a datos y conversión entre entidades y modelos
class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  NotificationsRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, NotificationEntity>> crearNotificacion(
    NotificationEntity notificacion,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = NotificationModel.fromEntity(notificacion);
        final result = await _remoteDataSource.crearNotificacion(model);
        return Right(result.toEntity());
      } catch (e) {
        return Left(
          ServerFailure(
            message: 'Error al crear notificación: ${e.toString()}',
            code: 5001,
          ),
        );
      }
    } else {
      return Left(
        NetworkFailure(
          message: 'No hay conexión a internet',
          code: 1001,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationPaginatedResult>> obtenerNotificacionesUsuario(
    String usuarioId, {
    NotificationFilters? filters,
    NotificationPagination? pagination,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.obtenerNotificacionesUsuario(usuarioId);
        final entities = result.map((model) => model.toEntity()).toList();
        
        // Crear resultado paginado básico
        final paginatedResult = NotificationPaginatedResult(
          notifications: entities,
          totalCount: entities.length,
          currentPage: pagination?.page ?? 1,
          limit: pagination?.limit ?? 20,
          totalPages: (entities.length / (pagination?.limit ?? 20)).ceil(),
          hasPreviousPage: (pagination?.page ?? 1) > 1,
          hasNextPage: entities.length > (pagination?.limit ?? 20),
        );
        
        return Right(paginatedResult);
      } catch (e) {
        return Left(
          ServerFailure(
            message: 'Error al obtener notificaciones: ${e.toString()}',
            code: 5002,
          ),
        );
      }
    } else {
      return Left(
        NetworkFailure(
          message: 'No hay conexión a internet',
          code: 1001,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> obtenerNotificacionPorId(
    String id,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.obtenerNotificacionPorId(id);
        if (result == null) {
          return Left(
            ServerFailure(
              message: 'Notificación no encontrada',
              code: 5003,
            ),
          );
        }
        return Right(result.toEntity());
      } catch (e) {
        return Left(
          ServerFailure(
            message: 'Error al obtener notificación: ${e.toString()}',
            code: 5004,
          ),
        );
      }
    } else {
      return Left(
        NetworkFailure(
          message: 'No hay conexión a internet',
          code: 1001,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> marcarComoLeida(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.marcarComoLeida(id);
        // Obtener la notificación actualizada
        final result = await _remoteDataSource.obtenerNotificacionPorId(id);
        if (result == null) {
          return Left(
            ServerFailure(
              message: 'Notificación no encontrada',
              code: 5003,
            ),
          );
        }
        return Right(result.toEntity());
      } catch (e) {
        return Left(
          ServerFailure(
            message: 'Error al marcar notificación como leída: ${e.toString()}',
            code: 5005,
          ),
        );
      }
    } else {
      return Left(
        NetworkFailure(
          message: 'No hay conexión a internet',
          code: 1001,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> actualizarNotificacion(
    NotificationEntity notificacion,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = NotificationModel.fromEntity(notificacion);
        final result = await _remoteDataSource.actualizarNotificacion(model);
        return Right(result.toEntity());
      } catch (e) {
        return Left(
          ServerFailure(
            message: 'Error al actualizar notificación: ${e.toString()}',
            code: 5006,
          ),
        );
      }
    } else {
      return Left(
        NetworkFailure(
          message: 'No hay conexión a internet',
          code: 1001,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> eliminarNotificacion(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.eliminarNotificacion(id);
        return const Right(true);
      } catch (e) {
        return Left(
          ServerFailure(
            message: 'Error al eliminar notificación: ${e.toString()}',
            code: 5007,
          ),
        );
      }
    } else {
      return Left(
        NetworkFailure(
          message: 'No hay conexión a internet',
          code: 1001,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> obtenerConteoNoLeidas(String usuarioId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.obtenerConteoNoLeidas(usuarioId);
        return Right(result);
      } catch (e) {
        return Left(
          ServerFailure(
            message: 'Error al obtener conteo de no leídas: ${e.toString()}',
            code: 5008,
          ),
        );
      }
    } else {
      return Left(
        NetworkFailure(
          message: 'No hay conexión a internet',
          code: 1001,
        ),
      );
    }
  }

  // ==================== MÉTODOS ADICIONALES REQUERIDOS ====================

  @override
  Future<Either<Failure, NotificationPaginatedResult>> obtenerTodasLasNotificaciones({
    NotificationFilters? filters,
    NotificationPagination? pagination,
  }) async {
    // Implementación básica - retorna resultado vacío
    return const Right(NotificationPaginatedResult(
      notifications: [],
      totalCount: 0,
      currentPage: 1,
      limit: 20,
      totalPages: 0,
      hasPreviousPage: false,
      hasNextPage: false,
    ));
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> marcarVariasComoLeidas(
    List<String> ids,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final List<NotificationEntity> updatedNotifications = [];
        for (final id in ids) {
          await _remoteDataSource.marcarComoLeida(id);
          final result = await _remoteDataSource.obtenerNotificacionPorId(id);
          if (result != null) {
            updatedNotifications.add(result.toEntity());
          }
        }
        return Right(updatedNotifications);
      } catch (e) {
        return Left(
          ServerFailure(
            message: 'Error al marcar notificaciones como leídas: ${e.toString()}',
            code: 5009,
          ),
        );
      }
    } else {
      return Left(
        NetworkFailure(
          message: 'No hay conexión a internet',
          code: 1001,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> marcarTodasComoLeidas(String usuarioId) async {
    // Implementación básica
    return const Right(0);
  }

  @override
  Future<Either<Failure, NotificationEntity>> marcarComoEnviada(String id) async {
    // Implementación básica - retorna la notificación sin cambios
    return obtenerNotificacionPorId(id);
  }

  @override
  Future<Either<Failure, NotificationEntity>> marcarConError(
    String id,
    String error,
  ) async {
    // Implementación básica - retorna la notificación sin cambios
    return obtenerNotificacionPorId(id);
  }

  @override
  Future<Either<Failure, NotificationEntity>> cancelarNotificacion(String id) async {
    // Implementación básica - retorna la notificación sin cambios
    return obtenerNotificacionPorId(id);
  }

  @override
  Future<Either<Failure, NotificationPaginatedResult>> buscarNotificaciones(
    String textoBusqueda, {
    String? usuarioId,
    NotificationPagination? pagination,
  }) async {
    // Implementación básica - retorna resultado vacío
    return const Right(NotificationPaginatedResult(
      notifications: [],
      totalCount: 0,
      currentPage: 1,
      limit: 20,
      totalPages: 0,
      hasPreviousPage: false,
      hasNextPage: false,
    ));
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> obtenerNotificacionesPendientes({
    int limite = 100,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, NotificationPaginatedResult>> obtenerNotificacionesConAccion(
    String usuarioId, {
    NotificationPagination? pagination,
  }) async {
    return const Right(NotificationPaginatedResult(
      notifications: [],
      totalCount: 0,
      currentPage: 1,
      limit: 20,
      totalPages: 0,
      hasPreviousPage: false,
      hasNextPage: false,
    ));
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> obtenerNotificacionesPorCita(
    String citaId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, NotificationPaginatedResult>> obtenerNotificacionesPorTerapeuta(
    String terapeutaId, {
    NotificationPagination? pagination,
  }) async {
    return const Right(NotificationPaginatedResult(
      notifications: [],
      totalCount: 0,
      currentPage: 1,
      limit: 20,
      totalPages: 0,
      hasPreviousPage: false,
      hasNextPage: false,
    ));
  }

  @override
  Future<Either<Failure, NotificationStats>> obtenerEstadisticasUsuario(
    String usuarioId, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final notificaciones = await _remoteDataSource.obtenerNotificacionesUsuario(usuarioId);
        
        // Calcular estadísticas
        final total = notificaciones.length;
        final noLeidas = notificaciones.where((n) => n.estado != EstadoNotificacion.leida).length;
        final enviadas = notificaciones.where((n) => n.estado == EstadoNotificacion.enviada).length;
        final conError = notificaciones.where((n) => n.estado == EstadoNotificacion.error).length;
        final pendientes = notificaciones.where((n) => n.estado == EstadoNotificacion.pendiente).length;
        
        final stats = NotificationStats(
          total: total,
          noLeidas: noLeidas,
          enviadas: enviadas,
          conError: conError,
          pendientes: pendientes,
          altaPrioridad: 0,
          requierenAccion: 0,
          distribucionalPorTipo: {},
          distribucionalPorCanal: {},
        );
        
        return Right(stats);
      } catch (e) {
        return Left(
          ServerFailure(
            message: 'Error al obtener estadísticas: ${e.toString()}',
            code: 5010,
          ),
        );
      }
    } else {
      return Left(
        NetworkFailure(
          message: 'No hay conexión a internet',
          code: 1001,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationStats>> obtenerEstadisticasGenerales({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    return const Right(NotificationStats(
      total: 0,
      noLeidas: 0,
      enviadas: 0,
      conError: 0,
      pendientes: 0,
      altaPrioridad: 0,
      requierenAccion: 0,
      distribucionalPorTipo: {},
      distribucionalPorCanal: {},
    ));
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> crearNotificacionesLote(
    List<NotificationEntity> notifications,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, int>> eliminarNotificacionesExpiradas({
    DateTime? fechaLimite,
  }) async {
    return const Right(0);
  }

  @override
  Future<Either<Failure, int>> cancelarNotificacionesPorCita(String citaId) async {
    return const Right(0);
  }

  @override
  Stream<List<NotificationEntity>> obtenerNotificacionesUsuarioStream(
    String usuarioId,
  ) {
    return Stream.value([]);
  }

  @override
  Stream<int> obtenerContadorNoLeidasStream(String usuarioId) {
    return Stream.value(0);
  }

  @override
  Stream<List<NotificationEntity>> obtenerNotificacionesAltaPrioridadStream(
    String usuarioId,
  ) {
    return Stream.value([]);
  }

  @override
  Future<Either<Failure, NotificationEntity>> programarNotificacion(
    NotificationEntity notification,
    DateTime fechaProgramada,
  ) async {
    return Left(
      ServerFailure(
        message: 'Programación no implementada',
        code: 5011,
      ),
    );
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> obtenerNotificacionesProgramadas(
    DateTime fechaDesde,
    DateTime fechaHasta,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, NotificationEntity>> reagendarNotificacion(
    String id,
    DateTime nuevaFecha,
  ) async {
    return Left(
      ServerFailure(
        message: 'Reagendar no implementado',
        code: 5012,
      ),
    );
  }
} 