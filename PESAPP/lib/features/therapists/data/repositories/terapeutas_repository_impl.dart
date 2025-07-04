import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/entities/therapist_entity.dart';
import '../../domain/repositories/terapeutas_repository.dart';
import '../datasources/terapeutas_remote_datasource.dart';

/// Implementación del repositorio de terapeutas
class TerapeutasRepositoryImpl implements TerapeutasRepository {
  final TerapeutasRemoteDataSource _remoteDataSource;

  const TerapeutasRepositoryImpl({
    required TerapeutasRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<TerapeutaEntity>> crearTerapeuta({
    required String usuarioId,
    required String numeroLicencia,
    required List<EspecializacionMasaje> especializaciones,
    required HorariosTrabajo horariosTrabajo,
    bool disponible = true,
  }) async {
    try {
      final terapeutaModel = await _remoteDataSource.crearTerapeuta(
        usuarioId: usuarioId,
        numeroLicencia: numeroLicencia,
        especializaciones: especializaciones,
        horariosTrabajo: horariosTrabajo,
        disponible: disponible,
      );

      return Result.success(terapeutaModel);
    } on DatabaseException catch (e) {
      return Result.failure(_mapDatabaseException(e));
    } on NetworkException catch (e) {
      return Result.failure(_mapNetworkException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure(
          message: 'Error inesperado al crear terapeuta: \${e.toString()}',
          code: 5001,
        ),
      );
    }
  }

  @override
  Future<Result<TerapeutaEntity>> obtenerTerapeutaPorId(String terapeutaId) async {
    try {
      final terapeutaModel = await _remoteDataSource.obtenerTerapeutaPorId(terapeutaId);
      return Result.success(terapeutaModel);
    } on DatabaseException catch (e) {
      return Result.failure(_mapDatabaseException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure(
          message: 'Error inesperado al obtener terapeuta: \${e.toString()}',
          code: 5002,
        ),
      );
    }
  }

  @override
  Future<Result<TerapeutaEntity>> obtenerTerapeutaPorUsuarioId(String usuarioId) async {
    try {
      final terapeutaModel = await _remoteDataSource.obtenerTerapeutaPorUsuarioId(usuarioId);
      return Result.success(terapeutaModel);
    } on DatabaseException catch (e) {
      return Result.failure(_mapDatabaseException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure(
          message: 'Error inesperado al obtener terapeuta por usuario: \${e.toString()}',
          code: 5003,
        ),
      );
    }
  }

  @override
  Future<Result<List<TerapeutaEntity>>> obtenerTerapeutas({
    bool disponibleSolo = false,
    EspecializacionMasaje? especializacion,
    int limite = 50,
    int pagina = 1,
  }) async {
    try {
      final terapeutasModels = await _remoteDataSource.obtenerTerapeutas(
        disponibleSolo: disponibleSolo,
        especializacion: especializacion,
        limite: limite,
        pagina: pagina,
      );

      return Result.success(terapeutasModels.cast<TerapeutaEntity>());
    } on DatabaseException catch (e) {
      return Result.failure(_mapDatabaseException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure(
          message: 'Error inesperado al obtener terapeutas: \${e.toString()}',
          code: 5004,
        ),
      );
    }
  }

  @override
  Future<Result<List<TerapeutaEntity>>> obtenerTerapeutasDisponibles({
    required DateTime fechaHora,
    required int duracionMinutos,
    EspecializacionMasaje? especializacion,
  }) async {
    try {
      final terapeutasModels = await _remoteDataSource.obtenerTerapeutasDisponibles(
        fechaHora: fechaHora,
        duracionMinutos: duracionMinutos,
        especializacion: especializacion,
      );

      return Result.success(terapeutasModels.cast<TerapeutaEntity>());
    } on DatabaseException catch (e) {
      return Result.failure(_mapDatabaseException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure(
          message: 'Error inesperado al obtener terapeutas disponibles: \${e.toString()}',
          code: 5005,
        ),
      );
    }
  }

  @override
  Future<Result<TerapeutaEntity>> actualizarTerapeuta({
    required String terapeutaId,
    String? numeroLicencia,
    List<EspecializacionMasaje>? especializaciones,
    HorariosTrabajo? horariosTrabajo,
    bool? disponible,
  }) async {
    try {
      final terapeutaModel = await _remoteDataSource.actualizarTerapeuta(
        terapeutaId: terapeutaId,
        numeroLicencia: numeroLicencia,
        especializaciones: especializaciones,
        horariosTrabajo: horariosTrabajo,
        disponible: disponible,
      );

      return Result.success(terapeutaModel);
    } on DatabaseException catch (e) {
      return Result.failure(_mapDatabaseException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure(
          message: 'Error inesperado al actualizar terapeuta: \${e.toString()}',
          code: 5006,
        ),
      );
    }
  }

  @override
  Future<Result<TerapeutaEntity>> cambiarDisponibilidad({
    required String terapeutaId,
    required bool disponible,
  }) async {
    return await actualizarTerapeuta(
      terapeutaId: terapeutaId,
      disponible: disponible,
    );
  }

  @override
  Future<Result<TerapeutaEntity>> actualizarHorarios({
    required String terapeutaId,
    required HorariosTrabajo horariosTrabajo,
  }) async {
    return await actualizarTerapeuta(
      terapeutaId: terapeutaId,
      horariosTrabajo: horariosTrabajo,
    );
  }

  @override
  Future<Result<TerapeutaEntity>> agregarEspecializacion({
    required String terapeutaId,
    required EspecializacionMasaje especializacion,
  }) async {
    try {
      // Simplificación: por ahora solo retorna éxito
      // TODO: Implementar lógica completa
      return Result.failure(
        const ServerFailure(
          message: 'Funcionalidad en desarrollo',
          code: 5009,
        ),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure(
          message: 'Error inesperado: \${e.toString()}',
          code: 5010,
        ),
      );
    }
  }

  @override
  Future<Result<TerapeutaEntity>> eliminarEspecializacion({
    required String terapeutaId,
    required EspecializacionMasaje especializacion,
  }) async {
    try {
      // Simplificación: por ahora solo retorna éxito
      // TODO: Implementar lógica completa
      return Result.failure(
        const ServerFailure(
          message: 'Funcionalidad en desarrollo',
          code: 5011,
        ),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure(
          message: 'Error inesperado: \${e.toString()}',
          code: 5012,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> verificarDisponibilidad({
    required String terapeutaId,
    required DateTime fechaHora,
    required int duracionMinutos,
  }) async {
    try {
      final disponible = await _remoteDataSource.verificarDisponibilidad(
        terapeutaId: terapeutaId,
        fechaHora: fechaHora,
        duracionMinutos: duracionMinutos,
      );

      return Result.success(disponible);
    } on DatabaseException catch (e) {
      return Result.failure(_mapDatabaseException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure(
          message: 'Error inesperado al verificar disponibilidad: \${e.toString()}',
          code: 5014,
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> obtenerEstadisticasTerapeuta({
    required String terapeutaId,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
  }) async {
    try {
      final estadisticas = await _remoteDataSource.obtenerEstadisticasTerapeuta(
        terapeutaId: terapeutaId,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );

      return Result.success(estadisticas);
    } on DatabaseException catch (e) {
      return Result.failure(_mapDatabaseException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure(
          message: 'Error inesperado al obtener estadísticas: \${e.toString()}',
          code: 5015,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> eliminarTerapeuta(String terapeutaId) async {
    try {
      final resultado = await _remoteDataSource.eliminarTerapeuta(terapeutaId);
      return Result.success(resultado);
    } on DatabaseException catch (e) {
      return Result.failure(_mapDatabaseException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure(
          message: 'Error inesperado al eliminar terapeuta: \${e.toString()}',
          code: 5016,
        ),
      );
    }
  }

  @override
  Future<Result<List<TerapeutaEntity>>> buscarTerapeutas({
    required String textoBusqueda,
    bool disponibleSolo = false,
  }) async {
    try {
      final terapeutasModels = await _remoteDataSource.buscarTerapeutas(
        textoBusqueda: textoBusqueda,
        disponibleSolo: disponibleSolo,
      );

      return Result.success(terapeutasModels.cast<TerapeutaEntity>());
    } on DatabaseException catch (e) {
      return Result.failure(_mapDatabaseException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure(
          message: 'Error inesperado al buscar terapeutas: \${e.toString()}',
          code: 5017,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> verificarLicenciaExiste({
    required String numeroLicencia,
    String? terapeutaIdExcluir,
  }) async {
    try {
      final existe = await _remoteDataSource.verificarLicenciaExiste(
        numeroLicencia: numeroLicencia,
        terapeutaIdExcluir: terapeutaIdExcluir,
      );

      return Result.success(existe);
    } on DatabaseException catch (e) {
      return Result.failure(_mapDatabaseException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure(
          message: 'Error inesperado al verificar licencia: \${e.toString()}',
          code: 5018,
        ),
      );
    }
  }

  /// Mapea DatabaseException a Failure específico
  Failure _mapDatabaseException(DatabaseException exception) {
    switch (exception.code) {
      case 4001:
      case 4002:
      case 4014:
        return ValidationFailure(
          message: exception.message,
          code: exception.code,
        );
      case 4005:
      case 4008:
        return NotFoundFailure(
          message: exception.message,
          code: exception.code,
        );
      default:
        return DatabaseFailure(
          message: exception.message,
          code: exception.code,
        );
    }
  }

  /// Mapea NetworkException a NetworkFailure
  NetworkFailure _mapNetworkException(NetworkException exception) {
    return NetworkFailure(
      message: exception.message,
      code: exception.code,
    );
  }
}
