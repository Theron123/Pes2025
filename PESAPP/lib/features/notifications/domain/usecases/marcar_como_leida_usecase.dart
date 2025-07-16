import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

/// Parámetros para marcar una notificación como leída
class MarcarComoLeidaParams extends Equatable {
  /// ID de la notificación a marcar como leída
  final String notificationId;

  const MarcarComoLeidaParams({
    required this.notificationId,
  });

  @override
  List<Object> get props => [notificationId];
}

/// Use case para marcar una notificación como leída
/// 
/// Permite marcar una notificación específica como leída, actualizando
/// su estado y fecha de lectura en el sistema.
/// 
/// **Validaciones implementadas:**
/// - ID de notificación no puede estar vacío
/// - ID debe tener formato válido
/// - La notificación debe existir
/// - La notificación debe poder ser marcada como leída
/// 
/// **Casos de uso:**
/// ```dart
/// final result = await marcarComoLeidaUseCase(
///   MarcarComoLeidaParams(notificationId: 'notif-123'),
/// );
/// 
/// if (result.isSuccess) {
///   final notification = result.value!;
///   print('Notificación marcada como leída: ${notification.titulo}');
/// }
/// ```
class MarcarComoLeidaUseCase implements UseCase<NotificationEntity, MarcarComoLeidaParams> {
  final NotificationsRepository repository;

  MarcarComoLeidaUseCase(this.repository);

  @override
  Future<Result<NotificationEntity>> call(MarcarComoLeidaParams params) async {
    try {
      // Validar parámetros de entrada
      final validationResult = _validateParams(params);
      if (validationResult != null) {
        return Result.failure(validationResult);
      }

      // Marcar como leída en el repositorio
      final result = await repository.marcarComoLeida(params.notificationId);

      return result.fold(
        (failure) => Result.failure(failure),
        (updatedNotification) => Result.success(updatedNotification),
      );

    } catch (e) {
      return Result.failure(
        DatabaseFailure(
          message: 'Error inesperado al marcar notificación como leída: ${e.toString()}',
          code: 4201,
        ),
      );
    }
  }

  /// Valida los parámetros de entrada
  ValidationFailure? _validateParams(MarcarComoLeidaParams params) {
    // Validar que el ID no esté vacío
    if (params.notificationId.isEmpty) {
      return const ValidationFailure(
        message: 'El ID de la notificación es requerido',
        code: 4202,
      );
    }

    // Validar longitud mínima del ID
    if (params.notificationId.length < 3) {
      return const ValidationFailure(
        message: 'El ID de la notificación debe tener al menos 3 caracteres',
        code: 4203,
      );
    }

    // Validar que el ID no contenga caracteres especiales
    if (!_isValidId(params.notificationId)) {
      return const ValidationFailure(
        message: 'El ID de la notificación contiene caracteres no válidos',
        code: 4204,
      );
    }

    return null;
  }

  /// Valida si un ID tiene formato válido
  bool _isValidId(String id) {
    // El ID debe contener solo letras, números, guiones y guiones bajos
    final validIdRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    return validIdRegex.hasMatch(id);
  }
} 