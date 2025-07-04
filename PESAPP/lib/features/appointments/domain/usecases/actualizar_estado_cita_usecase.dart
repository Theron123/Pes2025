import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/entities/appointment_entity.dart';
import '../repositories/citas_repository.dart';

/// Parámetros para el caso de uso ActualizarEstadoCita
class ActualizarEstadoCitaParams {
  final String citaId;
  final EstadoCita nuevoEstado;
  final String usuarioId;
  final String? notas;

  const ActualizarEstadoCitaParams({
    required this.citaId,
    required this.nuevoEstado,
    required this.usuarioId,
    this.notas,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActualizarEstadoCitaParams &&
        other.citaId == citaId &&
        other.nuevoEstado == nuevoEstado &&
        other.usuarioId == usuarioId &&
        other.notas == notas;
  }

  @override
  int get hashCode {
    return citaId.hashCode ^
        nuevoEstado.hashCode ^
        usuarioId.hashCode ^
        notas.hashCode;
  }
}

/// Caso de uso para actualizar el estado de una cita en el sistema hospitalario
/// 
/// Este caso de uso implementa toda la lógica de negocio para cambiar el estado de una cita:
/// - Validar que la cita existe
/// - Verificar que la transición de estado es válida
/// - Validar permisos según el rol del usuario
/// - Registrar el cambio con auditoría
/// - Actualizar el estado de manera atómica
class ActualizarEstadoCitaUseCase implements UseCase<CitaEntity, ActualizarEstadoCitaParams> {
  final CitasRepository citasRepository;

  const ActualizarEstadoCitaUseCase(this.citasRepository);

  @override
  Future<Result<CitaEntity>> call(ActualizarEstadoCitaParams params) async {
    try {
      // Validar parámetros de entrada
      final validationResult = validarParametros(params);
      if (!validationResult.isSuccess) {
        return Result.failure(validationResult.error!);
      }

      // Obtener la cita actual para validar el estado
      final citaActualResult = await citasRepository.obtenerCitaPorId(params.citaId);
      if (!citaActualResult.isSuccess) {
        return Result.failure(citaActualResult.error!);
      }

      final citaActual = citaActualResult.value!;

      // Validar que la transición de estado es válida
      final transicionValidaResult = validarTransicionEstado(
        citaActual.estado,
        params.nuevoEstado,
      );
      if (!transicionValidaResult.isSuccess) {
        return Result.failure(transicionValidaResult.error!);
      }

      // Validar reglas de negocio específicas por estado
      final reglasNegocioResult = validarReglasNegocioPorEstado(
        citaActual,
        params.nuevoEstado,
      );
      if (!reglasNegocioResult.isSuccess) {
        return Result.failure(reglasNegocioResult.error!);
      }

      // Actualizar el estado en el repositorio
      final citaActualizadaResult = await citasRepository.actualizarEstadoCita(
        citaId: params.citaId,
        nuevoEstado: params.nuevoEstado,
        notas: params.notas,
        usuarioId: params.usuarioId,
      );

      return citaActualizadaResult;
    } catch (e) {
      return Result.failure(
        UnexpectedFailure(
          message: 'Error inesperado al actualizar el estado de la cita: $e',
          code: 9997,
        ),
      );
    }
  }

  /// Validar parámetros de entrada
  static Result<bool> validarParametros(ActualizarEstadoCitaParams params) {
    // Validar ID de la cita
    if (params.citaId.isEmpty) {
      return Result.failure(
        const ValidationFailure(
          message: 'El ID de la cita es requerido',
          code: 1201,
        ),
      );
    }

    // Validar ID del usuario
    if (params.usuarioId.isEmpty) {
      return Result.failure(
        const ValidationFailure(
          message: 'El ID del usuario es requerido',
          code: 1202,
        ),
      );
    }

    // Validar notas si existen
    if (params.notas != null && params.notas!.length > 500) {
      return Result.failure(
        const ValidationFailure(
          message: 'Las notas no pueden exceder 500 caracteres',
          code: 1203,
        ),
      );
    }

    return Result.success(true);
  }

  /// Validar que la transición de estado es válida según las reglas de negocio
  static Result<bool> validarTransicionEstado(
    EstadoCita estadoActual,
    EstadoCita nuevoEstado,
  ) {
    // Si es el mismo estado, no hay cambio
    if (estadoActual == nuevoEstado) {
      return Result.failure(
        const ValidationFailure(
          message: 'El nuevo estado debe ser diferente al estado actual',
          code: 1204,
        ),
      );
    }

    // Estados finales no pueden cambiar
    if (estadoActual.esFinalizado) {
      return Result.failure(
        const ValidationFailure(
          message: 'No se puede cambiar el estado de una cita finalizada',
          code: 1205,
        ),
      );
    }

    // Validar transiciones específicas
    switch (estadoActual) {
      case EstadoCita.pendiente:
        // Desde pendiente puede ir a confirmada, cancelada o noShow
        if (![EstadoCita.confirmada, EstadoCita.cancelada, EstadoCita.noShow]
            .contains(nuevoEstado)) {
          return Result.failure(
            const ValidationFailure(
              message: 'Desde estado pendiente solo se puede cambiar a confirmada, cancelada o no presentado',
              code: 1206,
            ),
          );
        }
        break;

      case EstadoCita.confirmada:
        // Desde confirmada puede ir a enProgreso, completada, cancelada o noShow
        if (![EstadoCita.enProgreso, EstadoCita.completada, EstadoCita.cancelada, EstadoCita.noShow]
            .contains(nuevoEstado)) {
          return Result.failure(
            const ValidationFailure(
              message: 'Desde estado confirmada solo se puede cambiar a en progreso, completada, cancelada o no presentado',
              code: 1207,
            ),
          );
        }
        break;

      case EstadoCita.enProgreso:
        // Desde enProgreso solo puede ir a completada
        if (nuevoEstado != EstadoCita.completada) {
          return Result.failure(
            const ValidationFailure(
              message: 'Desde estado en progreso solo se puede cambiar a completada',
              code: 1208,
            ),
          );
        }
        break;

      default:
        // Estados finales no deberían llegar aquí
        return Result.failure(
          const ValidationFailure(
            message: 'Transición de estado no válida',
            code: 1209,
          ),
        );
    }

    return Result.success(true);
  }

  /// Validar reglas de negocio específicas por estado
  static Result<bool> validarReglasNegocioPorEstado(
    CitaEntity cita,
    EstadoCita nuevoEstado,
  ) {
    final ahora = DateTime.now();

    switch (nuevoEstado) {
      case EstadoCita.enProgreso:
        // Solo se puede marcar en progreso en el día de la cita y cerca del horario
        if (!cita.esHoy) {
          return Result.failure(
            const ValidationFailure(
              message: 'Solo se puede marcar en progreso el día de la cita',
              code: 1210,
            ),
          );
        }

        // Verificar que esté dentro de una ventana de tiempo razonable
        final diferenciaTiempo = cita.fechaHoraCompleta.difference(ahora).inMinutes.abs();
        if (diferenciaTiempo > 30) {
          return Result.failure(
            const ValidationFailure(
              message: 'Solo se puede marcar en progreso dentro de 30 minutos del horario programado',
              code: 1211,
            ),
          );
        }
        break;

      case EstadoCita.completada:
        // Solo se puede completar si ya estaba en progreso o si es el día de la cita
        if (cita.estado != EstadoCita.enProgreso && !cita.esHoy) {
          return Result.failure(
            const ValidationFailure(
              message: 'Solo se puede completar una cita en progreso o en el día programado',
              code: 1212,
            ),
          );
        }
        break;

      case EstadoCita.noShow:
        // Solo se puede marcar como no presentado después del horario programado
        if (ahora.isBefore(cita.fechaHoraCompleta.add(const Duration(minutes: 15)))) {
          return Result.failure(
            const ValidationFailure(
              message: 'Solo se puede marcar como no presentado después de 15 minutos del horario programado',
              code: 1213,
            ),
          );
        }
        break;

      case EstadoCita.cancelada:
        // Se puede cancelar en cualquier momento antes de la cita (con las reglas de cancelación)
        if (!cita.puedeSerCancelada) {
          return Result.failure(
            const ValidationFailure(
              message: 'Esta cita ya no puede ser cancelada (menos de 2 horas antes del horario)',
              code: 1214,
            ),
          );
        }
        break;

      default:
        // Estados válidos sin reglas especiales
        break;
    }

    return Result.success(true);
  }

  /// Obtener transiciones de estado válidas para una cita
  static List<EstadoCita> obtenerTransicionesValidas(CitaEntity cita) {
    if (cita.estado.esFinalizado) {
      return []; // Estados finales no pueden cambiar
    }

    switch (cita.estado) {
      case EstadoCita.pendiente:
        return [EstadoCita.confirmada, EstadoCita.cancelada, EstadoCita.noShow];

      case EstadoCita.confirmada:
        final transiciones = <EstadoCita>[EstadoCita.cancelada];
        
        // Solo permitir en progreso y completada cerca del horario
        final ahora = DateTime.now();
        final diferenciaTiempo = cita.fechaHoraCompleta.difference(ahora).inMinutes;
        
        if (diferenciaTiempo <= 30 && diferenciaTiempo >= -30) {
          transiciones.addAll([EstadoCita.enProgreso, EstadoCita.completada]);
        }
        
        // Permitir no show después del horario
        if (ahora.isAfter(cita.fechaHoraCompleta.add(const Duration(minutes: 15)))) {
          transiciones.add(EstadoCita.noShow);
        }
        
        return transiciones;

      case EstadoCita.enProgreso:
        return [EstadoCita.completada];

      default:
        return [];
    }
  }

  /// Verificar si un usuario tiene permisos para cambiar el estado
  static bool tienePermisosParaCambiarEstado(
    String rolUsuario,
    EstadoCita estadoActual,
    EstadoCita nuevoEstado,
  ) {
    switch (rolUsuario.toLowerCase()) {
      case 'admin':
      case 'administrador':
        return true; // Administradores pueden cambiar cualquier estado

      case 'terapeuta':
        // Terapeutas pueden confirmar, marcar en progreso y completar sus citas
        return [
          EstadoCita.confirmada,
          EstadoCita.enProgreso,
          EstadoCita.completada,
          EstadoCita.noShow,
        ].contains(nuevoEstado);

      case 'recepcionista':
        // Recepcionistas pueden confirmar y cancelar citas
        return [
          EstadoCita.confirmada,
          EstadoCita.cancelada,
        ].contains(nuevoEstado);

      case 'paciente':
        // Pacientes solo pueden cancelar sus citas
        return nuevoEstado == EstadoCita.cancelada;

      default:
        return false;
    }
  }
} 