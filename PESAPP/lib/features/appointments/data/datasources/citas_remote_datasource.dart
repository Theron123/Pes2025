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
    String? terapeutaId,
    int limite = 50,
    int pagina = 1,
  });

  /// Obtener cita por ID
  Future<CitaModel> obtenerCitaPorId(String citaId);

  /// Obtener citas de hoy
  Future<List<CitaModel>> obtenerCitasDeHoy({String? terapeutaId});

  /// Obtener próximas citas
  Future<List<CitaModel>> obtenerProximasCitas({
    String? pacienteId,
    String? terapeutaId,
  });

  /// Actualizar estado de cita
  Future<CitaModel> actualizarEstadoCita({
    required String citaId,
    required EstadoCita nuevoEstado,
    String? notas,
    required String usuarioId,
  });

  /// Cancelar cita
  Future<CitaModel> cancelarCita({
    required String citaId,
    required String razonCancelacion,
    required String canceladoPor,
  });

  /// Reprogramar cita
  Future<CitaModel> reprogramarCita({
    required String citaId,
    required DateTime nuevaFechaCita,
    required DateTime nuevaHoraCita,
    required String terapeutaId,
    required String reprogramadoPor,
    String? razonReprogramacion,
  });

  /// Verificar disponibilidad del terapeuta
  Future<bool> verificarDisponibilidadTerapeuta({
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    required int duracionMinutos,
    String? citaIdExcluir,
  });

  /// Verificar conflictos de horario
  Future<List<CitaModel>> verificarConflictosHorario({
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    required int duracionMinutos,
    String? citaIdExcluir,
  });

  /// Obtener estadísticas de citas
  Future<Map<String, dynamic>> obtenerEstadisticasCitas({
    required DateTime fechaDesde,
    required DateTime fechaHasta,
    String? terapeutaId,
  });

  /// Obtener historial de cambios de una cita
  Future<List<Map<String, dynamic>>> obtenerHistorialCita(String citaId);

  /// Stream de citas en tiempo real
  Stream<List<CitaModel>> streamCitasUsuario({
    required String usuarioId,
    required RolUsuario rolUsuario,
  });

  /// Stream de citas para dashboard
  Stream<List<CitaModel>> streamCitasDashboard({
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

      final response = await supabaseClient
          .from('citas')
          .insert(citaModel.toCreateJson())
          .select()
          .single();

      return CitaModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    } catch (e) {
      throw const ServerException(message: 'Error al crear la cita');
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
            terapeutas:therapist_id (
              *,
              usuarios:user_id (
                nombre,
                apellido,
                email
              )
            )
          ''')
          .eq('patient_id', pacienteId);

      // Aplicar filtros
      if (estado != null) {
        query = query.eq('status', estado.name);
      }

      if (fechaDesde != null) {
        query = query.gte('appointment_date', fechaDesde.toIso8601String().split('T')[0]);
      }

      if (fechaHasta != null) {
        query = query.lte('appointment_date', fechaHasta.toIso8601String().split('T')[0]);
      }

      // Aplicar paginación
      final offset = (pagina - 1) * limite;
      final response = await query
          .range(offset, offset + limite - 1)
          .order('appointment_date', ascending: false)
          .order('appointment_time', ascending: false);

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
            usuarios:patient_id (
              nombre,
              apellido,
              email,
              telefono
            )
          ''')
          .eq('therapist_id', terapeutaId);

      // Aplicar filtros
      if (estado != null) {
        query = query.eq('status', estado.name);
      }

      if (fechaDesde != null) {
        query = query.gte('appointment_date', fechaDesde.toIso8601String().split('T')[0]);
      }

      if (fechaHasta != null) {
        query = query.lte('appointment_date', fechaHasta.toIso8601String().split('T')[0]);
      }

      final offset = (pagina - 1) * limite;
      final response = await query
          .range(offset, offset + limite - 1)
          .order('appointment_date', ascending: true)
          .order('appointment_time', ascending: true);

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
    String? terapeutaId,
    int limite = 50,
    int pagina = 1,
  }) async {
    try {
      var query = supabaseClient
          .from('citas')
          .select('''
            *,
            usuarios:patient_id (
              nombre,
              apellido,
              email
            ),
            terapeutas:therapist_id (
              *,
              usuarios:user_id (
                nombre,
                apellido
              )
            )
          ''');

      // Aplicar todos los filtros
      if (estado != null) {
        query = query.eq('status', estado.name);
      }

      if (fechaDesde != null) {
        query = query.gte('appointment_date', fechaDesde.toIso8601String().split('T')[0]);
      }

      if (fechaHasta != null) {
        query = query.lte('appointment_date', fechaHasta.toIso8601String().split('T')[0]);
      }

      if (terapeutaId != null) {
        query = query.eq('therapist_id', terapeutaId);
      }

      final offset = (pagina - 1) * limite;
      final response = await query
          .range(offset, offset + limite - 1)
          .order('appointment_date', ascending: false)
          .order('appointment_time', ascending: false);

      return response.map((json) => CitaModel.fromJsonWithJoins(json)).toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
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
            usuarios:patient_id (
              nombre,
              apellido,
              email,
              telefono
            ),
            terapeutas:therapist_id (
              *,
              usuarios:user_id (
                nombre,
                apellido,
                email
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
  Future<List<CitaModel>> obtenerCitasDeHoy({String? terapeutaId}) async {
    try {
      final hoy = DateTime.now().toIso8601String().split('T')[0];
      
      var query = supabaseClient
          .from('citas')
          .select('''
            *,
            usuarios:patient_id (
              nombre,
              apellido,
              telefono
            ),
            terapeutas:therapist_id (
              *,
              usuarios:user_id (
                nombre,
                apellido
              )
            )
          ''')
          .eq('appointment_date', hoy);

      if (terapeutaId != null) {
        query = query.eq('therapist_id', terapeutaId);
      }

      final response = await query.order('appointment_time', ascending: true);

      return response.map((json) => CitaModel.fromJsonWithJoins(json)).toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    } catch (e) {
      throw const ServerException(message: 'Error al obtener las citas de hoy');
    }
  }

  @override
  Future<List<CitaModel>> obtenerProximasCitas({
    String? pacienteId,
    String? terapeutaId,
  }) async {
    try {
      final hoy = DateTime.now().toIso8601String().split('T')[0];
      final proximaSemana = DateTime.now().add(const Duration(days: 7))
          .toIso8601String().split('T')[0];

      var query = supabaseClient
          .from('citas')
          .select('''
            *,
            usuarios:patient_id (
              nombre,
              apellido,
              telefono
            ),
            terapeutas:therapist_id (
              *,
              usuarios:user_id (
                nombre,
                apellido
              )
            )
          ''')
          .gte('appointment_date', hoy)
          .lte('appointment_date', proximaSemana)
          .filter('status', 'in', '(pendiente,confirmada)');

      if (pacienteId != null) {
        query = query.eq('patient_id', pacienteId);
      }

      if (terapeutaId != null) {
        query = query.eq('therapist_id', terapeutaId);
      }

      final response = await query
          .order('appointment_date', ascending: true)
          .order('appointment_time', ascending: true);

      return response.map((json) => CitaModel.fromJsonWithJoins(json)).toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    } catch (e) {
      throw const ServerException(message: 'Error al obtener las próximas citas');
    }
  }

  @override
  Future<CitaModel> actualizarEstadoCita({
    required String citaId,
    required EstadoCita nuevoEstado,
    String? notas,
    required String usuarioId,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': nuevoEstado.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (notas != null) {
        updateData['notes'] = notas;
      }

      // Campos específicos para cancelación
      if (nuevoEstado == EstadoCita.cancelada) {
        updateData['canceled_at'] = DateTime.now().toIso8601String();
        updateData['canceled_by'] = usuarioId;
      }

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
      throw const ServerException(message: 'Error al actualizar el estado de la cita');
    }
  }

  @override
  Future<CitaModel> cancelarCita({
    required String citaId,
    required String razonCancelacion,
    required String canceladoPor,
  }) async {
    try {
      final response = await supabaseClient
          .from('citas')
          .update({
            'status': EstadoCita.cancelada.name,
            'canceled_at': DateTime.now().toIso8601String(),
            'canceled_by': canceladoPor,
            'cancellation_reason': razonCancelacion,
            'updated_at': DateTime.now().toIso8601String(),
          })
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
      throw const ServerException(message: 'Error al cancelar la cita');
    }
  }

  @override
  Future<CitaModel> reprogramarCita({
    required String citaId,
    required DateTime nuevaFechaCita,
    required DateTime nuevaHoraCita,
    required String terapeutaId,
    required String reprogramadoPor,
    String? razonReprogramacion,
  }) async {
    try {
      final response = await supabaseClient
          .from('citas')
          .update({
            'appointment_date': nuevaFechaCita.toIso8601String().split('T')[0],
            'appointment_time': _formatTimeToString(nuevaHoraCita),
            'therapist_id': terapeutaId,
            'status': EstadoCita.pendiente.name, // Vuelve a pendiente después de reprogramar
            'updated_at': DateTime.now().toIso8601String(),
            if (razonReprogramacion != null) 'notes': razonReprogramacion,
          })
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
      throw const ServerException(message: 'Error al reprogramar la cita');
    }
  }

  @override
  Future<bool> verificarDisponibilidadTerapeuta({
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    required int duracionMinutos,
    String? citaIdExcluir,
  }) async {
    try {
      final conflictos = await verificarConflictosHorario(
        terapeutaId: terapeutaId,
        fechaCita: fechaCita,
        horaCita: horaCita,
        duracionMinutos: duracionMinutos,
        citaIdExcluir: citaIdExcluir,
      );

      return conflictos.isEmpty;
    } catch (e) {
      throw const ServerException(message: 'Error al verificar disponibilidad');
    }
  }

  @override
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
          .eq('therapist_id', terapeutaId)
          .eq('appointment_date', fechaStr)
          .filter('status', 'in', '(pendiente,confirmada,enProgreso)');

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
  Future<Map<String, dynamic>> obtenerEstadisticasCitas({
    required DateTime fechaDesde,
    required DateTime fechaHasta,
    String? terapeutaId,
  }) async {
    try {
      var query = supabaseClient
          .from('citas')
          .select('status')
          .gte('appointment_date', fechaDesde.toIso8601String().split('T')[0])
          .lte('appointment_date', fechaHasta.toIso8601String().split('T')[0]);

      if (terapeutaId != null) {
        query = query.eq('therapist_id', terapeutaId);
      }

      final response = await query;

      // Calcular estadísticas
      final estadisticas = <String, int>{};
      for (final estado in EstadoCita.values) {
        estadisticas[estado.name] = 0;
      }

      for (final cita in response) {
        final estado = cita['status'] as String;
        estadisticas[estado] = (estadisticas[estado] ?? 0) + 1;
      }

      final total = response.length;
      
      return {
        'total': total,
        'por_estado': estadisticas,
        'tasa_completado': total > 0 
            ? (estadisticas['completada']! / total) 
            : 0.0,
        'tasa_cancelacion': total > 0 
            ? (estadisticas['cancelada']! / total) 
            : 0.0,
        'tasa_no_show': total > 0 
            ? (estadisticas['noShow']! / total) 
            : 0.0,
      };
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    } catch (e) {
      throw const ServerException(message: 'Error al obtener estadísticas');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> obtenerHistorialCita(String citaId) async {
    try {
      // Consultar tabla de auditoría para obtener historial de cambios
      final response = await supabaseClient
          .from('registros_auditoria')
          .select('''
            *,
            usuarios:user_id (nombre, apellido)
          ''')
          .eq('record_id', citaId)
          .eq('table_name', 'citas')
          .order('created_at', ascending: false);

      return response.map((json) => json).toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    } catch (e) {
      throw const ServerException(message: 'Error al obtener historial de la cita');
    }
  }

  @override
  Stream<List<CitaModel>> streamCitasUsuario({
    required String usuarioId,
    required RolUsuario rolUsuario,
  }) {
    try {
      String columnaFiltro;
      switch (rolUsuario) {
        case RolUsuario.paciente:
          columnaFiltro = 'patient_id';
          break;
        case RolUsuario.terapeuta:
          columnaFiltro = 'therapist_id';
          break;
        default:
          // Para admin y recepcionista, obtener todas las citas
          return supabaseClient
              .from('citas')
              .stream(primaryKey: ['id'])
              .order('appointment_date')
              .map((data) => data.map((json) => CitaModel.fromJson(json)).toList());
      }

      return supabaseClient
          .from('citas')
          .stream(primaryKey: ['id'])
          .eq(columnaFiltro, usuarioId)
          .order('appointment_date')
          .map((data) => data.map((json) => CitaModel.fromJson(json)).toList());
    } catch (e) {
      throw const ServerException(message: 'Error en stream de citas');
    }
  }

  @override
  Stream<List<CitaModel>> streamCitasDashboard({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) {
    try {
      return supabaseClient
          .from('citas')
          .stream(primaryKey: ['id'])
          .order('appointment_date')
          .map((data) {
            final citas = data.map((json) => CitaModel.fromJson(json)).toList();
            
            // Aplicar filtros de fecha en el lado del cliente
            if (fechaDesde != null || fechaHasta != null) {
              return citas.where((cita) {
                if (fechaDesde != null && cita.fechaCita.isBefore(fechaDesde)) {
                  return false;
                }
                if (fechaHasta != null && cita.fechaCita.isAfter(fechaHasta)) {
                  return false;
                }
                return true;
              }).toList();
            }
            
            return citas;
          });
    } catch (e) {
      throw const ServerException(message: 'Error en stream del dashboard');
    }
  }

  /// Formatear hora a string formato HH:MM:SS
  String _formatTimeToString(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  /// Mapear excepciones de Postgrest a excepciones específicas del dominio
  Exception _mapPostgrestException(PostgrestException e) {
    switch (e.code) {
      case '23505': // Violación de restricción única
        return const ValidationException(message: 'Ya existe una cita con esos datos');
      case '23503': // Violación de clave foránea
        return const ValidationException(message: 'Paciente o terapeuta no válido');
      case '23514': // Violación de restricción de verificación
        return const ValidationException(message: 'Datos de cita no válidos');
      case 'PGRST116': // No se encontró el registro
        return const NotFoundException(message: 'Cita no encontrada');
      default:
        return ServerException(message: e.message);
    }
  }
} 