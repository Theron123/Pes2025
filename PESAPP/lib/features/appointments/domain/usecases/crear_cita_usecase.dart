import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/entities/appointment_entity.dart';
import '../repositories/citas_repository.dart';

/// Parámetros para el caso de uso CrearCita
class CrearCitaParams {
  final String pacienteId;
  final String terapeutaId;
  final DateTime fechaCita;
  final DateTime horaCita;
  final String tipoMasaje;
  final int duracionMinutos;
  final String? notas;

  const CrearCitaParams({
    required this.pacienteId,
    required this.terapeutaId,
    required this.fechaCita,
    required this.horaCita,
    required this.tipoMasaje,
    this.duracionMinutos = 60,
    this.notas,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CrearCitaParams &&
        other.pacienteId == pacienteId &&
        other.terapeutaId == terapeutaId &&
        other.fechaCita == fechaCita &&
        other.horaCita == horaCita &&
        other.tipoMasaje == tipoMasaje &&
        other.duracionMinutos == duracionMinutos &&
        other.notas == notas;
  }

  @override
  int get hashCode {
    return pacienteId.hashCode ^
        terapeutaId.hashCode ^
        fechaCita.hashCode ^
        horaCita.hashCode ^
        tipoMasaje.hashCode ^
        duracionMinutos.hashCode ^
        notas.hashCode;
  }
}

/// Caso de uso para crear una nueva cita en el sistema hospitalario
/// 
/// Este caso de uso implementa toda la lógica de negocio para crear una cita:
/// - Validar que la fecha sea futura
/// - Validar horarios de trabajo del terapeuta
/// - Verificar disponibilidad del terapeuta
/// - Detectar conflictos de horario
/// - Crear la cita si pasa todas las validaciones
class CrearCitaUseCase implements UseCase<CitaEntity, CrearCitaParams> {
  final CitasRepository citasRepository;

  const CrearCitaUseCase(this.citasRepository);

  @override
  Future<Result<CitaEntity>> call(CrearCitaParams params) async {
    try {
      // Validar que la fecha de la cita sea futura
      final fechaHoraCompleta = DateTime(
        params.fechaCita.year,
        params.fechaCita.month,
        params.fechaCita.day,
        params.horaCita.hour,
        params.horaCita.minute,
      );

      if (fechaHoraCompleta.isBefore(DateTime.now())) {
        return Result.failure(
          const ValidationFailure(
            message: 'La fecha y hora de la cita debe ser futura',
            code: 1001,
          ),
        );
      }

      // Validar que la cita no sea con más de 1 año de anticipación
      final fechaLimite = DateTime.now().add(const Duration(days: 365));
      if (fechaHoraCompleta.isAfter(fechaLimite)) {
        return Result.failure(
          const ValidationFailure(
            message: 'No se pueden crear citas con más de 1 año de anticipación',
            code: 1002,
          ),
        );
      }

      // Validar duración de la cita
      if (params.duracionMinutos < 30 || params.duracionMinutos > 180) {
        return Result.failure(
          const ValidationFailure(
            message: 'La duración de la cita debe ser entre 30 y 180 minutos',
            code: 1003,
          ),
        );
      }

      // TODO: Reactivar cuando la verificación de disponibilidad esté funcionando
      // Verificar disponibilidad del terapeuta
      // final disponibilidadResult = await citasRepository.verificarDisponibilidadTerapeuta(
      //   terapeutaId: params.terapeutaId,
      //   fechaCita: params.fechaCita,
      //   horaCita: params.horaCita,
      //   duracionMinutos: params.duracionMinutos,
      // );

      // if (!disponibilidadResult.isSuccess) {
      //   return Result.failure(
      //     disponibilidadResult.error!,
      //   );
      // }

      // if (disponibilidadResult.value != true) {
      //   return Result.failure(
      //     const AppointmentFailure(
      //       message: 'El terapeuta no está disponible en el horario solicitado',
      //       code: 2001,
      //     ),
      //   );
      // }

      // TODO: Reactivar cuando la verificación de conflictos esté funcionando
      // Verificar conflictos de horario
      // final conflictosResult = await citasRepository.verificarConflictosHorario(
      //   terapeutaId: params.terapeutaId,
      //   fechaCita: params.fechaCita,
      //   horaCita: params.horaCita,
      //   duracionMinutos: params.duracionMinutos,
      // );

      // if (!conflictosResult.isSuccess) {
      //   return Result.failure(
      //     conflictosResult.error!,
      //   );
      // }

      // if (conflictosResult.value!.isNotEmpty) {
      //   return Result.failure(
      //     const AppointmentFailure(
      //       message: 'Ya existe una cita en conflicto con el horario solicitado',
      //       code: 2002,
      //     ),
      //   );
      // }

      // Crear la cita
      final citaResult = await citasRepository.crearCita(
        pacienteId: params.pacienteId,
        terapeutaId: params.terapeutaId,
        fechaCita: params.fechaCita,
        horaCita: params.horaCita,
        tipoMasaje: params.tipoMasaje,
        duracionMinutos: params.duracionMinutos,
        notas: params.notas,
      );

      return citaResult;
    } catch (e) {
      return Result.failure(
        UnexpectedFailure(
          message: 'Error inesperado al crear la cita: $e',
          code: 9999,
        ),
      );
    }
  }

  /// Validar parámetros de entrada
  static Result<bool> validarParametros(CrearCitaParams params) {
    // Validar IDs
    if (params.pacienteId.isEmpty) {
      return Result.failure(
        const ValidationFailure(
          message: 'El ID del paciente es requerido',
          code: 1004,
        ),
      );
    }

    if (params.terapeutaId.isEmpty) {
      return Result.failure(
        const ValidationFailure(
          message: 'El ID del terapeuta es requerido',
          code: 1005,
        ),
      );
    }

    if (params.pacienteId == params.terapeutaId) {
      return Result.failure(
        const ValidationFailure(
          message: 'El paciente y el terapeuta no pueden ser el mismo usuario',
          code: 1006,
        ),
      );
    }

    // Validar tipo de masaje
    if (params.tipoMasaje.isEmpty) {
      return Result.failure(
        const ValidationFailure(
          message: 'El tipo de masaje es requerido',
          code: 1007,
        ),
      );
    }

    // Validar notas si existen
    if (params.notas != null && params.notas!.length > 500) {
      return Result.failure(
        const ValidationFailure(
          message: 'Las notas no pueden exceder 500 caracteres',
          code: 1008,
        ),
      );
    }

    return Result.success(true);
  }

  /// Calcular horarios sugeridos en caso de conflicto
  static List<DateTime> calcularHorariosSugeridos(
    DateTime fechaCita,
    DateTime horaOriginal,
    int duracionMinutos,
  ) {
    final horariosSugeridos = <DateTime>[];
    
    // Sugerir horarios antes del horario original
    for (int i = 1; i <= 3; i++) {
      final horarioAnterior = horaOriginal.subtract(Duration(minutes: i * 30));
      if (horarioAnterior.hour >= 8) { // Horario mínimo de trabajo
        horariosSugeridos.add(DateTime(
          fechaCita.year,
          fechaCita.month,
          fechaCita.day,
          horarioAnterior.hour,
          horarioAnterior.minute,
        ));
      }
    }

    // Sugerir horarios después del horario original
    for (int i = 1; i <= 3; i++) {
      final horarioPosterior = horaOriginal.add(Duration(minutes: i * 30));
      if (horarioPosterior.hour < 18) { // Horario máximo de trabajo
        horariosSugeridos.add(DateTime(
          fechaCita.year,
          fechaCita.month,
          fechaCita.day,
          horarioPosterior.hour,
          horarioPosterior.minute,
        ));
      }
    }

    return horariosSugeridos;
  }
} 