import "package:flutter_bloc/flutter_bloc.dart";
import "package:equatable/equatable.dart";
import "../../../../shared/domain/entities/appointment_entity.dart";
import "../../../../core/errors/failures.dart";
import "../../domain/usecases/crear_cita_usecase.dart";
import "../../domain/usecases/obtener_citas_por_paciente_usecase.dart";
import "../../domain/usecases/actualizar_estado_cita_usecase.dart";

part "citas_event.dart";
part "citas_state.dart";

/// BLoC para la gestión de citas en el sistema hospitalario
/// 
/// Este BLoC maneja todas las operaciones relacionadas con las citas:
/// - Crear nuevas citas
/// - Cargar citas por paciente, terapeuta o todas
/// - Actualizar estado de citas
/// - Cancelar citas
/// - Verificar disponibilidad de terapeutas
class CitasBloc extends Bloc<CitasEvent, CitasState> {
  final CrearCitaUseCase _crearCitaUseCase;
  final ObtenerCitasPorPacienteUseCase _obtenerCitasPorPacienteUseCase;
  final ActualizarEstadoCitaUseCase _actualizarEstadoCitaUseCase;

  CitasBloc({
    required CrearCitaUseCase crearCitaUseCase,
    required ObtenerCitasPorPacienteUseCase obtenerCitasPorPacienteUseCase,
    required ActualizarEstadoCitaUseCase actualizarEstadoCitaUseCase,
  }) : _crearCitaUseCase = crearCitaUseCase,
       _obtenerCitasPorPacienteUseCase = obtenerCitasPorPacienteUseCase,
       _actualizarEstadoCitaUseCase = actualizarEstadoCitaUseCase,
       super(const CitasInitial()) {
    
    // Registrar event handlers
    on<LimpiarEstadoEvent>(_onLimpiarEstado);
    on<CrearCitaEvent>(_onCrearCita);
    on<CargarCitasPorPacienteEvent>(_onCargarCitasPorPaciente);
    on<ActualizarEstadoCitaEvent>(_onActualizarEstadoCita);
    on<CancelarCitaEvent>(_onCancelarCita);
    on<VerificarDisponibilidadEvent>(_onVerificarDisponibilidad);
    on<CargarTodasLasCitasEvent>(_onCargarTodasLasCitas);
    on<CargarCitasPorTerapeutaEvent>(_onCargarCitasPorTerapeuta);
  }

  /// Limpiar el estado del BLoC
  void _onLimpiarEstado(LimpiarEstadoEvent event, Emitter<CitasState> emit) {
    emit(const CitasInitial());
  }

  /// Crear una nueva cita
  Future<void> _onCrearCita(CrearCitaEvent event, Emitter<CitasState> emit) async {
    try {
      emit(const CitasLoading(mensaje: 'Creando cita...'));

      final params = CrearCitaParams(
        pacienteId: event.pacienteId,
        terapeutaId: event.terapeutaId,
        fechaCita: event.fechaCita,
        horaCita: event.horaCita,
        tipoMasaje: event.tipoMasaje,
        duracionMinutos: event.duracionMinutos,
        notas: event.notas,
      );

      final result = await _crearCitaUseCase(params);

      if (result.isSuccess) {
        emit(CitaCreada(
          cita: result.value!,
          mensaje: 'Cita creada exitosamente para el ${_formatearFecha(event.fechaCita)}',
        ));
      } else {
        emit(_mapFailureToState(result.error!, 'crear la cita'));
      }
    } catch (e) {
      emit(CitasError(
        mensaje: 'Error inesperado al crear la cita: $e',
        detalleError: e,
      ));
    }
  }

  /// Cargar citas de un paciente específico
  Future<void> _onCargarCitasPorPaciente(CargarCitasPorPacienteEvent event, Emitter<CitasState> emit) async {
    try {
      emit(const CitasLoading(mensaje: 'Cargando citas...'));

      final params = ObtenerCitasPorPacienteParams(
        pacienteId: event.pacienteId,
        estado: event.estado,
        fechaDesde: event.fechaDesde,
        fechaHasta: event.fechaHasta,
        limite: event.limite,
        pagina: event.pagina,
      );

      final result = await _obtenerCitasPorPacienteUseCase(params);

      if (result.isSuccess) {
        final citas = result.value!;
        final estadisticas = ObtenerCitasPorPacienteUseCase.obtenerEstadisticas(citas);
        
        emit(CitasLoaded(
          citas: citas,
          totalCitas: citas.length,
          paginaActual: event.pagina,
          hayMasPaginas: citas.length >= event.limite,
          estadisticas: estadisticas,
        ));
      } else {
        emit(_mapFailureToState(result.error!, 'cargar las citas'));
      }
    } catch (e) {
      emit(CitasError(
        mensaje: 'Error inesperado al cargar las citas: $e',
        detalleError: e,
      ));
    }
  }

  /// Actualizar el estado de una cita
  Future<void> _onActualizarEstadoCita(ActualizarEstadoCitaEvent event, Emitter<CitasState> emit) async {
    try {
      emit(const CitasLoading(mensaje: 'Actualizando estado de la cita...'));

      final params = ActualizarEstadoCitaParams(
        citaId: event.citaId,
        nuevoEstado: event.nuevoEstado,
        usuarioId: event.usuarioId,
        notas: event.notas,
      );

      final result = await _actualizarEstadoCitaUseCase(params);

      if (result.isSuccess) {
        emit(CitaActualizada(
          cita: result.value!,
          mensaje: 'Estado de cita actualizado a ${event.nuevoEstado.nombre}',
        ));
      } else {
        emit(_mapFailureToState(result.error!, 'actualizar el estado de la cita'));
      }
    } catch (e) {
      emit(CitasError(
        mensaje: 'Error inesperado al actualizar el estado: $e',
        detalleError: e,
      ));
    }
  }

  /// Cancelar una cita
  Future<void> _onCancelarCita(CancelarCitaEvent event, Emitter<CitasState> emit) async {
    try {
      emit(const CitasLoading(mensaje: 'Cancelando cita...'));

      final params = ActualizarEstadoCitaParams(
        citaId: event.citaId,
        nuevoEstado: EstadoCita.cancelada,
        usuarioId: event.usuarioId,
        notas: event.razonCancelacion,
      );

      final result = await _actualizarEstadoCitaUseCase(params);

      if (result.isSuccess) {
        emit(CitaCancelada(
          cita: result.value!,
          mensaje: 'Cita cancelada exitosamente',
        ));
      } else {
        emit(_mapFailureToState(result.error!, 'cancelar la cita'));
      }
    } catch (e) {
      emit(CitasError(
        mensaje: 'Error inesperado al cancelar la cita: $e',
        detalleError: e,
      ));
    }
  }

  /// Verificar disponibilidad de un terapeuta
  Future<void> _onVerificarDisponibilidad(VerificarDisponibilidadEvent event, Emitter<CitasState> emit) async {
    try {
      emit(const CitasLoading(mensaje: 'Verificando disponibilidad...'));

      // TODO: Implementar verificación de disponibilidad cuando el repositorio esté completo
      // Por ahora, simular verificación
      await Future.delayed(const Duration(seconds: 1));

      emit(const DisponibilidadVerificada(
        disponible: true,
        mensaje: 'Terapeuta disponible en el horario solicitado',
      ));
    } catch (e) {
      emit(CitasError(
        mensaje: 'Error al verificar disponibilidad: $e',
        detalleError: e,
      ));
    }
  }

  /// Cargar todas las citas (para administradores)
  Future<void> _onCargarTodasLasCitas(CargarTodasLasCitasEvent event, Emitter<CitasState> emit) async {
    try {
      emit(const CitasLoading(mensaje: 'Cargando todas las citas...'));

      // TODO: Implementar cuando exista el use case correspondiente
      await Future.delayed(const Duration(seconds: 1));

      emit(const CitasLoaded(
        citas: [],
        totalCitas: 0,
        paginaActual: 1,
        hayMasPaginas: false,
      ));
    } catch (e) {
      emit(CitasError(
        mensaje: 'Error al cargar todas las citas: $e',
        detalleError: e,
      ));
    }
  }

  /// Cargar citas de un terapeuta específico
  Future<void> _onCargarCitasPorTerapeuta(CargarCitasPorTerapeutaEvent event, Emitter<CitasState> emit) async {
    try {
      emit(const CitasLoading(mensaje: 'Cargando citas del terapeuta...'));

      // TODO: Implementar cuando exista el use case correspondiente
      await Future.delayed(const Duration(seconds: 1));

      emit(const CitasLoaded(
        citas: [],
        totalCitas: 0,
        paginaActual: 1,
        hayMasPaginas: false,
      ));
    } catch (e) {
      emit(CitasError(
        mensaje: 'Error al cargar citas del terapeuta: $e',
        detalleError: e,
      ));
    }
  }

  /// Mapear errores del domain layer a estados del BLoC
  CitasState _mapFailureToState(Failure failure, String operacion) {
    switch (failure.runtimeType) {
      case ValidationFailure:
        final validationFailure = failure as ValidationFailure;
        return CitasError(
          mensaje: validationFailure.message,
          codigoError: 'VALIDATION_ERROR',
          numeroError: validationFailure.code ?? 0,
        );
      
      case AppointmentFailure:
        final appointmentFailure = failure as AppointmentFailure;
        return CitasError(
          mensaje: appointmentFailure.message,
          codigoError: 'APPOINTMENT_ERROR',
          numeroError: appointmentFailure.code ?? 0,
        );
      
      case NetworkFailure:
        final networkFailure = failure as NetworkFailure;
        return CitasError(
          mensaje: 'Error de conexion: ${networkFailure.message}',
          codigoError: 'NETWORK_ERROR',
          numeroError: networkFailure.code ?? 0,
        );
      
      case DatabaseFailure:
        final databaseFailure = failure as DatabaseFailure;
        return CitasError(
          mensaje: 'Error de base de datos: ${databaseFailure.message}',
          codigoError: 'DATABASE_ERROR',
          numeroError: databaseFailure.code ?? 0,
        );
      
      default:
        return CitasError(
          mensaje: 'Error al $operacion: ${failure.message}',
          codigoError: 'UNKNOWN_ERROR',
          detalleError: failure,
        );
    }
  }

  /// Formatear fecha para mensajes al usuario
  String _formatearFecha(DateTime fecha) {
    final dias = ['Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'];
    final meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
                   'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    
    final diaSemana = dias[fecha.weekday - 1];
    final dia = fecha.day;
    final mes = meses[fecha.month - 1];
    final anio = fecha.year;
    
    return '$diaSemana, $dia de $mes de $anio';
  }
}
