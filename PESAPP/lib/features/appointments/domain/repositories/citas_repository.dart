import '../../../../shared/domain/entities/appointment_entity.dart';
import '../../../../shared/domain/entities/therapist_entity.dart';
import '../../../../shared/domain/entities/user_entity.dart';
import '../../../../core/usecases/usecase.dart';

/// Repositorio abstracto para gestión de citas en el sistema hospitalario
abstract class CitasRepository {
  /// Crear una nueva cita
  /// 
  /// [pacienteId] ID del paciente que solicita la cita
  /// [terapeutaId] ID del terapeuta asignado
  /// [fechaCita] Fecha de la cita
  /// [horaCita] Hora específica de la cita
  /// [tipoMasaje] Tipo de masaje solicitado
  /// [duracionMinutos] Duración en minutos (por defecto 60)
  /// [notas] Notas adicionales opcionales
  /// 
  /// Retorna [Result<CitaEntity>] con la cita creada o el error
  Future<Result<CitaEntity>> crearCita({
    required String pacienteId,
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    required String tipoMasaje,
    int duracionMinutos = 60,
    String? notas,
  });

  /// Obtener citas por paciente
  /// 
  /// [pacienteId] ID del paciente
  /// [estado] Filtro opcional por estado de cita
  /// [fechaDesde] Fecha inicial para filtro (opcional)
  /// [fechaHasta] Fecha final para filtro (opcional)
  /// [limite] Número máximo de citas a obtener
  /// [pagina] Página para paginación
  /// 
  /// Retorna [Result<List<CitaEntity>>] con las citas encontradas
  Future<Result<List<CitaEntity>>> obtenerCitasPorPaciente({
    required String pacienteId,
    EstadoCita? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limite = 50,
    int pagina = 1,
  });

  /// Obtener citas por terapeuta
  /// 
  /// [terapeutaId] ID del terapeuta
  /// [estado] Filtro opcional por estado de cita
  /// [fechaDesde] Fecha inicial para filtro (opcional)
  /// [fechaHasta] Fecha final para filtro (opcional)
  /// [limite] Número máximo de citas a obtener
  /// [pagina] Página para paginación
  /// 
  /// Retorna [Result<List<CitaEntity>>] con las citas encontradas
  Future<Result<List<CitaEntity>>> obtenerCitasPorTerapeuta({
    required String terapeutaId,
    EstadoCita? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limite = 50,
    int pagina = 1,
  });

  /// Obtener todas las citas (solo para administradores)
  /// 
  /// [estado] Filtro opcional por estado de cita
  /// [fechaDesde] Fecha inicial para filtro (opcional)
  /// [fechaHasta] Fecha final para filtro (opcional)
  /// [terapeutaId] Filtro opcional por terapeuta
  /// [limite] Número máximo de citas a obtener
  /// [pagina] Página para paginación
  /// 
  /// Retorna [Result<List<CitaEntity>>] con todas las citas
  Future<Result<List<CitaEntity>>> obtenerTodasLasCitas({
    EstadoCita? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    String? terapeutaId,
    int limite = 50,
    int pagina = 1,
  });

  /// Obtener cita por ID
  /// 
  /// [citaId] ID único de la cita
  /// 
  /// Retorna [Result<CitaEntity>] con la cita encontrada
  Future<Result<CitaEntity>> obtenerCitaPorId(String citaId);

  /// Obtener citas de hoy
  /// 
  /// [terapeutaId] ID del terapeuta (opcional, para filtrar)
  /// 
  /// Retorna [Result<List<CitaEntity>>] con las citas de hoy
  Future<Result<List<CitaEntity>>> obtenerCitasDeHoy({
    String? terapeutaId,
  });

  /// Obtener próximas citas (siguientes 7 días)
  /// 
  /// [pacienteId] ID del paciente (opcional, para filtrar)
  /// [terapeutaId] ID del terapeuta (opcional, para filtrar)
  /// 
  /// Retorna [Result<List<CitaEntity>>] con las próximas citas
  Future<Result<List<CitaEntity>>> obtenerProximasCitas({
    String? pacienteId,
    String? terapeutaId,
  });

  /// Actualizar estado de una cita
  /// 
  /// [citaId] ID de la cita a actualizar
  /// [nuevoEstado] Nuevo estado de la cita
  /// [notas] Notas adicionales opcionales
  /// [usuarioId] ID del usuario que realiza la actualización
  /// 
  /// Retorna [Result<CitaEntity>] con la cita actualizada
  Future<Result<CitaEntity>> actualizarEstadoCita({
    required String citaId,
    required EstadoCita nuevoEstado,
    String? notas,
    required String usuarioId,
  });

  /// Cancelar una cita
  /// 
  /// [citaId] ID de la cita a cancelar
  /// [razonCancelacion] Razón de la cancelación
  /// [canceladoPor] ID del usuario que cancela
  /// 
  /// Retorna [Result<CitaEntity>] con la cita cancelada
  Future<Result<CitaEntity>> cancelarCita({
    required String citaId,
    required String razonCancelacion,
    required String canceladoPor,
  });

  /// Reprogramar una cita
  /// 
  /// [citaId] ID de la cita a reprogramar
  /// [nuevaFechaCita] Nueva fecha de la cita
  /// [nuevaHoraCita] Nueva hora de la cita
  /// [terapeutaId] ID del terapeuta (puede cambiar)
  /// [reprogramadoPor] ID del usuario que reprograma
  /// [razonReprogramacion] Razón de la reprogramación
  /// 
  /// Retorna [Result<CitaEntity>] con la cita reprogramada
  Future<Result<CitaEntity>> reprogramarCita({
    required String citaId,
    required DateTime nuevaFechaCita,
    required DateTime nuevaHoraCita,
    required String terapeutaId,
    required String reprogramadoPor,
    String? razonReprogramacion,
  });

  /// Verificar disponibilidad de un terapeuta
  /// 
  /// [terapeutaId] ID del terapeuta
  /// [fechaCita] Fecha de la cita propuesta
  /// [horaCita] Hora de la cita propuesta
  /// [duracionMinutos] Duración de la cita en minutos
  /// [citaIdExcluir] ID de cita a excluir (para reprogramaciones)
  /// 
  /// Retorna [Result<bool>] true si está disponible, false si no
  Future<Result<bool>> verificarDisponibilidadTerapeuta({
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    required int duracionMinutos,
    String? citaIdExcluir,
  });

  /// Verificar conflictos de horario
  /// 
  /// [terapeutaId] ID del terapeuta
  /// [fechaCita] Fecha de la cita propuesta
  /// [horaCita] Hora de la cita propuesta
  /// [duracionMinutos] Duración de la cita en minutos
  /// [citaIdExcluir] ID de cita a excluir (para reprogramaciones)
  /// 
  /// Retorna [Result<List<CitaEntity>>] con las citas en conflicto
  Future<Result<List<CitaEntity>>> verificarConflictosHorario({
    required String terapeutaId,
    required DateTime fechaCita,
    required DateTime horaCita,
    required int duracionMinutos,
    String? citaIdExcluir,
  });

  /// Obtener estadísticas de citas
  /// 
  /// [fechaDesde] Fecha inicial del periodo
  /// [fechaHasta] Fecha final del periodo
  /// [terapeutaId] ID del terapeuta (opcional, para filtrar)
  /// 
  /// Retorna [Result<Map<String, dynamic>>] con estadísticas
  Future<Result<Map<String, dynamic>>> obtenerEstadisticasCitas({
    required DateTime fechaDesde,
    required DateTime fechaHasta,
    String? terapeutaId,
  });

  /// Obtener historial de cambios de una cita
  /// 
  /// [citaId] ID de la cita
  /// 
  /// Retorna [Result<List<Map<String, dynamic>>>] con el historial
  Future<Result<List<Map<String, dynamic>>>> obtenerHistorialCita(
    String citaId,
  );

  /// Stream de citas en tiempo real para un usuario
  /// 
  /// [usuarioId] ID del usuario (paciente o terapeuta)
  /// [rolUsuario] Rol del usuario para determinar qué citas mostrar
  /// 
  /// Retorna [Stream<Result<List<CitaEntity>>>] stream de citas
  Stream<Result<List<CitaEntity>>> streamCitasUsuario({
    required String usuarioId,
    required RolUsuario rolUsuario,
  });

  /// Stream de citas para el dashboard en tiempo real
  /// 
  /// [fechaDesde] Fecha inicial para el dashboard
  /// [fechaHasta] Fecha final para el dashboard
  /// 
  /// Retorna [Stream<Result<List<CitaEntity>>>] stream de citas del dashboard
  Stream<Result<List<CitaEntity>>> streamCitasDashboard({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });
} 