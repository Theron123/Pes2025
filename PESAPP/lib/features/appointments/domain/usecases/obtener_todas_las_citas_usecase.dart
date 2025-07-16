import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/entities/appointment_entity.dart';
import '../repositories/citas_repository.dart';

/// Parámetros para el caso de uso ObtenerTodasLasCitas
class ObtenerTodasLasCitasParams {
  final EstadoCita? estado;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final String? terapeutaId;
  final int limite;
  final int pagina;

  const ObtenerTodasLasCitasParams({
    this.estado,
    this.fechaDesde,
    this.fechaHasta,
    this.terapeutaId,
    this.limite = 100,
    this.pagina = 1,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ObtenerTodasLasCitasParams &&
        other.estado == estado &&
        other.fechaDesde == fechaDesde &&
        other.fechaHasta == fechaHasta &&
        other.terapeutaId == terapeutaId &&
        other.limite == limite &&
        other.pagina == pagina;
  }

  @override
  int get hashCode {
    return estado.hashCode ^
        fechaDesde.hashCode ^
        fechaHasta.hashCode ^
        terapeutaId.hashCode ^
        limite.hashCode ^
        pagina.hashCode;
  }
}

/// Caso de uso para obtener todas las citas registradas en el sistema
/// 
/// Este caso de uso permite:
/// - Obtener todas las citas independientemente del estado
/// - Filtrar por fecha, terapeuta o estado específico
/// - Paginación para manejar grandes volúmenes de datos
/// - Acceso para todos los roles de usuario
class ObtenerTodasLasCitasUseCase implements UseCase<List<CitaEntity>, ObtenerTodasLasCitasParams> {
  final CitasRepository citasRepository;

  const ObtenerTodasLasCitasUseCase(this.citasRepository);

  @override
  Future<Result<List<CitaEntity>>> call(ObtenerTodasLasCitasParams params) async {
    try {
      // Validar parámetros de paginación
      if (params.limite <= 0 || params.limite > 1000) {
        return Result.failure(
          const ValidationFailure(
            message: 'El límite debe ser entre 1 y 1000',
            code: 2001,
          ),
        );
      }

      if (params.pagina <= 0) {
        return Result.failure(
          const ValidationFailure(
            message: 'La página debe ser mayor a 0',
            code: 2002,
          ),
        );
      }

      // Validar fechas si se proporcionan
      if (params.fechaDesde != null && params.fechaHasta != null) {
        if (params.fechaDesde!.isAfter(params.fechaHasta!)) {
          return Result.failure(
            const ValidationFailure(
              message: 'La fecha de inicio no puede ser posterior a la fecha de fin',
              code: 2003,
            ),
          );
        }
      }

      // Obtener todas las citas del repositorio
      final result = await citasRepository.obtenerTodasLasCitas(
        estado: params.estado,
        fechaDesde: params.fechaDesde,
        fechaHasta: params.fechaHasta,
        terapeutaId: params.terapeutaId,
        limite: params.limite,
        pagina: params.pagina,
      );

      return result;
    } catch (e) {
      return Result.failure(
        UnexpectedFailure(
          message: 'Error inesperado al obtener las citas: $e',
        ),
      );
    }
  }
} 