import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

/// Parámetros para obtener notificaciones de un usuario
class ObtenerNotificacionesUsuarioParams extends Equatable {
  /// ID del usuario
  final String usuarioId;
  
  /// Filtros de búsqueda opcionales
  final NotificationFilters? filters;
  
  /// Parámetros de paginación
  final NotificationPagination? pagination;

  const ObtenerNotificacionesUsuarioParams({
    required this.usuarioId,
    this.filters,
    this.pagination,
  });

  @override
  List<Object?> get props => [usuarioId, filters, pagination];
}

/// Use case para obtener las notificaciones de un usuario específico
/// 
/// Permite obtener notificaciones con filtros avanzados y paginación.
/// Incluye validaciones de entrada y manejo de errores específicos.
/// 
/// **Funcionalidades:**
/// - Filtrado por estado, tipo, canal, fechas, prioridad
/// - Paginación con ordenamiento configurable
/// - Validación de permisos de usuario
/// - Estadísticas incluidas en el resultado
/// 
/// **Casos de uso:**
/// ```dart
/// // Obtener notificaciones no leídas
/// final result = await obtenerNotificacionesUsuarioUseCase(
///   ObtenerNotificacionesUsuarioParams(
///     usuarioId: '123',
///     filters: NotificationFilters(soloNoLeidas: true),
///     pagination: NotificationPagination(page: 1, limit: 10),
///   ),
/// );
/// 
/// // Obtener notificaciones de alta prioridad
/// final result = await obtenerNotificacionesUsuarioUseCase(
///   ObtenerNotificacionesUsuarioParams(
///     usuarioId: '123',
///     filters: NotificationFilters(prioridades: [1]),
///   ),
/// );
/// ```
class ObtenerNotificacionesUsuarioUseCase 
    implements UseCase<NotificationPaginatedResult, ObtenerNotificacionesUsuarioParams> {
  final NotificationsRepository repository;

  ObtenerNotificacionesUsuarioUseCase(this.repository);

  @override
  Future<Result<NotificationPaginatedResult>> call(
    ObtenerNotificacionesUsuarioParams params,
  ) async {
    try {
      // Validar parámetros de entrada
      final validationResult = _validateParams(params);
      if (validationResult != null) {
        return Result.failure(validationResult);
      }

      // Obtener notificaciones del repositorio
      final result = await repository.obtenerNotificacionesUsuario(
        params.usuarioId,
        filters: params.filters,
        pagination: params.pagination,
      );

      return result.fold(
        (failure) => Result.failure(failure),
        (paginatedResult) => Result.success(paginatedResult),
      );

    } catch (e) {
      return Result.failure(
        DatabaseFailure(
          message: 'Error inesperado al obtener notificaciones: ${e.toString()}',
          code: 4101,
        ),
      );
    }
  }

  /// Valida los parámetros de entrada
  ValidationFailure? _validateParams(ObtenerNotificacionesUsuarioParams params) {
    // Validar usuario ID
    if (params.usuarioId.isEmpty) {
      return const ValidationFailure(
        message: 'El ID del usuario es requerido',
        code: 4102,
      );
    }

    if (params.usuarioId.length < 3) {
      return const ValidationFailure(
        message: 'El ID del usuario debe tener al menos 3 caracteres',
        code: 4103,
      );
    }

    // Validar filtros si se proporcionan
    if (params.filters != null) {
      final filtersValidation = _validateFilters(params.filters!);
      if (filtersValidation != null) {
        return filtersValidation;
      }
    }

    // Validar paginación si se proporciona
    if (params.pagination != null) {
      final paginationValidation = _validatePagination(params.pagination!);
      if (paginationValidation != null) {
        return paginationValidation;
      }
    }

    return null;
  }

  /// Valida los filtros
  ValidationFailure? _validateFilters(NotificationFilters filters) {
    // Validar rango de fechas
    if (filters.fechaDesde != null && filters.fechaHasta != null) {
      if (filters.fechaDesde!.isAfter(filters.fechaHasta!)) {
        return const ValidationFailure(
          message: 'La fecha de inicio debe ser anterior a la fecha de fin',
          code: 4104,
        );
      }

      // Validar que el rango no sea mayor a 1 año
      final difference = filters.fechaHasta!.difference(filters.fechaDesde!);
      if (difference.inDays > 365) {
        return const ValidationFailure(
          message: 'El rango de fechas no puede ser mayor a 1 año',
          code: 4105,
        );
      }
    }

    // Validar prioridades
    if (filters.prioridades != null && filters.prioridades!.isNotEmpty) {
      for (final prioridad in filters.prioridades!) {
        if (prioridad < 1 || prioridad > 3) {
          return const ValidationFailure(
            message: 'Las prioridades deben estar entre 1 y 3',
            code: 4106,
          );
        }
      }
    }

    // Validar texto de búsqueda
    if (filters.textoBusqueda != null && filters.textoBusqueda!.isNotEmpty) {
      if (filters.textoBusqueda!.length < 2) {
        return const ValidationFailure(
          message: 'El texto de búsqueda debe tener al menos 2 caracteres',
          code: 4107,
        );
      }

      if (filters.textoBusqueda!.length > 100) {
        return const ValidationFailure(
          message: 'El texto de búsqueda no puede exceder 100 caracteres',
          code: 4108,
        );
      }
    }

    // Validar IDs de entidades asociadas
    if (filters.citaId != null && filters.citaId!.isEmpty) {
      return const ValidationFailure(
        message: 'El ID de cita no puede estar vacío',
        code: 4109,
      );
    }

    if (filters.terapeutaId != null && filters.terapeutaId!.isEmpty) {
      return const ValidationFailure(
        message: 'El ID de terapeuta no puede estar vacío',
        code: 4110,
      );
    }

    if (filters.reporteId != null && filters.reporteId!.isEmpty) {
      return const ValidationFailure(
        message: 'El ID de reporte no puede estar vacío',
        code: 4111,
      );
    }

    return null;
  }

  /// Valida los parámetros de paginación
  ValidationFailure? _validatePagination(NotificationPagination pagination) {
    // Validar número de página
    if (pagination.page < 1) {
      return const ValidationFailure(
        message: 'El número de página debe ser mayor a 0',
        code: 4112,
      );
    }

    if (pagination.page > 1000) {
      return const ValidationFailure(
        message: 'El número de página no puede ser mayor a 1000',
        code: 4113,
      );
    }

    // Validar límite
    if (pagination.limit < 1) {
      return const ValidationFailure(
        message: 'El límite debe ser mayor a 0',
        code: 4114,
      );
    }

    if (pagination.limit > 100) {
      return const ValidationFailure(
        message: 'El límite no puede ser mayor a 100',
        code: 4115,
      );
    }

    return null;
  }
} 