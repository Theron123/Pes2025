import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/therapist_entity.dart';

/// Eventos base para el BLoC de terapeutas
/// 
/// Define todas las acciones que pueden ser realizadas en el sistema de gestión
/// de terapeutas, incluyendo CRUD, búsquedas, y gestión de disponibilidad.
abstract class TerapeutasEvent extends Equatable {
  const TerapeutasEvent();

  @override
  List<Object?> get props => [];
}

/// Limpiar el estado del BLoC
class LimpiarEstadoTerapeutasEvent extends TerapeutasEvent {
  const LimpiarEstadoTerapeutasEvent();
}

/// Crear un nuevo terapeuta
class CrearTerapeutaEvent extends TerapeutasEvent {
  final String usuarioId;
  final String numeroLicencia;
  final List<EspecializacionMasaje> especializaciones;
  final HorariosTrabajo horariosTrabajo;
  final bool disponible;

  const CrearTerapeutaEvent({
    required this.usuarioId,
    required this.numeroLicencia,
    required this.especializaciones,
    required this.horariosTrabajo,
    this.disponible = true,
  });

  @override
  List<Object?> get props => [
        usuarioId,
        numeroLicencia,
        especializaciones,
        horariosTrabajo,
        disponible,
      ];
}

/// Cargar todos los terapeutas con filtros opcionales
class CargarTerapeutasEvent extends TerapeutasEvent {
  final bool disponibleSolo;
  final EspecializacionMasaje? especializacion;
  final int limite;
  final int pagina;

  const CargarTerapeutasEvent({
    this.disponibleSolo = false,
    this.especializacion,
    this.limite = 50,
    this.pagina = 1,
  });

  @override
  List<Object?> get props => [disponibleSolo, especializacion, limite, pagina];
}

/// Cargar terapeutas disponibles para una fecha y hora específica
class CargarTerapeutasDisponiblesEvent extends TerapeutasEvent {
  final DateTime fechaHora;
  final int duracionMinutos;
  final EspecializacionMasaje? especializacion;

  const CargarTerapeutasDisponiblesEvent({
    required this.fechaHora,
    required this.duracionMinutos,
    this.especializacion,
  });

  @override
  List<Object?> get props => [fechaHora, duracionMinutos, especializacion];
}

/// Obtener un terapeuta específico por ID
class ObtenerTerapeutaPorIdEvent extends TerapeutasEvent {
  final String terapeutaId;

  const ObtenerTerapeutaPorIdEvent({
    required this.terapeutaId,
  });

  @override
  List<Object?> get props => [terapeutaId];
}

/// Obtener terapeuta por ID de usuario
class ObtenerTerapeutaPorUsuarioEvent extends TerapeutasEvent {
  final String usuarioId;

  const ObtenerTerapeutaPorUsuarioEvent({
    required this.usuarioId,
  });

  @override
  List<Object?> get props => [usuarioId];
}

/// Actualizar información del terapeuta
class ActualizarTerapeutaEvent extends TerapeutasEvent {
  final String terapeutaId;
  final String? numeroLicencia;
  final List<EspecializacionMasaje>? especializaciones;
  final HorariosTrabajo? horariosTrabajo;
  final bool? disponible;

  const ActualizarTerapeutaEvent({
    required this.terapeutaId,
    this.numeroLicencia,
    this.especializaciones,
    this.horariosTrabajo,
    this.disponible,
  });

  @override
  List<Object?> get props => [
        terapeutaId,
        numeroLicencia,
        especializaciones,
        horariosTrabajo,
        disponible,
      ];
}

/// Cambiar disponibilidad del terapeuta
class CambiarDisponibilidadTerapeutaEvent extends TerapeutasEvent {
  final String terapeutaId;
  final bool disponible;

  const CambiarDisponibilidadTerapeutaEvent({
    required this.terapeutaId,
    required this.disponible,
  });

  @override
  List<Object?> get props => [terapeutaId, disponible];
}

/// Actualizar horarios de trabajo del terapeuta
class ActualizarHorariosTerapeutaEvent extends TerapeutasEvent {
  final String terapeutaId;
  final HorariosTrabajo horariosTrabajo;

  const ActualizarHorariosTerapeutaEvent({
    required this.terapeutaId,
    required this.horariosTrabajo,
  });

  @override
  List<Object?> get props => [terapeutaId, horariosTrabajo];
}

/// Agregar especialización al terapeuta
class AgregarEspecializacionEvent extends TerapeutasEvent {
  final String terapeutaId;
  final EspecializacionMasaje especializacion;

  const AgregarEspecializacionEvent({
    required this.terapeutaId,
    required this.especializacion,
  });

  @override
  List<Object?> get props => [terapeutaId, especializacion];
}

/// Eliminar especialización del terapeuta
class EliminarEspecializacionEvent extends TerapeutasEvent {
  final String terapeutaId;
  final EspecializacionMasaje especializacion;

  const EliminarEspecializacionEvent({
    required this.terapeutaId,
    required this.especializacion,
  });

  @override
  List<Object?> get props => [terapeutaId, especializacion];
}

/// Verificar disponibilidad de un terapeuta
class VerificarDisponibilidadTerapeutaEvent extends TerapeutasEvent {
  final String terapeutaId;
  final DateTime fechaHora;
  final int duracionMinutos;

  const VerificarDisponibilidadTerapeutaEvent({
    required this.terapeutaId,
    required this.fechaHora,
    required this.duracionMinutos,
  });

  @override
  List<Object?> get props => [terapeutaId, fechaHora, duracionMinutos];
}

/// Obtener estadísticas del terapeuta
class ObtenerEstadisticasTerapeutaEvent extends TerapeutasEvent {
  final String terapeutaId;
  final DateTime fechaDesde;
  final DateTime fechaHasta;

  const ObtenerEstadisticasTerapeutaEvent({
    required this.terapeutaId,
    required this.fechaDesde,
    required this.fechaHasta,
  });

  @override
  List<Object?> get props => [terapeutaId, fechaDesde, fechaHasta];
}

/// Buscar terapeutas por texto
class BuscarTerapeutasEvent extends TerapeutasEvent {
  final String textoBusqueda;
  final bool disponibleSolo;

  const BuscarTerapeutasEvent({
    required this.textoBusqueda,
    this.disponibleSolo = false,
  });

  @override
  List<Object?> get props => [textoBusqueda, disponibleSolo];
}

/// Eliminar terapeuta (soft delete)
class EliminarTerapeutaEvent extends TerapeutasEvent {
  final String terapeutaId;

  const EliminarTerapeutaEvent({
    required this.terapeutaId,
  });

  @override
  List<Object?> get props => [terapeutaId];
}

/// Verificar si un número de licencia ya existe
class VerificarLicenciaExisteEvent extends TerapeutasEvent {
  final String numeroLicencia;
  final String? terapeutaIdExcluir;

  const VerificarLicenciaExisteEvent({
    required this.numeroLicencia,
    this.terapeutaIdExcluir,
  });

  @override
  List<Object?> get props => [numeroLicencia, terapeutaIdExcluir];
} 