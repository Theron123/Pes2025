import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

/// Parámetros para crear una notificación
class CrearNotificacionParams extends Equatable {
  /// ID del usuario destinatario
  final String usuarioId;
  
  /// Tipo de notificación
  final TipoNotificacion tipo;
  
  /// Título de la notificación
  final String titulo;
  
  /// Mensaje/contenido de la notificación
  final String mensaje;
  
  /// Canal por el cual se enviará la notificación
  final CanalNotificacion canal;
  
  /// ID de la cita asociada (opcional)
  final String? citaId;
  
  /// ID del terapeuta asociado (opcional)
  final String? terapeutaId;
  
  /// ID del reporte asociado (opcional)
  final String? reporteId;
  
  /// Datos adicionales en formato JSON (opcional)
  final Map<String, dynamic>? datosAdicionales;
  
  /// Fecha y hora programada para envío (opcional)
  final DateTime? fechaProgramada;
  
  /// Si la notificación requiere acción del usuario
  final bool requiereAccion;
  
  /// URL o acción específica a ejecutar al tocar la notificación
  final String? accion;
  
  /// Si la notificación puede ser cancelada por el usuario
  final bool cancelable;
  
  /// Fecha de expiración de la notificación (opcional)
  final DateTime? fechaExpiracion;

  const CrearNotificacionParams({
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

/// Use case para crear una nueva notificación en el sistema
/// 
/// Valida los datos de entrada y crea una notificación siguiendo las reglas
/// de negocio del sistema hospitalario.
/// 
/// **Validaciones implementadas:**
/// - Título no puede estar vacío (3-100 caracteres)
/// - Mensaje no puede estar vacío (10-500 caracteres)
/// - Usuario ID debe ser válido
/// - Fecha programada debe ser en el futuro
/// - Fecha de expiración debe ser posterior a la fecha programada
/// - Acción debe ser una URL válida si se especifica
/// - Validaciones específicas por tipo de notificación
/// 
/// **Casos de uso:**
/// ```dart
/// final result = await crearNotificacionUseCase(
///   CrearNotificacionParams(
///     usuarioId: '123',
///     tipo: TipoNotificacion.recordatorioTarot,
///     titulo: 'Recordatorio de Cita',
///     mensaje: 'Su cita es mañana a las 10:00 AM',
///     canal: CanalNotificacion.push,
///     citaId: 'cita-123',
///     requiereAccion: true,
///     accion: '/appointments/details/cita-123',
///   ),
/// );
/// ```
class CrearNotificacionUseCase implements UseCase<NotificationEntity, CrearNotificacionParams> {
  final NotificationsRepository repository;

  CrearNotificacionUseCase(this.repository);

  @override
  Future<Result<NotificationEntity>> call(CrearNotificacionParams params) async {
    try {
      // Validar parámetros de entrada
      final validationResult = _validateParams(params);
      if (validationResult != null) {
        return Result.failure(validationResult);
      }

      // Crear la entidad NotificationEntity
      final notification = NotificationEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        usuarioId: params.usuarioId,
        tipo: params.tipo,
        titulo: params.titulo.trim(),
        mensaje: params.mensaje.trim(),
        estado: EstadoNotificacion.pendiente,
        canal: params.canal,
        citaId: params.citaId,
        terapeutaId: params.terapeutaId,
        reporteId: params.reporteId,
        datosAdicionales: params.datosAdicionales,
        fechaCreacion: DateTime.now(),
        fechaProgramada: params.fechaProgramada,
        requiereAccion: params.requiereAccion,
        accion: params.accion,
        cancelable: params.cancelable,
        fechaExpiracion: params.fechaExpiracion,
      );

      // Validar la entidad creada
      final entityValidationResult = _validateEntity(notification);
      if (entityValidationResult != null) {
        return Result.failure(entityValidationResult);
      }

      // Crear la notificación en el repositorio
      final result = await repository.crearNotificacion(notification);
      
      return result.fold(
        (failure) => Result.failure(failure),
        (createdNotification) => Result.success(createdNotification),
      );

    } catch (e) {
      return Result.failure(
        DatabaseFailure(
          message: 'Error inesperado al crear la notificación: ${e.toString()}',
          code: 4001,
        ),
      );
    }
  }

  /// Valida los parámetros de entrada
  ValidationFailure? _validateParams(CrearNotificacionParams params) {
    // Validar usuario ID
    if (params.usuarioId.isEmpty) {
      return const ValidationFailure(
        message: 'El ID del usuario es requerido',
        code: 4002,
      );
    }

    if (params.usuarioId.length < 3) {
      return const ValidationFailure(
        message: 'El ID del usuario debe tener al menos 3 caracteres',
        code: 4003,
      );
    }

    // Validar título
    if (params.titulo.trim().isEmpty) {
      return const ValidationFailure(
        message: 'El título de la notificación es requerido',
        code: 4004,
      );
    }

    if (params.titulo.trim().length < 3) {
      return const ValidationFailure(
        message: 'El título debe tener al menos 3 caracteres',
        code: 4005,
      );
    }

    if (params.titulo.trim().length > 100) {
      return const ValidationFailure(
        message: 'El título no puede exceder 100 caracteres',
        code: 4006,
      );
    }

    // Validar mensaje
    if (params.mensaje.trim().isEmpty) {
      return const ValidationFailure(
        message: 'El mensaje de la notificación es requerido',
        code: 4007,
      );
    }

    if (params.mensaje.trim().length < 10) {
      return const ValidationFailure(
        message: 'El mensaje debe tener al menos 10 caracteres',
        code: 4008,
      );
    }

    if (params.mensaje.trim().length > 500) {
      return const ValidationFailure(
        message: 'El mensaje no puede exceder 500 caracteres',
        code: 4009,
      );
    }

    // Validar fecha programada
    if (params.fechaProgramada != null) {
      final now = DateTime.now();
      if (params.fechaProgramada!.isBefore(now)) {
        return const ValidationFailure(
          message: 'La fecha programada debe ser en el futuro',
          code: 4010,
        );
      }

      // La fecha programada no puede ser más de 1 año en el futuro
      final oneYearFromNow = now.add(const Duration(days: 365));
      if (params.fechaProgramada!.isAfter(oneYearFromNow)) {
        return const ValidationFailure(
          message: 'La fecha programada no puede ser más de 1 año en el futuro',
          code: 4011,
        );
      }
    }

    // Validar fecha de expiración
    if (params.fechaExpiracion != null) {
      final now = DateTime.now();
      if (params.fechaExpiracion!.isBefore(now)) {
        return const ValidationFailure(
          message: 'La fecha de expiración debe ser en el futuro',
          code: 4012,
        );
      }

      // Si hay fecha programada, la expiración debe ser posterior
      if (params.fechaProgramada != null && 
          params.fechaExpiracion!.isBefore(params.fechaProgramada!)) {
        return const ValidationFailure(
          message: 'La fecha de expiración debe ser posterior a la fecha programada',
          code: 4013,
        );
      }
    }

    // Validar acción
    if (params.accion != null && params.accion!.isNotEmpty) {
      if (!_isValidAction(params.accion!)) {
        return const ValidationFailure(
          message: 'La acción debe ser una ruta válida (comenzar con /)',
          code: 4014,
        );
      }
    }

    // Validar IDs asociados según el tipo de notificación
    final typeValidationResult = _validateTypeSpecificRequirements(params);
    if (typeValidationResult != null) {
      return typeValidationResult;
    }

    return null;
  }

  /// Valida la entidad creada
  ValidationFailure? _validateEntity(NotificationEntity notification) {
    // Validar que el tipo de notificación sea coherente con los datos
    if (notification.tipo == TipoNotificacion.recordatorioTarot || 
        notification.tipo == TipoNotificacion.recordatorio24h ||
        notification.tipo == TipoNotificacion.recordatorio2h ||
        notification.tipo == TipoNotificacion.citaConfirmada ||
        notification.tipo == TipoNotificacion.citaCancelada ||
        notification.tipo == TipoNotificacion.citaReprogramada ||
        notification.tipo == TipoNotificacion.citaCompletada) {
      if (notification.citaId == null) {
        return const ValidationFailure(
          message: 'Las notificaciones relacionadas con citas requieren un ID de cita',
          code: 4015,
        );
      }
    }

    if (notification.tipo == TipoNotificacion.reporteGenerado) {
      if (notification.reporteId == null) {
        return const ValidationFailure(
          message: 'Las notificaciones de reporte requieren un ID de reporte',
          code: 4016,
        );
      }
    }

    // Validar que las notificaciones de alta prioridad tengan configuración adecuada
    if (notification.esAltaPrioridad) {
      if (notification.canal == CanalNotificacion.email) {
        return const ValidationFailure(
          message: 'Las notificaciones de alta prioridad no pueden usar solo email',
          code: 4017,
        );
      }
    }

    return null;
  }

  /// Valida los requerimientos específicos por tipo de notificación
  ValidationFailure? _validateTypeSpecificRequirements(CrearNotificacionParams params) {
    switch (params.tipo) {
      case TipoNotificacion.recordatorioTarot:
      case TipoNotificacion.recordatorio24h:
      case TipoNotificacion.recordatorio2h:
      case TipoNotificacion.citaConfirmada:
      case TipoNotificacion.citaCancelada:
      case TipoNotificacion.citaReprogramada:
      case TipoNotificacion.citaCompletada:
        if (params.citaId == null || params.citaId!.isEmpty) {
          return const ValidationFailure(
            message: 'Las notificaciones relacionadas con citas requieren un ID de cita',
            code: 4015,
          );
        }
        break;

      case TipoNotificacion.terapeutaAsignado:
      case TipoNotificacion.cambioTerapeuta:
        if (params.terapeutaId == null || params.terapeutaId!.isEmpty) {
          return const ValidationFailure(
            message: 'Las notificaciones relacionadas con terapeutas requieren un ID de terapeuta',
            code: 4018,
          );
        }
        break;

      case TipoNotificacion.reporteGenerado:
        if (params.reporteId == null || params.reporteId!.isEmpty) {
          return const ValidationFailure(
            message: 'Las notificaciones de reporte requieren un ID de reporte',
            code: 4016,
          );
        }
        break;

      default:
        // Otros tipos no requieren validaciones específicas
        break;
    }

    return null;
  }

  /// Valida si una acción es válida (debe ser una ruta)
  bool _isValidAction(String action) {
    // La acción debe comenzar con '/' (ruta relativa)
    if (!action.startsWith('/')) {
      return false;
    }

    // No debe contener caracteres especiales peligrosos
    final invalidChars = ['<', '>', '"', "'", '&', 'javascript:', 'data:'];
    for (final char in invalidChars) {
      if (action.contains(char)) {
        return false;
      }
    }

    return true;
  }
} 