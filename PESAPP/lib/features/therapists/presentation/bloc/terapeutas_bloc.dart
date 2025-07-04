import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/crear_terapeuta_usecase.dart';
import '../../domain/usecases/obtener_terapeutas_usecase.dart';
import 'terapeutas_event.dart';
import 'terapeutas_state.dart';

/// BLoC para gestión completa de terapeutas
class TerapeutasBloc extends Bloc<TerapeutasEvent, TerapeutasState> {
  final CrearTerapeutaUseCase _crearTerapeutaUseCase;
  final ObtenerTerapeutasUseCase _obtenerTerapeutasUseCase;

  TerapeutasBloc({
    required CrearTerapeutaUseCase crearTerapeutaUseCase,
    required ObtenerTerapeutasUseCase obtenerTerapeutasUseCase,
  })  : _crearTerapeutaUseCase = crearTerapeutaUseCase,
        _obtenerTerapeutasUseCase = obtenerTerapeutasUseCase,
        super(const TerapeutasInitial()) {
    // Eventos básicos
    on<LimpiarEstadoTerapeutasEvent>(_onLimpiarEstado);
    on<CrearTerapeutaEvent>(_onCrearTerapeuta);
    on<CargarTerapeutasEvent>(_onCargarTerapeutas);
    
    // Eventos de búsqueda y disponibilidad
    on<CargarTerapeutasDisponiblesEvent>(_onCargarTerapeutasDisponibles);
    on<ObtenerTerapeutaPorIdEvent>(_onObtenerTerapeutaPorId);
    on<ObtenerTerapeutaPorUsuarioEvent>(_onObtenerTerapeutaPorUsuario);
    on<VerificarDisponibilidadTerapeutaEvent>(_onVerificarDisponibilidad);
    
    // Eventos de actualización
    on<ActualizarTerapeutaEvent>(_onActualizarTerapeuta);
    on<CambiarDisponibilidadTerapeutaEvent>(_onCambiarDisponibilidad);
    on<ActualizarHorariosTerapeutaEvent>(_onActualizarHorarios);
    
    // Eventos de especialización
    on<AgregarEspecializacionEvent>(_onAgregarEspecializacion);
    on<EliminarEspecializacionEvent>(_onEliminarEspecializacion);
  }

  /// Limpiar estado
  FutureOr<void> _onLimpiarEstado(
    LimpiarEstadoTerapeutasEvent event,
    Emitter<TerapeutasState> emit,
  ) async {
    emit(const TerapeutasInitial());
  }

  /// Crear terapeuta
  FutureOr<void> _onCrearTerapeuta(
    CrearTerapeutaEvent event,
    Emitter<TerapeutasState> emit,
  ) async {
    emit(const TerapeutasLoading(mensaje: 'Creando terapeuta...'));

    try {
      final parametros = CrearTerapeutaParams(
        usuarioId: event.usuarioId,
        numeroLicencia: event.numeroLicencia,
        especializaciones: event.especializaciones,
        horariosTrabajo: event.horariosTrabajo,
        disponible: event.disponible,
      );

      final resultado = await _crearTerapeutaUseCase.call(parametros);

      if (resultado.isSuccess && resultado.value != null) {
        final terapeuta = resultado.value!;
        emit(TerapeutaCreado(
          terapeuta: terapeuta,
          mensaje: 'Terapeuta creado exitosamente',
          timestamp: DateTime.now(),
        ));
      } else {
        emit(TerapeutasError(
          mensaje: 'Error al crear terapeuta',
          codigo: 6100,
          detalles: resultado.error?.message,
        ));
      }
    } catch (e) {
      emit(TerapeutasError(
        mensaje: 'Error inesperado al crear terapeuta',
        codigo: 6101,
        detalles: e.toString(),
      ));
    }
  }

  /// Cargar lista de terapeutas
  FutureOr<void> _onCargarTerapeutas(
    CargarTerapeutasEvent event,
    Emitter<TerapeutasState> emit,
  ) async {
    emit(const TerapeutasLoading(mensaje: 'Cargando terapeutas...'));

    try {
      final parametros = ObtenerTerapeutasParams(
        disponibleSolo: event.disponibleSolo,
        especializacion: event.especializacion,
        limite: event.limite,
        pagina: event.pagina,
      );

      final resultado = await _obtenerTerapeutasUseCase.call(parametros);

      if (resultado.isSuccess && resultado.value != null) {
        final terapeutas = resultado.value!;
        emit(TerapeutasLoaded(
          terapeutas: terapeutas,
          totalPaginas: _calcularTotalPaginas(terapeutas.length, event.limite),
          paginaActual: event.pagina,
          metadatos: {
            'total_terapeutas': terapeutas.length,
            'ultima_actualizacion': DateTime.now().toIso8601String(),
            'filtros_aplicados': {
              'disponible_solo': event.disponibleSolo,
              'especializacion': event.especializacion?.name,
            },
          },
        ));
      } else {
        emit(TerapeutasError(
          mensaje: 'Error al cargar terapeutas',
          codigo: 6102,
          detalles: resultado.error?.message,
        ));
      }
    } catch (e) {
      emit(TerapeutasError(
        mensaje: 'Error inesperado al cargar terapeutas',
        codigo: 6103,
        detalles: e.toString(),
      ));
    }
  }

  /// Cargar terapeutas disponibles para fecha específica
  FutureOr<void> _onCargarTerapeutasDisponibles(
    CargarTerapeutasDisponiblesEvent event,
    Emitter<TerapeutasState> emit,
  ) async {
    emit(const TerapeutasLoading(mensaje: 'Verificando disponibilidad...'));

    try {
      // TODO: Implementar cuando esté disponible el repository completo
      // Por ahora, simulamos la búsqueda de terapeutas disponibles
      await Future.delayed(const Duration(seconds: 1));

      emit(TerapeutasDisponiblesLoaded(
        terapeutasDisponibles: const [],
        fechaHora: event.fechaHora,
        duracionMinutos: event.duracionMinutos,
        especializacionFiltro: event.especializacion,
      ));
    } catch (e) {
      emit(TerapeutasError(
        mensaje: 'Error al verificar disponibilidad',
        codigo: 6104,
        detalles: e.toString(),
      ));
    }
  }

  /// Obtener terapeuta por ID
  FutureOr<void> _onObtenerTerapeutaPorId(
    ObtenerTerapeutaPorIdEvent event,
    Emitter<TerapeutasState> emit,
  ) async {
    emit(const TerapeutasLoading(mensaje: 'Cargando terapeuta...'));

    try {
      // TODO: Implementar cuando esté disponible el repository completo
      await Future.delayed(const Duration(seconds: 1));

      emit(const TerapeutasError(
        mensaje: 'Funcionalidad pendiente de implementación',
        codigo: 6105,
        detalles: 'El repository no está completamente implementado',
      ));
    } catch (e) {
      emit(TerapeutasError(
        mensaje: 'Error al obtener terapeuta',
        codigo: 6106,
        detalles: e.toString(),
      ));
    }
  }

  /// Obtener terapeuta por usuario ID
  FutureOr<void> _onObtenerTerapeutaPorUsuario(
    ObtenerTerapeutaPorUsuarioEvent event,
    Emitter<TerapeutasState> emit,
  ) async {
    emit(const TerapeutasLoading(mensaje: 'Buscando terapeuta...'));

    try {
      // TODO: Implementar cuando esté disponible el repository completo
      await Future.delayed(const Duration(seconds: 1));

      emit(const TerapeutasError(
        mensaje: 'Funcionalidad pendiente de implementación',
        codigo: 6107,
        detalles: 'El repository no está completamente implementado',
      ));
    } catch (e) {
      emit(TerapeutasError(
        mensaje: 'Error al buscar terapeuta por usuario',
        codigo: 6108,
        detalles: e.toString(),
      ));
    }
  }

  /// Verificar disponibilidad de terapeuta
  FutureOr<void> _onVerificarDisponibilidad(
    VerificarDisponibilidadTerapeutaEvent event,
    Emitter<TerapeutasState> emit,
  ) async {
    emit(const TerapeutasProcessing(
      operacion: 'verificar_disponibilidad',
      mensaje: 'Verificando disponibilidad del terapeuta...',
    ));

    try {
      // TODO: Implementar verificación real con repository
      await Future.delayed(const Duration(seconds: 1));

      emit(DisponibilidadVerificada(
        terapeutaId: event.terapeutaId,
        disponible: true, // Simulación
        fechaHora: event.fechaHora,
        duracionMinutos: event.duracionMinutos,
        mensaje: 'Terapeuta disponible en el horario solicitado',
        horariosAlternativos: [
          event.fechaHora.add(const Duration(hours: 1)),
          event.fechaHora.add(const Duration(hours: 2)),
        ],
      ));
    } catch (e) {
      emit(TerapeutasError(
        mensaje: 'Error al verificar disponibilidad',
        codigo: 6109,
        detalles: e.toString(),
      ));
    }
  }

  /// Actualizar terapeuta
  FutureOr<void> _onActualizarTerapeuta(
    ActualizarTerapeutaEvent event,
    Emitter<TerapeutasState> emit,
  ) async {
    emit(const TerapeutasProcessing(
      operacion: 'actualizar_terapeuta',
      mensaje: 'Actualizando información del terapeuta...',
    ));

    try {
      // TODO: Implementar cuando esté disponible el repository completo
      await Future.delayed(const Duration(seconds: 1));

      emit(const TerapeutasError(
        mensaje: 'Funcionalidad pendiente de implementación',
        codigo: 6110,
        detalles: 'El repository de actualización no está implementado',
      ));
    } catch (e) {
      emit(TerapeutasError(
        mensaje: 'Error al actualizar terapeuta',
        codigo: 6111,
        detalles: e.toString(),
      ));
    }
  }

  /// Cambiar disponibilidad del terapeuta
  FutureOr<void> _onCambiarDisponibilidad(
    CambiarDisponibilidadTerapeutaEvent event,
    Emitter<TerapeutasState> emit,
  ) async {
    emit(TerapeutasProcessing(
      operacion: 'cambiar_disponibilidad',
      mensaje: event.disponible 
          ? 'Habilitando terapeuta...' 
          : 'Deshabilitando terapeuta...',
    ));

    try {
      // TODO: Implementar cuando esté disponible el repository completo
      await Future.delayed(const Duration(seconds: 1));

      emit(const TerapeutasError(
        mensaje: 'Funcionalidad pendiente de implementación',
        codigo: 6112,
        detalles: 'El repository de disponibilidad no está implementado',
      ));
    } catch (e) {
      emit(TerapeutasError(
        mensaje: 'Error al cambiar disponibilidad',
        codigo: 6113,
        detalles: e.toString(),
      ));
    }
  }

  /// Actualizar horarios de trabajo
  FutureOr<void> _onActualizarHorarios(
    ActualizarHorariosTerapeutaEvent event,
    Emitter<TerapeutasState> emit,
  ) async {
    emit(const TerapeutasProcessing(
      operacion: 'actualizar_horarios',
      mensaje: 'Actualizando horarios de trabajo...',
    ));

    try {
      // TODO: Implementar cuando esté disponible el repository completo
      await Future.delayed(const Duration(seconds: 1));

      emit(const TerapeutasError(
        mensaje: 'Funcionalidad pendiente de implementación',
        codigo: 6114,
        detalles: 'El repository de horarios no está implementado',
      ));
    } catch (e) {
      emit(TerapeutasError(
        mensaje: 'Error al actualizar horarios',
        codigo: 6115,
        detalles: e.toString(),
      ));
    }
  }

  /// Agregar especialización
  FutureOr<void> _onAgregarEspecializacion(
    AgregarEspecializacionEvent event,
    Emitter<TerapeutasState> emit,
  ) async {
    emit(const TerapeutasProcessing(
      operacion: 'agregar_especializacion',
      mensaje: 'Agregando especialización...',
    ));

    try {
      // TODO: Implementar cuando esté disponible el repository completo
      await Future.delayed(const Duration(seconds: 1));

      emit(const TerapeutasError(
        mensaje: 'Funcionalidad pendiente de implementación',
        codigo: 6116,
        detalles: 'El repository de especializaciones no está implementado',
      ));
    } catch (e) {
      emit(TerapeutasError(
        mensaje: 'Error al agregar especialización',
        codigo: 6117,
        detalles: e.toString(),
      ));
    }
  }

  /// Eliminar especialización
  FutureOr<void> _onEliminarEspecializacion(
    EliminarEspecializacionEvent event,
    Emitter<TerapeutasState> emit,
  ) async {
    emit(const TerapeutasProcessing(
      operacion: 'eliminar_especializacion',
      mensaje: 'Eliminando especialización...',
    ));

    try {
      // TODO: Implementar cuando esté disponible el repository completo
      await Future.delayed(const Duration(seconds: 1));

      emit(const TerapeutasError(
        mensaje: 'Funcionalidad pendiente de implementación',
        codigo: 6118,
        detalles: 'El repository de especializaciones no está implementado',
      ));
    } catch (e) {
      emit(TerapeutasError(
        mensaje: 'Error al eliminar especialización',
        codigo: 6119,
        detalles: e.toString(),
      ));
    }
  }

  /// Calcular total de páginas
  int _calcularTotalPaginas(int totalItems, int itemsPorPagina) {
    if (totalItems == 0 || itemsPorPagina == 0) return 1;
    return (totalItems / itemsPorPagina).ceil();
  }
} 