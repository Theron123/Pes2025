import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/domain/entities/therapist_entity.dart';
import '../repositories/terapeutas_repository.dart';

/// Use case para crear un nuevo terapeuta en el sistema
/// 
/// Características:
/// - Validación completa de datos de entrada
/// - Verificación de licencia única
/// - Validación de horarios de trabajo
/// - Verificación de especializaciones válidas
/// - Manejo de errores específicos
class CrearTerapeutaUseCase implements UseCase<TerapeutaEntity, CrearTerapeutaParams> {
  final TerapeutasRepository terapeutasRepository;

  const CrearTerapeutaUseCase({required this.terapeutasRepository});

  @override
  Future<Result<TerapeutaEntity>> call(CrearTerapeutaParams params) async {
    try {
      // Validar parámetros de entrada
      final validationResult = validarParametros(params);
      if (!validationResult.isSuccess) {
        return Result.failure(validationResult.error!);
      }

      // Verificar que el número de licencia no esté en uso
      final licenciaExisteResult = await terapeutasRepository.verificarLicenciaExiste(
        numeroLicencia: params.numeroLicencia,
      );

      if (!licenciaExisteResult.isSuccess) {
        return Result.failure(licenciaExisteResult.error!);
      }

      if (licenciaExisteResult.value == true) {
        return Result.failure(
          const ValidationFailure(
            message: 'El número de licencia ya está registrado en el sistema',
            code: 3001,
          ),
        );
      }

      // Validar horarios de trabajo
      final horariosValidacionResult = validarHorariosTrabajo(params.horariosTrabajo);
      if (!horariosValidacionResult.isSuccess) {
        return Result.failure(horariosValidacionResult.error!);
      }

      // Crear el terapeuta
      final terapeutaResult = await terapeutasRepository.crearTerapeuta(
        usuarioId: params.usuarioId,
        numeroLicencia: params.numeroLicencia,
        especializaciones: params.especializaciones,
        horariosTrabajo: params.horariosTrabajo,
        disponible: params.disponible,
      );

      return terapeutaResult;
    } catch (e) {
      return Result.failure(
        UnexpectedFailure(
          message: 'Error inesperado al crear el terapeuta: $e',
          code: 9999,
        ),
      );
    }
  }

  /// Validar parámetros de entrada
  static Result<bool> validarParametros(CrearTerapeutaParams params) {
    // Validar ID de usuario
    if (params.usuarioId.isEmpty) {
      return Result.failure(
        const ValidationFailure(
          message: 'El ID del usuario es requerido',
          code: 3002,
        ),
      );
    }

    // Validar número de licencia
    if (params.numeroLicencia.isEmpty) {
      return Result.failure(
        const ValidationFailure(
          message: 'El número de licencia es requerido',
          code: 3003,
        ),
      );
    }

    if (params.numeroLicencia.length < 5 || params.numeroLicencia.length > 20) {
      return Result.failure(
        const ValidationFailure(
          message: 'El número de licencia debe tener entre 5 y 20 caracteres',
          code: 3004,
        ),
      );
    }

    // Validar que tenga al menos una especialización
    if (params.especializaciones.isEmpty) {
      return Result.failure(
        const ValidationFailure(
          message: 'El terapeuta debe tener al menos una especialización',
          code: 3005,
        ),
      );
    }

    // Validar que no tenga más de 5 especializaciones
    if (params.especializaciones.length > 5) {
      return Result.failure(
        const ValidationFailure(
          message: 'El terapeuta no puede tener más de 5 especializaciones',
          code: 3006,
        ),
      );
    }

    // Validar especializaciones únicas
    final especializacionesUnicas = params.especializaciones.toSet();
    if (especializacionesUnicas.length != params.especializaciones.length) {
      return Result.failure(
        const ValidationFailure(
          message: 'No se pueden repetir especializaciones',
          code: 3007,
        ),
      );
    }

    return Result.success(true);
  }

  /// Validar horarios de trabajo
  static Result<bool> validarHorariosTrabajo(HorariosTrabajo horarios) {
    // Verificar que tenga los 7 días de la semana
    if (horarios.horariosSemana.length != 7) {
      return Result.failure(
        const ValidationFailure(
          message: 'Se deben definir horarios para los 7 días de la semana',
          code: 3008,
        ),
      );
    }

    // Verificar que cada día esté representado exactamente una vez
    final diasDefinidos = horarios.horariosSemana.map((h) => h.dia).toSet();
    if (diasDefinidos.length != 7) {
      return Result.failure(
        const ValidationFailure(
          message: 'Cada día de la semana debe estar definido exactamente una vez',
          code: 3009,
        ),
      );
    }

    // Verificar que al menos haya un día de trabajo
    final diasTrabajo = horarios.horariosSemana.where((h) => !h.esDiaLibre).toList();
    if (diasTrabajo.isEmpty) {
      return Result.failure(
        const ValidationFailure(
          message: 'El terapeuta debe trabajar al menos un día a la semana',
          code: 3010,
        ),
      );
    }

    // Validar cada día de trabajo
    for (final horarioDia in horarios.horariosSemana) {
      if (!horarioDia.esValido) {
        return Result.failure(
          ValidationFailure(
            message: 'El horario para ${horarioDia.dia.nombre} no es válido',
            code: 3011,
          ),
        );
      }

      // Verificar horarios de trabajo razonables (no más de 12 horas por día)
      if (!horarioDia.esDiaLibre && 
          horarioDia.horaInicio != null && 
          horarioDia.horaFin != null) {
        final horasTrabajoTotal = (horarioDia.horaFin!.totalMinutos - 
            horarioDia.horaInicio!.totalMinutos) / 60;
        
        if (horasTrabajoTotal > 12) {
          return Result.failure(
            ValidationFailure(
              message: 'El horario de trabajo para ${horarioDia.dia.nombre} no puede exceder 12 horas',
              code: 3012,
            ),
          );
        }

        if (horasTrabajoTotal < 1) {
          return Result.failure(
            ValidationFailure(
              message: 'El horario de trabajo para ${horarioDia.dia.nombre} debe ser de al menos 1 hora',
              code: 3013,
            ),
          );
        }
      }
    }

    return Result.success(true);
  }
}

/// Parámetros para crear un terapeuta
class CrearTerapeutaParams extends Equatable {
  final String usuarioId;
  final String numeroLicencia;
  final List<EspecializacionMasaje> especializaciones;
  final HorariosTrabajo horariosTrabajo;
  final bool disponible;

  const CrearTerapeutaParams({
    required this.usuarioId,
    required this.numeroLicencia,
    required this.especializaciones,
    required this.horariosTrabajo,
    this.disponible = true,
  });

  @override
  List<Object> get props => [
    usuarioId,
    numeroLicencia,
    especializaciones,
    horariosTrabajo,
    disponible,
  ];
} 