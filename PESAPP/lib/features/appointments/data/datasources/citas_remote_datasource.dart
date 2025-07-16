import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/domain/entities/appointment_entity.dart';
import '../../../../shared/domain/entities/user_entity.dart';
import '../models/cita_model.dart';

/// Fuente de datos remota para citas usando Supabase
/// 
/// Esta clase maneja todas las operaciones de base de datos para las citas:
/// - CRUD operations (crear, leer, actualizar, eliminar)
/// - Queries complejas con joins
/// - Verificación de disponibilidad y conflictos
/// - Streams en tiempo real
/// - Manejo de errores específicos de Supabase
abstract class CitasRemoteDataSource {
  /// Crear una nueva cita
  Future<CitaModel> crearCita({
    required String pacienteId,
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    required String tipoMasaje,
    int duracionMinutos = 60,
    String? notas,
  });

  /// Obtener citas por paciente
  Future<List<CitaModel>> obtenerCitasPorPaciente({
    required String pacienteId,
    EstadoCita? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limite = 50,
    int pagina = 1,
  });

  /// Obtener citas por terapeuta
  Future<List<CitaModel>> obtenerCitasPorTerapeuta({
    required String terapeutaId,
    EstadoCita? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limite = 50,
    int pagina = 1,
  });

  /// Obtener todas las citas (administradores)
  Future<List<CitaModel>> obtenerTodasLasCitas({
    EstadoCita? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limite = 50,
    int pagina = 1,
  });

  /// Obtener cita por ID
  Future<CitaModel> obtenerCitaPorId(String citaId);

  /// Actualizar cita existente
  Future<CitaModel> actualizarCita({
    required String citaId,
    String? terapeutaId,
    DateTime? fechaCita,
    DateTime? horaCita,
    String? tipoMasaje,
    int? duracionMinutos,
    EstadoCita? estado,
    String? notas,
  });

  /// Eliminar cita
  Future<void> eliminarCita(String citaId);

  /// Verificar disponibilidad de terapeuta
  Future<bool> verificarDisponibilidad({
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    int duracionMinutos = 60,
    String? citaExcluidaId,
  });

  /// Obtener citas de terapeuta para un día específico
  Future<List<CitaModel>> obtenerCitasTerapeuta({
    required String terapeutaId,
    required DateTime fecha,
  });

  /// Stream para escuchar cambios en tiempo real
  Stream<List<CitaModel>> escucharCitasPorPaciente({
    required String pacienteId,
    EstadoCita? estado,
  });

  /// Stream para escuchar cambios en citas de terapeuta
  Stream<List<CitaModel>> escucharCitasPorTerapeuta({
    required String terapeutaId,
    EstadoCita? estado,
  });

  /// Obtener estadísticas de citas
  Future<Map<String, dynamic>> obtenerEstadisticasCitas({
    String? terapeutaId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });
}

/// Implementación de CitasRemoteDataSource usando Supabase
class CitasRemoteDataSourceImpl implements CitasRemoteDataSource {
  final SupabaseClient supabaseClient;

  const CitasRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<CitaModel> crearCita({
    required String pacienteId,
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    required String tipoMasaje,
    int duracionMinutos = 60,
    String? notas,
  }) async {
    try {
      print('DEBUG CitasRemoteDataSource: Iniciando creación de cita');
      print('  - Paciente ID: $pacienteId');
      print('  - Terapeuta ID: $terapeutaId');
      print('  - Fecha: $fechaCita');
      print('  - Hora: $horaCita');
      print('  - Tipo: $tipoMasaje');
      print('  - Duración: $duracionMinutos minutos');
      print('  - Notas: $notas');

      final ahora = DateTime.now();
      final citaModel = CitaModel(
        id: '', // Se generará automáticamente
        pacienteId: pacienteId,
        terapeutaId: terapeutaId,
        fechaCita: fechaCita,
        horaCita: horaCita,
        duracionMinutos: duracionMinutos,
        tipoMasaje: tipoMasaje,
        estado: EstadoCita.pendiente,
        notas: notas,
        creadoEn: ahora,
        actualizadoEn: ahora,
      );

      final jsonData = citaModel.toCreateJson();
      print('DEBUG: JSON a enviar a Supabase:');
      print(jsonData);

      final response = await supabaseClient
          .from('citas')
          .insert(jsonData)
          .select()
          .single();

      print('DEBUG: Respuesta de Supabase:');
      print(response);

      final citaCreada = CitaModel.fromJson(response);
      print('DEBUG: Cita creada exitosamente con ID: ${citaCreada.id}');
      
      return citaCreada;
    } on PostgrestException catch (e) {
      print('DEBUG: PostgrestException - Código: ${e.code}, Mensaje: ${e.message}');
      print('DEBUG: Detalles: ${e.details}');
      throw _mapPostgrestException(e);
    } catch (e) {
      print('DEBUG: Error general al crear cita: $e');
      print('DEBUG: Tipo de error: ${e.runtimeType}');
      throw ServerException(message: 'Error al crear la cita: $e');
    }
  }

  @override
  Future<List<CitaModel>> obtenerCitasPorPaciente({
    required String pacienteId,
    EstadoCita? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limite = 50,
    int pagina = 1,
  }) async {
    try {
      var query = supabaseClient
          .from('citas')
          .select('''
            *,
            terapeutas:terapeuta_id (
              *,
              usuarios:usuario_id (
                nombre,
                apellido,
                email
              )
            )
          ''')
          .eq('paciente_id', pacienteId);

      // Aplicar filtros
      if (estado != null) {
        query = query.eq('estado', estado.name);
      }

      if (fechaDesde != null) {
        query = query.gte('fecha_cita', fechaDesde.toIso8601String().split('T')[0]);
      }

      if (fechaHasta != null) {
        query = query.lte('fecha_cita', fechaHasta.toIso8601String().split('T')[0]);
      }

      // Aplicar paginación
      final offset = (pagina - 1) * limite;
      final response = await query
          .range(offset, offset + limite - 1)
          .order('fecha_cita', ascending: false)
          .order('hora_cita', ascending: false);

      return response.map((json) => CitaModel.fromJsonWithJoins(json)).toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    } catch (e) {
      throw const ServerException(message: 'Error al obtener las citas del paciente');
    }
  }

  @override
  Future<List<CitaModel>> obtenerCitasPorTerapeuta({
    required String terapeutaId,
    EstadoCita? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limite = 50,
    int pagina = 1,
  }) async {
    try {
      var query = supabaseClient
          .from('citas')
          .select('''
            *,
            usuarios:paciente_id (
              nombre,
              apellido,
              email,
              telefono
            )
          ''')
          .eq('terapeuta_id', terapeutaId);

      // Aplicar filtros
      if (estado != null) {
        query = query.eq('estado', estado.name);
      }

      if (fechaDesde != null) {
        query = query.gte('fecha_cita', fechaDesde.toIso8601String().split('T')[0]);
      }

      if (fechaHasta != null) {
        query = query.lte('fecha_cita', fechaHasta.toIso8601String().split('T')[0]);
      }

      final offset = (pagina - 1) * limite;
      final response = await query
          .range(offset, offset + limite - 1)
          .order('fecha_cita', ascending: true)
          .order('hora_cita', ascending: true);

      return response.map((json) => CitaModel.fromJsonWithJoins(json)).toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    } catch (e) {
      throw const ServerException(message: 'Error al obtener las citas del terapeuta');
    }
  }

  @override
  Future<List<CitaModel>> obtenerTodasLasCitas({
    EstadoCita? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limite = 50,
    int pagina = 1,
  }) async {
    try {
      var query = supabaseClient
          .from('citas')
          .select('''
            *,
            usuarios:paciente_id (
              nombre,
              apellido,
              email
            ),
            terapeutas:terapeuta_id (
              *,
              usuarios:usuario_id (
                nombre,
                apellido
              )
            )
          ''');

      // Aplicar todos los filtros
      if (estado != null) {
        query = query.eq('estado', estado.name);
      }

      if (fechaDesde != null) {
        query = query.gte('fecha_cita', fechaDesde.toIso8601String().split('T')[0]);
      }

      if (fechaHasta != null) {
        query = query.lte('fecha_cita', fechaHasta.toIso8601String().split('T')[0]);
      }

      final offset = (pagina - 1) * limite;
      final response = await query
          .range(offset, offset + limite - 1)
          .order('fecha_cita', ascending: false)
          .order('hora_cita', ascending: false);

      return response.map((json) => CitaModel.fromJsonWithJoins(json)).toList();
    } catch (e) {
      throw const ServerException(message: 'Error al obtener todas las citas');
    }
  }

  @override
  Future<CitaModel> obtenerCitaPorId(String citaId) async {
    try {
      final response = await supabaseClient
          .from('citas')
          .select('''
            *,
            usuarios:paciente_id (
              nombre,
              apellido,
              email
            ),
            terapeutas:terapeuta_id (
              *,
              usuarios:usuario_id (
                nombre,
                apellido
              )
            )
          ''')
          .eq('id', citaId)
          .single();

      return CitaModel.fromJsonWithJoins(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException(message: 'Cita no encontrada');
      }
      throw _mapPostgrestException(e);
    } catch (e) {
      throw const ServerException(message: 'Error al obtener la cita');
    }
  }

  @override
  Future<CitaModel> actualizarCita({
    required String citaId,
    String? terapeutaId,
    DateTime? fechaCita,
    DateTime? horaCita,
    String? tipoMasaje,
    int? duracionMinutos,
    EstadoCita? estado,
    String? notas,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (terapeutaId != null) {
        updateData['terapeuta_id'] = terapeutaId;
      }
      if (fechaCita != null) {
        updateData['fecha_cita'] = fechaCita.toIso8601String().split('T')[0];
      }
      if (horaCita != null) {
        updateData['hora_cita'] = _formatTimeToString(horaCita);
      }
      if (tipoMasaje != null) {
        updateData['tipo_masaje'] = tipoMasaje;
      }
      if (duracionMinutos != null) {
        updateData['duracion_minutos'] = duracionMinutos;
      }
      if (estado != null) {
        updateData['estado'] = estado.name;
      }
      if (notas != null) {
        updateData['notas'] = notas;
      }
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabaseClient
          .from('citas')
          .update(updateData)
          .eq('id', citaId)
          .select()
          .single();

      return CitaModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException(message: 'Cita no encontrada');
      }
      throw _mapPostgrestException(e);
    } catch (e) {
      throw const ServerException(message: 'Error al actualizar la cita');
    }
  }

  @override
  Future<void> eliminarCita(String citaId) async {
    try {
      await supabaseClient
          .from('citas')
          .delete()
          .eq('id', citaId);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException(message: 'Cita no encontrada');
      }
      throw _mapPostgrestException(e);
    } catch (e) {
      throw const ServerException(message: 'Error al eliminar la cita');
    }
  }

  @override
  Future<bool> verificarDisponibilidad({
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    int duracionMinutos = 60,
    String? citaExcluidaId,
  }) async {
    try {
      final conflictos = await verificarConflictosHorario(
        terapeutaId: terapeutaId,
        fechaCita: fechaCita,
        horaCita: horaCita,
        duracionMinutos: duracionMinutos,
        citaIdExcluir: citaExcluidaId,
      );

      return conflictos.isEmpty;
    } catch (e) {
      throw const ServerException(message: 'Error al verificar disponibilidad');
    }
  }

  /// Verificar conflictos de horario
  Future<List<CitaModel>> verificarConflictosHorario({
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    required int duracionMinutos,
    String? citaIdExcluir,
  }) async {
    try {
      final fechaStr = fechaCita.toIso8601String().split('T')[0];

      var query = supabaseClient
          .from('citas')
          .select()
          .eq('terapeuta_id', terapeutaId)
          .eq('fecha_cita', fechaStr)
          .filter('estado', 'in', '(pendiente,confirmada,en_progreso)');

      if (citaIdExcluir != null) {
        query = query.neq('id', citaIdExcluir);
      }

      final response = await query;

      // Filtrar conflictos de horario en el lado del cliente
      final citasDelDia = response.map((json) => CitaModel.fromJson(json)).toList();
      
      final conflictos = <CitaModel>[];
      for (final cita in citasDelDia) {
        final citaInicio = cita.horaCita;
        final citaFin = cita.horaCita.add(Duration(minutes: cita.duracionMinutos));

        // Verificar si hay solapamiento
        if (horaCita.isBefore(citaFin) && 
            horaCita.add(Duration(minutes: duracionMinutos)).isAfter(citaInicio)) {
          conflictos.add(cita);
        }
      }

      return conflictos;
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    } catch (e) {
      throw const ServerException(message: 'Error al verificar conflictos de horario');
    }
  }

  @override
  Future<List<CitaModel>> obtenerCitasTerapeuta({
    required String terapeutaId,
    required DateTime fecha,
  }) async {
    try {
      final fechaStr = fecha.toIso8601String().split('T')[0];

      var query = supabaseClient
          .from('citas')
          .select('''
            *,
            usuarios:paciente_id (
              nombre,
              apellido,
              telefono
            ),
            terapeutas:terapeuta_id (
              *,
              usuarios:usuario_id (
                nombre,
                apellido
              )
            )
          ''')
          .eq('terapeuta_id', terapeutaId)
          .eq('fecha_cita', fechaStr)
          .filter('estado', 'in', '(pendiente,confirmada,en_progreso)');

      final response = await query;

      return response.map((json) => CitaModel.fromJsonWithJoins(json)).toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    } catch (e) {
      throw const ServerException(message: 'Error al obtener citas del terapeuta por fecha');
    }
  }

  @override
  Stream<List<CitaModel>> escucharCitasPorPaciente({
    required String pacienteId,
    EstadoCita? estado,
  }) {
    try {
      return supabaseClient
          .from('citas')
          .stream(primaryKey: ['id'])
          .eq('paciente_id', pacienteId)
          .order('fecha_cita')
          .map((data) => data.map((json) => CitaModel.fromJson(json)).toList());
    } catch (e) {
      throw const ServerException(message: 'Error en stream de citas por paciente');
    }
  }

  @override
  Stream<List<CitaModel>> escucharCitasPorTerapeuta({
    required String terapeutaId,
    EstadoCita? estado,
  }) {
    try {
      return supabaseClient
          .from('citas')
          .stream(primaryKey: ['id'])
          .eq('terapeuta_id', terapeutaId)
          .order('fecha_cita')
          .map((data) => data.map((json) => CitaModel.fromJson(json)).toList());
    } catch (e) {
      throw const ServerException(message: 'Error en stream de citas por terapeuta');
    }
  }

  @override
  Future<Map<String, dynamic>> obtenerEstadisticasCitas({
    String? terapeutaId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      var query = supabaseClient
          .from('citas')
          .select('estado')
          .gte('fecha_cita', fechaDesde?.toIso8601String().split('T')[0] ?? '2000-01-01')
          .lte('fecha_cita', fechaHasta?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0]);

      if (terapeutaId != null) {
        query = query.eq('terapeuta_id', terapeutaId);
      }

      final response = await query;

      // Contar por estado
      final estadisticas = <String, int>{};
      for (final cita in response) {
        final estado = cita['estado'] as String;
        estadisticas[estado] = (estadisticas[estado] ?? 0) + 1;
      }

      return {
        'total': response.length,
        'por_estado': estadisticas,
        'fecha_consulta': DateTime.now().toIso8601String(),
      };
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    } catch (e) {
      throw const ServerException(message: 'Error al obtener estadísticas de citas');
    }
  }

  /// Mapea excepciones de PostgrestException a excepciones de dominio
  Exception _mapPostgrestException(PostgrestException e) {
    switch (e.code) {
      case '23503':
        return const ServerException(message: 'Referencia no válida. Verifica que el paciente y terapeuta existan.');
      case '23505':
        return const ServerException(message: 'Ya existe una cita en este horario para el terapeuta.');
      case '42P01':
        return const ServerException(message: 'Error de configuración de base de datos.');
      case 'PGRST116':
        return const NotFoundException(message: 'Registro no encontrado.');
      default:
        return ServerException(message: 'Error del servidor: ${e.message}');
    }
  }

  /// Convierte DateTime a string de tiempo para base de datos
  String _formatTimeToString(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }
} 