part of "citas_bloc.dart";

abstract class CitasState extends Equatable {
  const CitasState();
  @override
  List<Object?> get props => [];
}

class CitasInitial extends CitasState {
  const CitasInitial();
}

/// Estado de carga para cualquier operación
class CitasLoading extends CitasState {
  final String? mensaje;
  
  const CitasLoading({this.mensaje});
  
  @override
  List<Object?> get props => [mensaje];
}

/// Estado cuando se cargan exitosamente las citas
class CitasLoaded extends CitasState {
  final List<CitaEntity> citas;
  final int totalCitas;
  final int paginaActual;
  final bool hayMasPaginas;
  final Map<String, dynamic>? estadisticas;
  
  const CitasLoaded({
    required this.citas,
    required this.totalCitas,
    this.paginaActual = 1,
    this.hayMasPaginas = false,
    this.estadisticas,
  });
  
  @override
  List<Object?> get props => [
    citas,
    totalCitas,
    paginaActual,
    hayMasPaginas,
    estadisticas,
  ];
}

/// Estado cuando se crea exitosamente una cita
class CitaCreada extends CitasState {
  final CitaEntity cita;
  final String mensaje;
  
  const CitaCreada({
    required this.cita,
    this.mensaje = 'Cita creada exitosamente',
  });
  
  @override
  List<Object?> get props => [cita, mensaje];
}

/// Estado cuando se actualiza exitosamente una cita
class CitaActualizada extends CitasState {
  final CitaEntity cita;
  final String mensaje;
  
  const CitaActualizada({
    required this.cita,
    this.mensaje = 'Cita actualizada exitosamente',
  });
  
  @override
  List<Object?> get props => [cita, mensaje];
}

/// Estado cuando se cancela exitosamente una cita
class CitaCancelada extends CitasState {
  final CitaEntity cita;
  final String mensaje;
  
  const CitaCancelada({
    required this.cita,
    this.mensaje = 'Cita cancelada exitosamente',
  });
  
  @override
  List<Object?> get props => [cita, mensaje];
}

/// Estado de disponibilidad verificada
class DisponibilidadVerificada extends CitasState {
  final bool disponible;
  final List<DateTime>? horariosAlternativos;
  final String? mensaje;
  
  const DisponibilidadVerificada({
    required this.disponible,
    this.horariosAlternativos,
    this.mensaje,
  });
  
  @override
  List<Object?> get props => [disponible, horariosAlternativos, mensaje];
}

/// Estado de error para cualquier operación
class CitasError extends CitasState {
  final String mensaje;
  final String? codigoError;
  final int? numeroError;
  final dynamic detalleError;
  
  const CitasError({
    required this.mensaje,
    this.codigoError,
    this.numeroError,
    this.detalleError,
  });
  
  @override
  List<Object?> get props => [mensaje, codigoError, numeroError, detalleError];
}

/// Estado específico para errores de validación
class CitasValidationError extends CitasState {
  final String mensaje;
  final Map<String, String>? erroresCampos;
  final int codigoError;
  
  const CitasValidationError({
    required this.mensaje,
    this.erroresCampos,
    required this.codigoError,
  });
  
  @override
  List<Object?> get props => [mensaje, erroresCampos, codigoError];
}

/// Estado específico para errores de negocio de citas
class CitasBusinessError extends CitasState {
  final String mensaje;
  final int codigoError;
  final List<DateTime>? horariosAlternativos;
  
  const CitasBusinessError({
    required this.mensaje,
    required this.codigoError,
    this.horariosAlternativos,
  });
  
  @override
  List<Object?> get props => [mensaje, codigoError, horariosAlternativos];
}

/// Estado para operaciones en proceso con progreso
class CitasProcessing extends CitasState {
  final String operacion;
  final double? progreso;
  final String? mensajeDetalle;
  
  const CitasProcessing({
    required this.operacion,
    this.progreso,
    this.mensajeDetalle,
  });
  
  @override
  List<Object?> get props => [operacion, progreso, mensajeDetalle];
}
