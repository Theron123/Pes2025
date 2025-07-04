part of "citas_bloc.dart";

abstract class CitasEvent extends Equatable {
  const CitasEvent();
  @override
  List<Object?> get props => [];
}

class LimpiarEstadoEvent extends CitasEvent {
  const LimpiarEstadoEvent();
}

/// Evento para cargar las citas de un paciente específico
class CargarCitasPorPacienteEvent extends CitasEvent {
  final String pacienteId;
  final EstadoCita? estado;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final int limite;
  final int pagina;

  const CargarCitasPorPacienteEvent({
    required this.pacienteId,
    this.estado,
    this.fechaDesde,
    this.fechaHasta,
    this.limite = 50,
    this.pagina = 1,
  });

  @override
  List<Object?> get props => [
    pacienteId,
    estado,
    fechaDesde,
    fechaHasta,
    limite,
    pagina,
  ];
}

/// Evento para crear una nueva cita
class CrearCitaEvent extends CitasEvent {
  final String pacienteId;
  final String terapeutaId;
  final DateTime fechaCita;
  final DateTime horaCita;
  final String tipoMasaje;
  final int duracionMinutos;
  final String? notas;

  const CrearCitaEvent({
    required this.pacienteId,
    required this.terapeutaId,
    required this.fechaCita,
    required this.horaCita,
    required this.tipoMasaje,
    this.duracionMinutos = 60,
    this.notas,
  });

  @override
  List<Object?> get props => [
    pacienteId,
    terapeutaId,
    fechaCita,
    horaCita,
    tipoMasaje,
    duracionMinutos,
    notas,
  ];
}

/// Evento para actualizar el estado de una cita
class ActualizarEstadoCitaEvent extends CitasEvent {
  final String citaId;
  final EstadoCita nuevoEstado;
  final String usuarioId;
  final String? notas;

  const ActualizarEstadoCitaEvent({
    required this.citaId,
    required this.nuevoEstado,
    required this.usuarioId,
    this.notas,
  });

  @override
  List<Object?> get props => [
    citaId,
    nuevoEstado,
    usuarioId,
    notas,
  ];
}

/// Evento para cargar todas las citas (para administradores)
class CargarTodasLasCitasEvent extends CitasEvent {
  final EstadoCita? estado;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final String? terapeutaId;
  final int limite;
  final int pagina;

  const CargarTodasLasCitasEvent({
    this.estado,
    this.fechaDesde,
    this.fechaHasta,
    this.terapeutaId,
    this.limite = 50,
    this.pagina = 1,
  });

  @override
  List<Object?> get props => [
    estado,
    fechaDesde,
    fechaHasta,
    terapeutaId,
    limite,
    pagina,
  ];
}

/// Evento para cargar citas de un terapeuta específico
class CargarCitasPorTerapeutaEvent extends CitasEvent {
  final String terapeutaId;
  final EstadoCita? estado;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final int limite;
  final int pagina;

  const CargarCitasPorTerapeutaEvent({
    required this.terapeutaId,
    this.estado,
    this.fechaDesde,
    this.fechaHasta,
    this.limite = 50,
    this.pagina = 1,
  });

  @override
  List<Object?> get props => [
    terapeutaId,
    estado,
    fechaDesde,
    fechaHasta,
    limite,
    pagina,
  ];
}

/// Evento para cancelar una cita
class CancelarCitaEvent extends CitasEvent {
  final String citaId;
  final String usuarioId;
  final String? razonCancelacion;

  const CancelarCitaEvent({
    required this.citaId,
    required this.usuarioId,
    this.razonCancelacion,
  });

  @override
  List<Object?> get props => [
    citaId,
    usuarioId,
    razonCancelacion,
  ];
}

/// Evento para verificar disponibilidad de un terapeuta
class VerificarDisponibilidadEvent extends CitasEvent {
  final String terapeutaId;
  final DateTime fechaCita;
  final DateTime horaCita;
  final int duracionMinutos;

  const VerificarDisponibilidadEvent({
    required this.terapeutaId,
    required this.fechaCita,
    required this.horaCita,
    required this.duracionMinutos,
  });

  @override
  List<Object?> get props => [
    terapeutaId,
    fechaCita,
    horaCita,
    duracionMinutos,
  ];
}
