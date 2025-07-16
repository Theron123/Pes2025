import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/domain/entities/therapist_entity.dart';
import '../models/terapeuta_model.dart';

/// Data source remoto para operaciones de terapeutas con Supabase
abstract class TerapeutasRemoteDataSource {
  Future<TerapeutaModel> crearTerapeuta({
    required String usuarioId,
    required String numeroLicencia,
    required List<EspecializacionMasaje> especializaciones,
    required HorariosTrabajo horariosTrabajo,
    bool disponible = true,
  });

  Future<TerapeutaModel> obtenerTerapeutaPorId(String terapeutaId);
  Future<TerapeutaModel> obtenerTerapeutaPorUsuarioId(String usuarioId);
  
  Future<List<TerapeutaModel>> obtenerTerapeutas({
    bool disponibleSolo = false,
    EspecializacionMasaje? especializacion,
    int limite = 50,
    int pagina = 1,
  });

  Future<TerapeutaModel> actualizarTerapeuta({
    required String terapeutaId,
    String? numeroLicencia,
    List<EspecializacionMasaje>? especializaciones,
    HorariosTrabajo? horariosTrabajo,
    bool? disponible,
  });

  Future<bool> verificarDisponibilidad({
    required String terapeutaId,
    required DateTime fechaHora,
    required int duracionMinutos,
  });

  Future<bool> verificarLicenciaExiste({
    required String numeroLicencia,
    String? terapeutaIdExcluir,
  });

  Future<List<TerapeutaModel>> obtenerTerapeutasDisponibles({
    required DateTime fechaHora,
    required int duracionMinutos,
    EspecializacionMasaje? especializacion,
  });

  Future<Map<String, dynamic>> obtenerEstadisticasTerapeuta({
    required String terapeutaId,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
  });

  Future<bool> eliminarTerapeuta(String terapeutaId);

  Future<List<TerapeutaModel>> buscarTerapeutas({
    required String textoBusqueda,
    bool disponibleSolo = false,
  });
}

/// Implementación concreta del data source remoto para terapeutas
class TerapeutasRemoteDataSourceImpl implements TerapeutasRemoteDataSource {
  final SupabaseClient _supabaseClient;

  const TerapeutasRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<TerapeutaModel> crearTerapeuta({
    required String usuarioId,
    required String numeroLicencia,
    required List<EspecializacionMasaje> especializaciones,
    required HorariosTrabajo horariosTrabajo,
    bool disponible = true,
  }) async {
    try {
      final datosCreacion = {
        'usuario_id': usuarioId,
        'numero_licencia': numeroLicencia,
        'especializaciones': especializaciones.map((e) => e.name).toList(),
        'horario_trabajo': {},
        'disponible': disponible,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseClient
          .from('terapeutas')
          .insert(datosCreacion)
          .select()
          .single();

      return TerapeutaModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Error al crear terapeuta: ${e.message}',
        code: 4003,
      );
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Error inesperado al crear terapeuta: ${e.toString()}',
        code: 4004,
      );
    }
  }

  @override
  Future<TerapeutaModel> obtenerTerapeutaPorId(String terapeutaId) async {
    try {
      final response = await _supabaseClient
          .from('terapeutas')
          .select('*')
          .eq('id', terapeutaId)
          .single();

      return TerapeutaModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Error al obtener terapeuta: ${e.message}',
        code: 4006,
      );
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Error inesperado al obtener terapeuta: ${e.toString()}',
        code: 4007,
      );
    }
  }

  @override
  Future<TerapeutaModel> obtenerTerapeutaPorUsuarioId(String usuarioId) async {
    try {
      final response = await _supabaseClient
          .from('terapeutas')
          .select('*')
          .eq('usuario_id', usuarioId)
          .single();

      return TerapeutaModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Error al obtener terapeuta por usuario: ${e.message}',
        code: 4009,
      );
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Error inesperado al obtener terapeuta por usuario: ${e.toString()}',
        code: 4010,
      );
    }
  }

  @override
  Future<List<TerapeutaModel>> obtenerTerapeutas({
    bool disponibleSolo = false,
    EspecializacionMasaje? especializacion,
    int limite = 50,
    int pagina = 1,
  }) async {
    try {
      print('DEBUG TerapeutasRemoteDataSource: Obteniendo terapeutas');
      print('  - Disponible solo: $disponibleSolo');
      print('  - Especialización: $especializacion');
      print('  - Límite: $limite');
      print('  - Página: $pagina');
      
      final offset = (pagina - 1) * limite;

      var query = _supabaseClient
          .from('terapeutas')
          .select('*');

      if (disponibleSolo) {
        query = query.eq('disponible', true);
      }

      final response = await query
          .range(offset, offset + limite - 1)
          .order('created_at', ascending: false);

      print('DEBUG: Respuesta de Supabase para terapeutas:');
      print('  - Número de registros: ${response.length}');
      print('  - Datos: $response');

      final terapeutas = response
          .map<TerapeutaModel>((json) => TerapeutaModel.fromJson(json))
          .toList();
          
      print('DEBUG: Terapeutas procesados: ${terapeutas.length}');
      for (final terapeuta in terapeutas) {
        print('  - ID: ${terapeuta.id}, Disponible: ${terapeuta.disponible}');
      }

      return terapeutas;
    } on PostgrestException catch (e) {
      print('DEBUG: PostgrestException en obtenerTerapeutas: ${e.message}');
      throw DatabaseException(
        message: 'Error al obtener terapeutas: ${e.message}',
        code: 4011,
      );
    } catch (e) {
      print('DEBUG: Error general en obtenerTerapeutas: $e');
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Error inesperado al obtener terapeutas: ${e.toString()}',
        code: 4012,
      );
    }
  }

  @override
  Future<TerapeutaModel> actualizarTerapeuta({
    required String terapeutaId,
    String? numeroLicencia,
    List<EspecializacionMasaje>? especializaciones,
    HorariosTrabajo? horariosTrabajo,
    bool? disponible,
  }) async {
    try {
      final datosActualizacion = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (numeroLicencia != null) {
        datosActualizacion['numero_licencia'] = numeroLicencia;
      }

      if (especializaciones != null) {
        datosActualizacion['especializaciones'] = 
            especializaciones.map((e) => e.name).toList();
      }

      if (disponible != null) {
        datosActualizacion['disponible'] = disponible;
      }

      final response = await _supabaseClient
          .from('terapeutas')
          .update(datosActualizacion)
          .eq('id', terapeutaId)
          .select()
          .single();

      return TerapeutaModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Error al actualizar terapeuta: ${e.message}',
        code: 4015,
      );
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Error inesperado al actualizar terapeuta: ${e.toString()}',
        code: 4016,
      );
    }
  }

  @override
  Future<bool> verificarDisponibilidad({
    required String terapeutaId,
    required DateTime fechaHora,
    required int duracionMinutos,
  }) async {
    try {
      // Implementación básica: asumir disponible si no hay errores
      return true;
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Error al verificar disponibilidad: ${e.message}',
        code: 4017,
      );
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Error inesperado al verificar disponibilidad: ${e.toString()}',
        code: 4018,
      );
    }
  }

  @override
  Future<bool> verificarLicenciaExiste({
    required String numeroLicencia,
    String? terapeutaIdExcluir,
  }) async {
    try {
      var query = _supabaseClient
          .from('terapeutas')
          .select('id')
          .eq('numero_licencia', numeroLicencia);

      if (terapeutaIdExcluir != null) {
        query = query.neq('id', terapeutaIdExcluir);
      }

      final response = await query;
      return response.isNotEmpty;
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Error al verificar licencia: ${e.message}',
        code: 4025,
      );
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Error inesperado al verificar licencia: ${e.toString()}',
        code: 4026,
      );
    }
  }

  @override
  Future<List<TerapeutaModel>> obtenerTerapeutasDisponibles({
    required DateTime fechaHora,
    required int duracionMinutos,
    EspecializacionMasaje? especializacion,
  }) async {
    // Implementación simplificada
    return await obtenerTerapeutas(disponibleSolo: true, especializacion: especializacion);
  }

  @override
  Future<Map<String, dynamic>> obtenerEstadisticasTerapeuta({
    required String terapeutaId,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
  }) async {
    // Implementación básica
    return {
      'total_citas': 0,
      'citas_completadas': 0,
      'citas_canceladas': 0,
    };
  }

  @override
  Future<bool> eliminarTerapeuta(String terapeutaId) async {
    try {
      await _supabaseClient
          .from('terapeutas')
          .update({'disponible': false})
          .eq('id', terapeutaId);

      return true;
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Error al eliminar terapeuta: ${e.message}',
        code: 4021,
      );
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Error inesperado al eliminar terapeuta: ${e.toString()}',
        code: 4022,
      );
    }
  }

  @override
  Future<List<TerapeutaModel>> buscarTerapeutas({
    required String textoBusqueda,
    bool disponibleSolo = false,
  }) async {
    // Implementación simplificada
    return await obtenerTerapeutas(disponibleSolo: disponibleSolo);
  }
}
