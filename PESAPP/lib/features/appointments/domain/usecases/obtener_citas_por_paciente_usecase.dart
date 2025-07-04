import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/entities/appointment_entity.dart';
import '../repositories/citas_repository.dart';

/// Parámetros para el caso de uso ObtenerCitasPorPaciente
class ObtenerCitasPorPacienteParams {
  final String pacienteId;
  final EstadoCita? estado;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final int limite;
  final int pagina;

  const ObtenerCitasPorPacienteParams({
    required this.pacienteId,
    this.estado,
    this.fechaDesde,
    this.fechaHasta,
    this.limite = 50,
    this.pagina = 1,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ObtenerCitasPorPacienteParams &&
        other.pacienteId == pacienteId &&
        other.estado == estado &&
        other.fechaDesde == fechaDesde &&
        other.fechaHasta == fechaHasta &&
        other.limite == limite &&
        other.pagina == pagina;
  }

  @override
  int get hashCode {
    return pacienteId.hashCode ^
        estado.hashCode ^
        fechaDesde.hashCode ^
        fechaHasta.hashCode ^
        limite.hashCode ^
        pagina.hashCode;
  }
}

/// Caso de uso para obtener las citas de un paciente específico
/// 
/// Este caso de uso implementa la lógica para recuperar las citas de un paciente:
/// - Validar que el ID del paciente sea válido
/// - Aplicar filtros de estado si se especifica
/// - Aplicar filtros de fecha si se especifican
/// - Implementar paginación para mejorar el rendimiento
/// - Ordenar las citas por fecha (más recientes primero)
class ObtenerCitasPorPacienteUseCase implements UseCase<List<CitaEntity>, ObtenerCitasPorPacienteParams> {
  final CitasRepository citasRepository;

  const ObtenerCitasPorPacienteUseCase(this.citasRepository);

  @override
  Future<Result<List<CitaEntity>>> call(ObtenerCitasPorPacienteParams params) async {
    try {
      // Validar parámetros de entrada
      final validationResult = validarParametros(params);
      if (!validationResult.isSuccess) {
        return Result.failure(validationResult.error!);
      }

      // Validar rango de fechas si se proporcionan ambas
      if (params.fechaDesde != null && params.fechaHasta != null) {
        if (params.fechaDesde!.isAfter(params.fechaHasta!)) {
          return Result.failure(
            const ValidationFailure(
              message: 'La fecha de inicio debe ser anterior a la fecha de fin',
              code: 1101,
            ),
          );
        }
      }

      // Obtener las citas del repositorio
      final citasResult = await citasRepository.obtenerCitasPorPaciente(
        pacienteId: params.pacienteId,
        estado: params.estado,
        fechaDesde: params.fechaDesde,
        fechaHasta: params.fechaHasta,
        limite: params.limite,
        pagina: params.pagina,
      );

      if (!citasResult.isSuccess) {
        return Result.failure(citasResult.error!);
      }

      // Ordenar las citas por fecha de manera descendente (más recientes primero)
      final citas = citasResult.value!;
      citas.sort((a, b) => b.fechaHoraCompleta.compareTo(a.fechaHoraCompleta));

      return Result.success(citas);
    } catch (e) {
      return Result.failure(
        UnexpectedFailure(
          message: 'Error inesperado al obtener las citas del paciente: $e',
          code: 9998,
        ),
      );
    }
  }

  /// Validar parámetros de entrada
  static Result<bool> validarParametros(ObtenerCitasPorPacienteParams params) {
    // Validar ID del paciente
    if (params.pacienteId.isEmpty) {
      return Result.failure(
        const ValidationFailure(
          message: 'El ID del paciente es requerido',
          code: 1102,
        ),
      );
    }

    // Validar límite de paginación
    if (params.limite <= 0 || params.limite > 100) {
      return Result.failure(
        const ValidationFailure(
          message: 'El límite debe ser entre 1 y 100',
          code: 1103,
        ),
      );
    }

    // Validar número de página
    if (params.pagina < 1) {
      return Result.failure(
        const ValidationFailure(
          message: 'El número de página debe ser mayor a 0',
          code: 1104,
        ),
      );
    }

    return Result.success(true);
  }

  /// Filtrar citas por rango de fechas específico
  static List<CitaEntity> filtrarPorRangoFechas(
    List<CitaEntity> citas,
    DateTime fechaDesde,
    DateTime fechaHasta,
  ) {
    return citas.where((cita) {
      return cita.fechaCita.isAfter(fechaDesde.subtract(const Duration(days: 1))) &&
             cita.fechaCita.isBefore(fechaHasta.add(const Duration(days: 1)));
    }).toList();
  }

  /// Filtrar citas por estado específico
  static List<CitaEntity> filtrarPorEstado(
    List<CitaEntity> citas,
    EstadoCita estado,
  ) {
    return citas.where((cita) => cita.estado == estado).toList();
  }

  /// Obtener estadísticas básicas de las citas
  static Map<String, dynamic> obtenerEstadisticas(List<CitaEntity> citas) {
    final totalCitas = citas.length;
    final citasCompletadas = citas.where((c) => c.estado == EstadoCita.completada).length;
    final citasPendientes = citas.where((c) => c.estado == EstadoCita.pendiente).length;
    final citasCanceladas = citas.where((c) => c.estado == EstadoCita.cancelada).length;
    final citasConfirmadas = citas.where((c) => c.estado == EstadoCita.confirmada).length;

    return {
      'total': totalCitas,
      'completadas': citasCompletadas,
      'pendientes': citasPendientes,
      'canceladas': citasCanceladas,
      'confirmadas': citasConfirmadas,
      'tasaCompletado': totalCitas > 0 ? (citasCompletadas / totalCitas) : 0.0,
      'tasaCancelacion': totalCitas > 0 ? (citasCanceladas / totalCitas) : 0.0,
    };
  }

  /// Agrupar citas por mes para análisis temporal
  static Map<String, List<CitaEntity>> agruparPorMes(List<CitaEntity> citas) {
    final Map<String, List<CitaEntity>> citasPorMes = {};

    for (final cita in citas) {
      final mesAnio = '${cita.fechaCita.year}-${cita.fechaCita.month.toString().padLeft(2, '0')}';
      if (!citasPorMes.containsKey(mesAnio)) {
        citasPorMes[mesAnio] = [];
      }
      citasPorMes[mesAnio]!.add(cita);
    }

    return citasPorMes;
  }
} 