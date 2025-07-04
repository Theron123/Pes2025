import 'package:equatable/equatable.dart';

/// Estado de una cita en el sistema hospitalario de masajes
enum EstadoCita {
  pendiente,
  confirmada,
  enProgreso,
  completada,
  cancelada,
  noShow,
}

/// Extensión para EstadoCita
extension EstadoCitaExtension on EstadoCita {
  String get nombre {
    switch (this) {
      case EstadoCita.pendiente:
        return 'Pendiente';
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.enProgreso:
        return 'En Progreso';
      case EstadoCita.completada:
        return 'Completada';
      case EstadoCita.cancelada:
        return 'Cancelada';
      case EstadoCita.noShow:
        return 'No Se Presentó';
    }
  }

  String get descripcion {
    switch (this) {
      case EstadoCita.pendiente:
        return 'Cita reservada, esperando confirmación del terapeuta';
      case EstadoCita.confirmada:
        return 'Cita confirmada por el terapeuta';
      case EstadoCita.enProgreso:
        return 'Sesión de masaje en curso';
      case EstadoCita.completada:
        return 'Sesión de masaje finalizada exitosamente';
      case EstadoCita.cancelada:
        return 'Cita cancelada por el paciente o terapeuta';
      case EstadoCita.noShow:
        return 'El paciente no se presentó a la cita';
    }
  }

  int get valorColor {
    switch (this) {
      case EstadoCita.pendiente:
        return 0xFFFFC107; // Ámbar
      case EstadoCita.confirmada:
        return 0xFF2196F3; // Azul
      case EstadoCita.enProgreso:
        return 0xFF9C27B0; // Púrpura
      case EstadoCita.completada:
        return 0xFF4CAF50; // Verde
      case EstadoCita.cancelada:
        return 0xFF757575; // Gris
      case EstadoCita.noShow:
        return 0xFFF44336; // Rojo
    }
  }

  bool get esFinalizado {
    switch (this) {
      case EstadoCita.completada:
      case EstadoCita.cancelada:
      case EstadoCita.noShow:
        return true;
      case EstadoCita.pendiente:
      case EstadoCita.confirmada:
      case EstadoCita.enProgreso:
        return false;
    }
  }

  bool get esActivo {
    switch (this) {
      case EstadoCita.pendiente:
      case EstadoCita.confirmada:
      case EstadoCita.enProgreso:
        return true;
      case EstadoCita.completada:
      case EstadoCita.cancelada:
      case EstadoCita.noShow:
        return false;
    }
  }
}

/// Entidad de cita en el sistema hospitalario de masajes
class CitaEntity extends Equatable {
  final String id;
  final String pacienteId;
  final String terapeutaId;
  final DateTime fechaCita;
  final DateTime horaCita;
  final int duracionMinutos;
  final String tipoMasaje;
  final EstadoCita estado;
  final String? notas;
  final String? creadoPor;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  final DateTime? canceladoEn;
  final String? canceladoPor;
  final String? razonCancelacion;

  const CitaEntity({
    required this.id,
    required this.pacienteId,
    required this.terapeutaId,
    required this.fechaCita,
    required this.horaCita,
    required this.duracionMinutos,
    required this.tipoMasaje,
    required this.estado,
    this.notas,
    this.creadoPor,
    required this.creadoEn,
    required this.actualizadoEn,
    this.canceladoEn,
    this.canceladoPor,
    this.razonCancelacion,
  });

  /// Combinar fecha y hora de la cita
  DateTime get fechaHoraCompleta {
    return DateTime(
      fechaCita.year,
      fechaCita.month,
      fechaCita.day,
      horaCita.hour,
      horaCita.minute,
    );
  }

  /// Obtener la hora de finalización de la cita
  DateTime get horaFinalizacion {
    return fechaHoraCompleta.add(Duration(minutes: duracionMinutos));
  }

  /// Verificar si la cita es en el pasado
  bool get esPasada {
    return fechaHoraCompleta.isBefore(DateTime.now());
  }

  /// Verificar si la cita es en el futuro
  bool get esFutura {
    return fechaHoraCompleta.isAfter(DateTime.now());
  }

  /// Verificar si la cita es hoy
  bool get esHoy {
    final ahora = DateTime.now();
    return fechaCita.year == ahora.year &&
           fechaCita.month == ahora.month &&
           fechaCita.day == ahora.day;
  }

  /// Verificar si la cita es mañana
  bool get esManana {
    final manana = DateTime.now().add(const Duration(days: 1));
    return fechaCita.year == manana.year &&
           fechaCita.month == manana.month &&
           fechaCita.day == manana.day;
  }

  /// Verificar si la cita está en progreso ahora
  bool get estaEnProgreso {
    if (estado != EstadoCita.enProgreso) return false;
    
    final ahora = DateTime.now();
    return ahora.isAfter(fechaHoraCompleta) && 
           ahora.isBefore(horaFinalizacion);
  }

  /// Verificar si la cita puede ser cancelada
  bool get puedeSerCancelada {
    if (estado.esFinalizado) return false;
    if (esPasada) return false;
    
    // Regla: no se puede cancelar 2 horas antes de la cita
    final limiteCancelacion = fechaHoraCompleta.subtract(const Duration(hours: 2));
    return DateTime.now().isBefore(limiteCancelacion);
  }

  /// Verificar si la cita puede ser reprogramada
  bool get puedeSerReprogramada {
    if (estado.esFinalizado) return false;
    if (esPasada) return false;
    
    // Regla: se puede reprogramar hasta 24 horas antes
    final limiteReprogramacion = fechaHoraCompleta.subtract(const Duration(hours: 24));
    return DateTime.now().isBefore(limiteReprogramacion);
  }

  /// Verificar si se debe enviar recordatorio
  bool get debeEnviarRecordatorio {
    if (estado != EstadoCita.confirmada) return false;
    if (esPasada) return false;
    
    // Enviar recordatorio 24 horas antes
    final tiempoRecordatorio = fechaHoraCompleta.subtract(const Duration(hours: 24));
    final ahora = DateTime.now();
    
    // Ventana de 1 hora para enviar el recordatorio
    return ahora.isAfter(tiempoRecordatorio) && 
           ahora.isBefore(tiempoRecordatorio.add(const Duration(hours: 1)));
  }

  /// Obtener tiempo restante hasta la cita
  Duration get tiempoRestante {
    if (esPasada) return Duration.zero;
    return fechaHoraCompleta.difference(DateTime.now());
  }

  /// Formatear fecha para mostrar
  String get fechaFormateada {
    final meses = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${fechaCita.day} de ${meses[fechaCita.month]} de ${fechaCita.year}';
  }

  /// Formatear hora para mostrar
  String get horaFormateada {
    final hora12 = horaCita.hour == 0 ? 12 : (horaCita.hour > 12 ? horaCita.hour - 12 : horaCita.hour);
    final periodo = horaCita.hour < 12 ? 'AM' : 'PM';
    final minutos = horaCita.minute.toString().padLeft(2, '0');
    return '$hora12:$minutos $periodo';
  }

  /// Formatear duración para mostrar
  String get duracionFormateada {
    final horas = duracionMinutos ~/ 60;
    final minutos = duracionMinutos % 60;
    
    if (horas == 0) {
      return '$minutos min';
    } else if (minutos == 0) {
      return '$horas h';
    } else {
      return '$horas h $minutos min';
    }
  }

  /// Obtener resumen de la cita
  String get resumen {
    return '$tipoMasaje - $fechaFormateada a las $horaFormateada ($duracionFormateada)';
  }

  /// Obtener días hasta la cita
  int get diasHastaCita {
    if (esPasada) return 0;
    return fechaHoraCompleta.difference(DateTime.now()).inDays;
  }

  /// Crear una copia con valores actualizados
  CitaEntity copyWith({
    String? id,
    String? pacienteId,
    String? terapeutaId,
    DateTime? fechaCita,
    DateTime? horaCita,
    int? duracionMinutos,
    String? tipoMasaje,
    EstadoCita? estado,
    String? notas,
    String? creadoPor,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    DateTime? canceladoEn,
    String? canceladoPor,
    String? razonCancelacion,
  }) {
    return CitaEntity(
      id: id ?? this.id,
      pacienteId: pacienteId ?? this.pacienteId,
      terapeutaId: terapeutaId ?? this.terapeutaId,
      fechaCita: fechaCita ?? this.fechaCita,
      horaCita: horaCita ?? this.horaCita,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      tipoMasaje: tipoMasaje ?? this.tipoMasaje,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
      creadoPor: creadoPor ?? this.creadoPor,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      canceladoEn: canceladoEn ?? this.canceladoEn,
      canceladoPor: canceladoPor ?? this.canceladoPor,
      razonCancelacion: razonCancelacion ?? this.razonCancelacion,
    );
  }

  @override
  List<Object?> get props => [
    id,
    pacienteId,
    terapeutaId,
    fechaCita,
    horaCita,
    duracionMinutos,
    tipoMasaje,
    estado,
    notas,
    creadoPor,
    creadoEn,
    actualizadoEn,
    canceladoEn,
    canceladoPor,
    razonCancelacion,
  ];
} 