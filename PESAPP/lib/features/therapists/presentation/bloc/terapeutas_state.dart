import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/therapist_entity.dart';

/// Estados base para el BLoC de terapeutas
/// 
/// Define todos los posibles estados de la interfaz de usuario para la gestión
/// de terapeutas, incluyendo carga, éxito, error y estados específicos.
abstract class TerapeutasState extends Equatable {
  const TerapeutasState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del BLoC
class TerapeutasInitial extends TerapeutasState {
  const TerapeutasInitial();
}

/// Estado de carga general
class TerapeutasLoading extends TerapeutasState {
  final String mensaje;

  const TerapeutasLoading({
    this.mensaje = 'Cargando terapeutas...',
  });

  @override
  List<Object?> get props => [mensaje];
}

/// Estado de procesamiento para operaciones específicas
class TerapeutasProcessing extends TerapeutasState {
  final String operacion;
  final String mensaje;

  const TerapeutasProcessing({
    required this.operacion,
    required this.mensaje,
  });

  @override
  List<Object?> get props => [operacion, mensaje];
}

/// Estado de lista de terapeutas cargada
class TerapeutasLoaded extends TerapeutasState {
  final List<TerapeutaEntity> terapeutas;
  final int totalPaginas;
  final int paginaActual;
  final bool tieneMapDatos;
  final Map<String, dynamic>? metadatos;

  const TerapeutasLoaded({
    required this.terapeutas,
    this.totalPaginas = 1,
    this.paginaActual = 1,
    this.tieneMapDatos = false,
    this.metadatos,
  });

  @override
  List<Object?> get props => [
        terapeutas,
        totalPaginas,
        paginaActual,
        tieneMapDatos,
        metadatos,
      ];

  /// Crear copia con valores actualizados
  TerapeutasLoaded copyWith({
    List<TerapeutaEntity>? terapeutas,
    int? totalPaginas,
    int? paginaActual,
    bool? tieneMapDatos,
    Map<String, dynamic>? metadatos,
  }) {
    return TerapeutasLoaded(
      terapeutas: terapeutas ?? this.terapeutas,
      totalPaginas: totalPaginas ?? this.totalPaginas,
      paginaActual: paginaActual ?? this.paginaActual,
      tieneMapDatos: tieneMapDatos ?? this.tieneMapDatos,
      metadatos: metadatos ?? this.metadatos,
    );
  }
}

/// Estado de terapeutas disponibles cargados
class TerapeutasDisponiblesLoaded extends TerapeutasState {
  final List<TerapeutaEntity> terapeutasDisponibles;
  final DateTime fechaHora;
  final int duracionMinutos;
  final EspecializacionMasaje? especializacionFiltro;

  const TerapeutasDisponiblesLoaded({
    required this.terapeutasDisponibles,
    required this.fechaHora,
    required this.duracionMinutos,
    this.especializacionFiltro,
  });

  @override
  List<Object?> get props => [
        terapeutasDisponibles,
        fechaHora,
        duracionMinutos,
        especializacionFiltro,
      ];
}

/// Estado de terapeuta específico cargado
class TerapeutaIndividualLoaded extends TerapeutasState {
  final TerapeutaEntity terapeuta;
  final bool incluyeEstadisticas;
  final Map<String, dynamic>? estadisticas;

  const TerapeutaIndividualLoaded({
    required this.terapeuta,
    this.incluyeEstadisticas = false,
    this.estadisticas,
  });

  @override
  List<Object?> get props => [terapeuta, incluyeEstadisticas, estadisticas];
}

/// Estado de terapeuta creado exitosamente
class TerapeutaCreado extends TerapeutasState {
  final TerapeutaEntity terapeuta;
  final String mensaje;
  final DateTime timestamp;

  const TerapeutaCreado({
    required this.terapeuta,
    required this.mensaje,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [terapeuta, mensaje, timestamp];
}

/// Estado de terapeuta actualizado exitosamente
class TerapeutaActualizado extends TerapeutasState {
  final TerapeutaEntity terapeuta;
  final String mensaje;
  final DateTime timestamp;
  final String? camposActualizados;

  const TerapeutaActualizado({
    required this.terapeuta,
    required this.mensaje,
    required this.timestamp,
    this.camposActualizados,
  });

  @override
  List<Object?> get props => [terapeuta, mensaje, timestamp, camposActualizados];
}

/// Estado de disponibilidad verificada
class DisponibilidadVerificada extends TerapeutasState {
  final String terapeutaId;
  final bool disponible;
  final DateTime fechaHora;
  final int duracionMinutos;
  final String mensaje;
  final List<DateTime>? horariosAlternativos;

  const DisponibilidadVerificada({
    required this.terapeutaId,
    required this.disponible,
    required this.fechaHora,
    required this.duracionMinutos,
    required this.mensaje,
    this.horariosAlternativos,
  });

  @override
  List<Object?> get props => [
        terapeutaId,
        disponible,
        fechaHora,
        duracionMinutos,
        mensaje,
        horariosAlternativos,
      ];
}

/// Estado de estadísticas cargadas
class EstadisticasTerapeutaLoaded extends TerapeutasState {
  final String terapeutaId;
  final Map<String, dynamic> estadisticas;
  final DateTime fechaDesde;
  final DateTime fechaHasta;

  const EstadisticasTerapeutaLoaded({
    required this.terapeutaId,
    required this.estadisticas,
    required this.fechaDesde,
    required this.fechaHasta,
  });

  @override
  List<Object?> get props => [terapeutaId, estadisticas, fechaDesde, fechaHasta];
}

/// Estado de búsqueda completada
class BusquedaTerapeutasCompletada extends TerapeutasState {
  final List<TerapeutaEntity> resultados;
  final String textoBusqueda;
  final int totalResultados;
  final bool busquedaVacia;

  const BusquedaTerapeutasCompletada({
    required this.resultados,
    required this.textoBusqueda,
    required this.totalResultados,
    this.busquedaVacia = false,
  });

  @override
  List<Object?> get props => [
        resultados,
        textoBusqueda,
        totalResultados,
        busquedaVacia,
      ];
}

/// Estado de especialización actualizada
class EspecializacionActualizada extends TerapeutasState {
  final TerapeutaEntity terapeuta;
  final EspecializacionMasaje especializacion;
  final bool agregada; // true si se agregó, false si se eliminó
  final String mensaje;

  const EspecializacionActualizada({
    required this.terapeuta,
    required this.especializacion,
    required this.agregada,
    required this.mensaje,
  });

  @override
  List<Object?> get props => [terapeuta, especializacion, agregada, mensaje];
}

/// Estado de terapeuta eliminado
class TerapeutaEliminado extends TerapeutasState {
  final String terapeutaId;
  final String mensaje;
  final DateTime timestamp;

  const TerapeutaEliminado({
    required this.terapeutaId,
    required this.mensaje,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [terapeutaId, mensaje, timestamp];
}

/// Estado de verificación de licencia
class LicenciaVerificada extends TerapeutasState {
  final String numeroLicencia;
  final bool existe;
  final String mensaje;

  const LicenciaVerificada({
    required this.numeroLicencia,
    required this.existe,
    required this.mensaje,
  });

  @override
  List<Object?> get props => [numeroLicencia, existe, mensaje];
}

/// Estado de error general
class TerapeutasError extends TerapeutasState {
  final String mensaje;
  final int codigo;
  final String? detalles;
  final String? accionSugerida;

  const TerapeutasError({
    required this.mensaje,
    this.codigo = 6000,
    this.detalles,
    this.accionSugerida,
  });

  @override
  List<Object?> get props => [mensaje, codigo, detalles, accionSugerida];
}

/// Estado de error de validación
class TerapeutasValidationError extends TerapeutasState {
  final String mensaje;
  final int codigo;
  final Map<String, String>? erroresCampos;
  final String? campoAfectado;

  const TerapeutasValidationError({
    required this.mensaje,
    this.codigo = 6001,
    this.erroresCampos,
    this.campoAfectado,
  });

  @override
  List<Object?> get props => [mensaje, codigo, erroresCampos, campoAfectado];
}

/// Estado de error de negocio
class TerapeutasBusinessError extends TerapeutasState {
  final String mensaje;
  final int codigo;
  final String reglaViolada;
  final String? solucionSugerida;

  const TerapeutasBusinessError({
    required this.mensaje,
    this.codigo = 6002,
    required this.reglaViolada,
    this.solucionSugerida,
  });

  @override
  List<Object?> get props => [mensaje, codigo, reglaViolada, solucionSugerida];
}

/// Estado de error de red
class TerapeutasNetworkError extends TerapeutasState {
  final String mensaje;
  final int codigo;
  final bool puedeReintentar;

  const TerapeutasNetworkError({
    required this.mensaje,
    this.codigo = 6003,
    this.puedeReintentar = true,
  });

  @override
  List<Object?> get props => [mensaje, codigo, puedeReintentar];
}

/// Estado de error de base de datos
class TerapeutasDatabaseError extends TerapeutasState {
  final String mensaje;
  final int codigo;
  final String? operacionFallida;

  const TerapeutasDatabaseError({
    required this.mensaje,
    this.codigo = 6004,
    this.operacionFallida,
  });

  @override
  List<Object?> get props => [mensaje, codigo, operacionFallida];
} 