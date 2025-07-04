import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/entities/appointment_entity.dart';
import '../../../../shared/domain/entities/user_entity.dart';
import '../../domain/repositories/citas_repository.dart';
import '../datasources/citas_remote_datasource.dart';
import '../models/cita_model.dart';

/// Implementación del repositorio de citas
/// 
/// Esta clase actúa como adaptador entre la capa de dominio y la capa de datos:
/// - Convierte entidades del dominio a modelos de datos y viceversa
/// - Maneja excepciones y las convierte a Failures del dominio
/// - Implementa la lógica de retry y cache si es necesaria
/// - Centraliza todas las operaciones de datos para citas
class CitasRepositoryImpl implements CitasRepository {
  final CitasRemoteDataSource remoteDataSource;

  const CitasRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Result<CitaEntity>> crearCita({
    required String pacienteId,
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    required String tipoMasaje,
    int duracionMinutos = 60,
    String? notas,
  }) async {
    try {
      final citaModel = await remoteDataSource.crearCita(
        pacienteId: pacienteId,
        terapeutaId: terapeutaId,
        fechaCita: fechaCita,
        horaCita: horaCita,
        tipoMasaje: tipoMasaje,
        duracionMinutos: duracionMinutos,
        notas: notas,
      );

      return Result.success(citaModel);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } on ValidationException catch (e) {
      return Result.failure(_mapValidationException(e));
    } on NotFoundException catch (e) {
      return Result.failure(_mapNotFoundException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Future<Result<List<CitaEntity>>> obtenerCitasPorPaciente({
    required String pacienteId,
    EstadoCita? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limite = 50,
    int pagina = 1,
  }) async {
    try {
      final citasModels = await remoteDataSource.obtenerCitasPorPaciente(
        pacienteId: pacienteId,
        estado: estado,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
        limite: limite,
        pagina: pagina,
      );

      // CitaModel ya es una CitaEntity, no necesitamos casting
      return Result.success(citasModels);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } on ValidationException catch (e) {
      return Result.failure(_mapValidationException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Future<Result<List<CitaEntity>>> obtenerCitasPorTerapeuta({
    required String terapeutaId,
    EstadoCita? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limite = 50,
    int pagina = 1,
  }) async {
    try {
      final citasModels = await remoteDataSource.obtenerCitasPorTerapeuta(
        terapeutaId: terapeutaId,
        estado: estado,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
        limite: limite,
        pagina: pagina,
      );

      // CitaModel ya es una CitaEntity, no necesitamos casting
      return Result.success(citasModels);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } on ValidationException catch (e) {
      return Result.failure(_mapValidationException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Future<Result<List<CitaEntity>>> obtenerTodasLasCitas({
    EstadoCita? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    String? terapeutaId,
    int limite = 50,
    int pagina = 1,
  }) async {
    try {
      final citasModels = await remoteDataSource.obtenerTodasLasCitas(
        estado: estado,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
        terapeutaId: terapeutaId,
        limite: limite,
        pagina: pagina,
      );

      // CitaModel ya es una CitaEntity, no necesitamos casting
      return Result.success(citasModels);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } on ValidationException catch (e) {
      return Result.failure(_mapValidationException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Future<Result<CitaEntity>> obtenerCitaPorId(String citaId) async {
    try {
      final citaModel = await remoteDataSource.obtenerCitaPorId(citaId);
      return Result.success(citaModel);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } on NotFoundException catch (e) {
      return Result.failure(_mapNotFoundException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Future<Result<List<CitaEntity>>> obtenerCitasDeHoy({
    String? terapeutaId,
  }) async {
    try {
      final citasModels = await remoteDataSource.obtenerCitasDeHoy(
        terapeutaId: terapeutaId,
      );

      // CitaModel ya es una CitaEntity, no necesitamos casting
      return Result.success(citasModels);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Future<Result<List<CitaEntity>>> obtenerProximasCitas({
    String? pacienteId,
    String? terapeutaId,
  }) async {
    try {
      final citasModels = await remoteDataSource.obtenerProximasCitas(
        pacienteId: pacienteId,
        terapeutaId: terapeutaId,
      );

      // CitaModel ya es una CitaEntity, no necesitamos casting
      return Result.success(citasModels);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Future<Result<CitaEntity>> actualizarEstadoCita({
    required String citaId,
    required EstadoCita nuevoEstado,
    String? notas,
    required String usuarioId,
  }) async {
    try {
      final citaModel = await remoteDataSource.actualizarEstadoCita(
        citaId: citaId,
        nuevoEstado: nuevoEstado,
        notas: notas,
        usuarioId: usuarioId,
      );

      return Result.success(citaModel);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } on ValidationException catch (e) {
      return Result.failure(_mapValidationException(e));
    } on NotFoundException catch (e) {
      return Result.failure(_mapNotFoundException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Future<Result<CitaEntity>> cancelarCita({
    required String citaId,
    required String razonCancelacion,
    required String canceladoPor,
  }) async {
    try {
      final citaModel = await remoteDataSource.cancelarCita(
        citaId: citaId,
        razonCancelacion: razonCancelacion,
        canceladoPor: canceladoPor,
      );

      return Result.success(citaModel);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } on ValidationException catch (e) {
      return Result.failure(_mapValidationException(e));
    } on NotFoundException catch (e) {
      return Result.failure(_mapNotFoundException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Future<Result<CitaEntity>> reprogramarCita({
    required String citaId,
    required DateTime nuevaFechaCita,
    required DateTime nuevaHoraCita,
    required String terapeutaId,
    required String reprogramadoPor,
    String? razonReprogramacion,
  }) async {
    try {
      final citaModel = await remoteDataSource.reprogramarCita(
        citaId: citaId,
        nuevaFechaCita: nuevaFechaCita,
        nuevaHoraCita: nuevaHoraCita,
        terapeutaId: terapeutaId,
        reprogramadoPor: reprogramadoPor,
        razonReprogramacion: razonReprogramacion,
      );

      return Result.success(citaModel);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } on ValidationException catch (e) {
      return Result.failure(_mapValidationException(e));
    } on NotFoundException catch (e) {
      return Result.failure(_mapNotFoundException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Future<Result<bool>> verificarDisponibilidadTerapeuta({
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    required int duracionMinutos,
    String? citaIdExcluir,
  }) async {
    try {
      final disponible = await remoteDataSource.verificarDisponibilidadTerapeuta(
        terapeutaId: terapeutaId,
        fechaCita: fechaCita,
        horaCita: horaCita,
        duracionMinutos: duracionMinutos,
        citaIdExcluir: citaIdExcluir,
      );

      return Result.success(disponible);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Future<Result<List<CitaEntity>>> verificarConflictosHorario({
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    required int duracionMinutos,
    String? citaIdExcluir,
  }) async {
    try {
      final conflictosModels = await remoteDataSource.verificarConflictosHorario(
        terapeutaId: terapeutaId,
        fechaCita: fechaCita,
        horaCita: horaCita,
        duracionMinutos: duracionMinutos,
        citaIdExcluir: citaIdExcluir,
      );

      final conflictosEntities = conflictosModels.cast<CitaEntity>();
      return Result.success(conflictosEntities);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> obtenerEstadisticasCitas({
    required DateTime fechaDesde,
    required DateTime fechaHasta,
    String? terapeutaId,
  }) async {
    try {
      final estadisticas = await remoteDataSource.obtenerEstadisticasCitas(
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
        terapeutaId: terapeutaId,
      );

      return Result.success(estadisticas);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> obtenerHistorialCita(
    String citaId,
  ) async {
    try {
      final historial = await remoteDataSource.obtenerHistorialCita(citaId);
      return Result.success(historial);
    } on ServerException catch (e) {
      return Result.failure(_mapServerException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } on NotFoundException catch (e) {
      return Result.failure(_mapNotFoundException(e));
    } catch (e) {
      return Result.failure(_mapUnexpectedException(e));
    }
  }

  @override
  Stream<Result<List<CitaEntity>>> streamCitasUsuario({
    required String usuarioId,
    required RolUsuario rolUsuario,
  }) {
    try {
      return remoteDataSource
          .streamCitasUsuario(
            usuarioId: usuarioId,
            rolUsuario: rolUsuario,
          )
          .map((citasModels) {
            final citasEntities = citasModels.cast<CitaEntity>();
            return Result.success(citasEntities);
          })
          .handleError((error) {
            if (error is ServerException) {
              return Result.failure(_mapServerException(error));
            } else if (error is NetworkException) {
              return Result.failure(_mapNetworkException(error));
            } else {
              return Result.failure(_mapUnexpectedException(error));
            }
          });
    } catch (e) {
      return Stream.value(Result.failure(_mapUnexpectedException(e)));
    }
  }

  @override
  Stream<Result<List<CitaEntity>>> streamCitasDashboard({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) {
    try {
      return remoteDataSource
          .streamCitasDashboard(
            fechaDesde: fechaDesde,
            fechaHasta: fechaHasta,
          )
          .map((citasModels) {
            final citasEntities = citasModels.cast<CitaEntity>();
            return Result.success(citasEntities);
          })
          .handleError((error) {
            if (error is ServerException) {
              return Result.failure(_mapServerException(error));
            } else if (error is NetworkException) {
              return Result.failure(_mapNetworkException(error));
            } else {
              return Result.failure(_mapUnexpectedException(error));
            }
          });
    } catch (e) {
      return Stream.value(Result.failure(_mapUnexpectedException(e)));
    }
  }

  // === Métodos auxiliares para mapeo de excepciones ===

  /// Mapear ServerException a Failure del dominio
  Failure _mapServerException(ServerException exception) {
    return ServerFailure(
      message: exception.message,
      code: 500,
    );
  }

  /// Mapear NetworkException a Failure del dominio
  Failure _mapNetworkException(NetworkException exception) {
    return NetworkFailure(
      message: exception.message,
      code: 1000,
    );
  }

  /// Mapear ValidationException a Failure del dominio
  Failure _mapValidationException(ValidationException exception) {
    return ValidationFailure(
      message: exception.message,
      code: 400,
    );
  }

  /// Mapear NotFoundException a Failure del dominio
  Failure _mapNotFoundException(NotFoundException exception) {
    return DatabaseFailure(
      message: exception.message,
      code: 404,
    );
  }

  /// Mapear excepciones inesperadas a Failure del dominio
  Failure _mapUnexpectedException(dynamic exception) {
    return UnexpectedFailure(
      message: 'Error inesperado: ${exception.toString()}',
      code: 9999,
    );
  }
} 