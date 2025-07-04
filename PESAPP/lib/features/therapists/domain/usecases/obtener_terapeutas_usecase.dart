import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/domain/entities/therapist_entity.dart';
import '../repositories/terapeutas_repository.dart';

/// Use case para obtener terapeutas con filtros diversos
/// 
/// Características:
/// - Filtro por disponibilidad
/// - Filtro por especialización
/// - Paginación
/// - Búsqueda por texto
/// - Verificación de disponibilidad en fecha/hora específica
class ObtenerTerapeutasUseCase implements UseCase<List<TerapeutaEntity>, ObtenerTerapeutasParams> {
  final TerapeutasRepository terapeutasRepository;

  const ObtenerTerapeutasUseCase({required this.terapeutasRepository});

  @override
  Future<Result<List<TerapeutaEntity>>> call(ObtenerTerapeutasParams params) async {
    try {
      // Validar parámetros de entrada
      final validationResult = validarParametros(params);
      if (!validationResult.isSuccess) {
        return Result.failure(validationResult.error!);
      }

      Result<List<TerapeutaEntity>> terapeutasResult;

      // Determinar qué tipo de búsqueda realizar
      if (params.textoBusqueda != null && params.textoBusqueda!.isNotEmpty) {
        // Búsqueda por texto
        terapeutasResult = await terapeutasRepository.buscarTerapeutas(
          textoBusqueda: params.textoBusqueda!,
          disponibleSolo: params.disponibleSolo,
        );
      } else if (params.fechaHoraDisponibilidad != null) {
        // Búsqueda por disponibilidad específica
        terapeutasResult = await terapeutasRepository.obtenerTerapeutasDisponibles(
          fechaHora: params.fechaHoraDisponibilidad!,
          duracionMinutos: params.duracionMinutos ?? 60,
          especializacion: params.especializacion,
        );
      } else {
        // Búsqueda general con filtros
        terapeutasResult = await terapeutasRepository.obtenerTerapeutas(
          disponibleSolo: params.disponibleSolo,
          especializacion: params.especializacion,
          limite: params.limite,
          pagina: params.pagina,
        );
      }

      if (!terapeutasResult.isSuccess) {
        return Result.failure(terapeutasResult.error!);
      }

      // Aplicar filtros adicionales si es necesario
      var terapeutas = terapeutasResult.value!;

      // Filtrar por múltiples especializaciones si se especificó
      if (params.especializaciones != null && params.especializaciones!.isNotEmpty) {
        terapeutas = terapeutas.where((terapeuta) {
          return params.especializaciones!.any((esp) => terapeuta.tieneEspecializacion(esp));
        }).toList();
      }

      // Ordenar resultados según criterio especificado
      if (params.ordenarPor != null) {
        terapeutas = ordenarTerapeutas(terapeutas, params.ordenarPor!);
      }

      return Result.success(terapeutas);
    } catch (e) {
      return Result.failure(
        UnexpectedFailure(
          message: 'Error inesperado al obtener terapeutas: $e',
          code: 9999,
        ),
      );
    }
  }

  /// Validar parámetros de entrada
  static Result<bool> validarParametros(ObtenerTerapeutasParams params) {
    // Validar límite de paginación
    if (params.limite <= 0 || params.limite > 100) {
      return Result.failure(
        const ValidationFailure(
          message: 'El límite debe estar entre 1 y 100',
          code: 3020,
        ),
      );
    }

    // Validar página
    if (params.pagina <= 0) {
      return Result.failure(
        const ValidationFailure(
          message: 'La página debe ser mayor a 0',
          code: 3021,
        ),
      );
    }

    // Validar duración si se especifica disponibilidad
    if (params.fechaHoraDisponibilidad != null) {
      if (params.duracionMinutos == null || params.duracionMinutos! <= 0) {
        return Result.failure(
          const ValidationFailure(
            message: 'La duración en minutos es requerida cuando se verifica disponibilidad',
            code: 3022,
          ),
        );
      }

      if (params.duracionMinutos! > 480) { // Máximo 8 horas
        return Result.failure(
          const ValidationFailure(
            message: 'La duración no puede exceder 480 minutos (8 horas)',
            code: 3023,
          ),
        );
      }
    }

    // Validar texto de búsqueda
    if (params.textoBusqueda != null && params.textoBusqueda!.length < 2) {
      return Result.failure(
        const ValidationFailure(
          message: 'El texto de búsqueda debe tener al menos 2 caracteres',
          code: 3024,
        ),
      );
    }

    return Result.success(true);
  }

  /// Ordenar lista de terapeutas según criterio
  static List<TerapeutaEntity> ordenarTerapeutas(
    List<TerapeutaEntity> terapeutas,
    CriterioOrdenTerapeutas criterio,
  ) {
    final terapeutasOrdenados = List<TerapeutaEntity>.from(terapeutas);

    switch (criterio) {
      case CriterioOrdenTerapeutas.nombre:
        // Nota: Aquí necesitaríamos acceso a los datos del usuario
        // Por ahora ordenamos por ID como fallback
        terapeutasOrdenados.sort((a, b) => a.id.compareTo(b.id));
        break;
      case CriterioOrdenTerapeutas.especializaciones:
        terapeutasOrdenados.sort((a, b) => 
          a.especializaciones.length.compareTo(b.especializaciones.length));
        break;
      case CriterioOrdenTerapeutas.disponibilidad:
        terapeutasOrdenados.sort((a, b) => 
          b.disponible.toString().compareTo(a.disponible.toString()));
        break;
      case CriterioOrdenTerapeutas.fechaCreacion:
        terapeutasOrdenados.sort((a, b) => 
          b.creadoEn.compareTo(a.creadoEn));
        break;
    }

    return terapeutasOrdenados;
  }
}

/// Parámetros para obtener terapeutas
class ObtenerTerapeutasParams extends Equatable {
  final bool disponibleSolo;
  final EspecializacionMasaje? especializacion;
  final List<EspecializacionMasaje>? especializaciones;
  final int limite;
  final int pagina;
  final String? textoBusqueda;
  final DateTime? fechaHoraDisponibilidad;
  final int? duracionMinutos;
  final CriterioOrdenTerapeutas? ordenarPor;

  const ObtenerTerapeutasParams({
    this.disponibleSolo = false,
    this.especializacion,
    this.especializaciones,
    this.limite = 50,
    this.pagina = 1,
    this.textoBusqueda,
    this.fechaHoraDisponibilidad,
    this.duracionMinutos,
    this.ordenarPor,
  });

  @override
  List<Object?> get props => [
    disponibleSolo,
    especializacion,
    especializaciones,
    limite,
    pagina,
    textoBusqueda,
    fechaHoraDisponibilidad,
    duracionMinutos,
    ordenarPor,
  ];
}

/// Criterios de ordenamiento para terapeutas
enum CriterioOrdenTerapeutas {
  nombre,
  especializaciones,
  disponibilidad,
  fechaCreacion,
}

/// Extensión para CriterioOrdenTerapeutas
extension CriterioOrdenTerapeutasExtension on CriterioOrdenTerapeutas {
  String get nombre {
    switch (this) {
      case CriterioOrdenTerapeutas.nombre:
        return 'Nombre';
      case CriterioOrdenTerapeutas.especializaciones:
        return 'Especializaciones';
      case CriterioOrdenTerapeutas.disponibilidad:
        return 'Disponibilidad';
      case CriterioOrdenTerapeutas.fechaCreacion:
        return 'Fecha de Creación';
    }
  }
} 