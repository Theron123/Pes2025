import 'package:equatable/equatable.dart';

/// Especialización de masajes disponibles en el sistema hospitalario
enum EspecializacionMasaje {
  sueco,          // Swedish
  tejidoProfundo, // Deep Tissue
  piedrascalientes, // Hot Stone
  aromaterapia,   // Aromatherapy
  deportivo,      // Sports
  prenatal,       // Prenatal
  puntosGatillo,  // Trigger Point
  reflexologia,   // Reflexology
  shiatsu,        // Shiatsu
  tailandes,      // Thai
}

/// Extensión para EspecializacionMasaje
extension EspecializacionMasajeExtension on EspecializacionMasaje {
  String get nombre {
    switch (this) {
      case EspecializacionMasaje.sueco:
        return 'Masaje Sueco';
      case EspecializacionMasaje.tejidoProfundo:
        return 'Masaje de Tejido Profundo';
      case EspecializacionMasaje.piedrascalientes:
        return 'Masaje con Piedras Calientes';
      case EspecializacionMasaje.aromaterapia:
        return 'Aromaterapia';
      case EspecializacionMasaje.deportivo:
        return 'Masaje Deportivo';
      case EspecializacionMasaje.prenatal:
        return 'Masaje Prenatal';
      case EspecializacionMasaje.puntosGatillo:
        return 'Puntos Gatillo';
      case EspecializacionMasaje.reflexologia:
        return 'Reflexología';
      case EspecializacionMasaje.shiatsu:
        return 'Shiatsu';
      case EspecializacionMasaje.tailandes:
        return 'Masaje Tailandés';
    }
  }

  String get descripcion {
    switch (this) {
      case EspecializacionMasaje.sueco:
        return 'Masaje relajante con movimientos suaves y fluidos';
      case EspecializacionMasaje.tejidoProfundo:
        return 'Técnica que se enfoca en las capas profundas del músculo';
      case EspecializacionMasaje.piedrascalientes:
        return 'Terapia con piedras volcánicas calientes';
      case EspecializacionMasaje.aromaterapia:
        return 'Masaje con aceites esenciales aromáticos';
      case EspecializacionMasaje.deportivo:
        return 'Específico para atletas y lesiones deportivas';
      case EspecializacionMasaje.prenatal:
        return 'Diseñado especialmente para mujeres embarazadas';
      case EspecializacionMasaje.puntosGatillo:
        return 'Liberación de nudos musculares y puntos de tensión';
      case EspecializacionMasaje.reflexologia:
        return 'Estimulación de puntos reflejos en pies y manos';
      case EspecializacionMasaje.shiatsu:
        return 'Técnica japonesa de presión con dedos';
      case EspecializacionMasaje.tailandes:
        return 'Masaje tradicional con estiramientos';
    }
  }

  int get duracionMinutos {
    switch (this) {
      case EspecializacionMasaje.sueco:
        return 60;
      case EspecializacionMasaje.tejidoProfundo:
        return 90;
      case EspecializacionMasaje.piedrascalientes:
        return 75;
      case EspecializacionMasaje.aromaterapia:
        return 60;
      case EspecializacionMasaje.deportivo:
        return 60;
      case EspecializacionMasaje.prenatal:
        return 60;
      case EspecializacionMasaje.puntosGatillo:
        return 45;
      case EspecializacionMasaje.reflexologia:
        return 45;
      case EspecializacionMasaje.shiatsu:
        return 60;
      case EspecializacionMasaje.tailandes:
        return 90;
    }
  }
}

/// Días de la semana
enum DiaSemana {
  lunes,
  martes,
  miercoles,
  jueves,
  viernes,
  sabado,
  domingo,
}

/// Extensión para DiaSemana
extension DiaSemanaExtension on DiaSemana {
  String get nombre {
    switch (this) {
      case DiaSemana.lunes:
        return 'Lunes';
      case DiaSemana.martes:
        return 'Martes';
      case DiaSemana.miercoles:
        return 'Miércoles';
      case DiaSemana.jueves:
        return 'Jueves';
      case DiaSemana.viernes:
        return 'Viernes';
      case DiaSemana.sabado:
        return 'Sábado';
      case DiaSemana.domingo:
        return 'Domingo';
    }
  }

  String get abreviacion {
    switch (this) {
      case DiaSemana.lunes:
        return 'Lun';
      case DiaSemana.martes:
        return 'Mar';
      case DiaSemana.miercoles:
        return 'Mie';
      case DiaSemana.jueves:
        return 'Jue';
      case DiaSemana.viernes:
        return 'Vie';
      case DiaSemana.sabado:
        return 'Sab';
      case DiaSemana.domingo:
        return 'Dom';
    }
  }
}

/// Hora del día en formato 24 horas
class HoraDia extends Equatable {
  final int hora;
  final int minuto;

  const HoraDia({
    required this.hora,
    required this.minuto,
  }) : assert(hora >= 0 && hora <= 23),
       assert(minuto >= 0 && minuto <= 59);

  /// Crear desde string en formato HH:mm
  factory HoraDia.desde(String tiempo) {
    final partes = tiempo.split(':');
    if (partes.length != 2) {
      throw const FormatException('Formato de tiempo inválido. Use HH:mm');
    }
    
    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);
    
    if (hora == null || minuto == null) {
      throw const FormatException('Valores de tiempo inválidos');
    }
    
    return HoraDia(hora: hora, minuto: minuto);
  }

  /// Convertir a string en formato HH:mm
  String get formato24h {
    return '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
  }

  /// Convertir a string en formato 12 horas
  String get formato12h {
    final periodo = hora < 12 ? 'AM' : 'PM';
    final hora12 = hora == 0 ? 12 : (hora > 12 ? hora - 12 : hora);
    return '${hora12.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')} $periodo';
  }

  /// Convertir a minutos desde medianoche
  int get totalMinutos => hora * 60 + minuto;

  /// Verificar si es antes que otra hora
  bool esAntes(HoraDia otra) => totalMinutos < otra.totalMinutos;

  /// Verificar si es después que otra hora
  bool esDespues(HoraDia otra) => totalMinutos > otra.totalMinutos;

  @override
  List<Object> get props => [hora, minuto];
}

/// Horario de trabajo para un día específico
class HorarioDia extends Equatable {
  final DiaSemana dia;
  final bool esDiaLibre;
  final HoraDia? horaInicio;
  final HoraDia? horaFin;
  final HoraDia? inicioDescanso;
  final HoraDia? finDescanso;

  const HorarioDia({
    required this.dia,
    this.esDiaLibre = false,
    this.horaInicio,
    this.horaFin,
    this.inicioDescanso,
    this.finDescanso,
  });

  /// Verificar si el horario es válido
  bool get esValido {
    if (esDiaLibre) return true;
    
    if (horaInicio == null || horaFin == null) return false;
    
    if (horaInicio!.esDespues(horaFin!)) return false;
    
    if (inicioDescanso != null && finDescanso != null) {
      if (inicioDescanso!.esDespues(finDescanso!)) return false;
      if (inicioDescanso!.esAntes(horaInicio!) || finDescanso!.esDespues(horaFin!)) return false;
    }
    
    return true;
  }

  /// Verificar si una hora específica está disponible
  bool estaDisponible(HoraDia hora) {
    if (esDiaLibre) return false;
    if (horaInicio == null || horaFin == null) return false;
    
    if (hora.esAntes(horaInicio!) || hora.esDespues(horaFin!)) return false;
    
    if (inicioDescanso != null && finDescanso != null) {
      if (!hora.esAntes(inicioDescanso!) && !hora.esDespues(finDescanso!)) {
        return false;
      }
    }
    
    return true;
  }

  @override
  List<Object?> get props => [dia, esDiaLibre, horaInicio, horaFin, inicioDescanso, finDescanso];
}

/// Horarios de trabajo semanales
class HorariosTrabajo extends Equatable {
  final List<HorarioDia> horariosSemana;

  const HorariosTrabajo({required this.horariosSemana});

  /// Crear horarios de trabajo estándar (lunes a viernes 9-17)
  factory HorariosTrabajo.estandar() {
    return HorariosTrabajo(
      horariosSemana: [
        HorarioDia(
          dia: DiaSemana.lunes,
          horaInicio: const HoraDia(hora: 9, minuto: 0),
          horaFin: const HoraDia(hora: 17, minuto: 0),
          inicioDescanso: const HoraDia(hora: 12, minuto: 0),
          finDescanso: const HoraDia(hora: 13, minuto: 0),
        ),
        HorarioDia(
          dia: DiaSemana.martes,
          horaInicio: const HoraDia(hora: 9, minuto: 0),
          horaFin: const HoraDia(hora: 17, minuto: 0),
          inicioDescanso: const HoraDia(hora: 12, minuto: 0),
          finDescanso: const HoraDia(hora: 13, minuto: 0),
        ),
        HorarioDia(
          dia: DiaSemana.miercoles,
          horaInicio: const HoraDia(hora: 9, minuto: 0),
          horaFin: const HoraDia(hora: 17, minuto: 0),
          inicioDescanso: const HoraDia(hora: 12, minuto: 0),
          finDescanso: const HoraDia(hora: 13, minuto: 0),
        ),
        HorarioDia(
          dia: DiaSemana.jueves,
          horaInicio: const HoraDia(hora: 9, minuto: 0),
          horaFin: const HoraDia(hora: 17, minuto: 0),
          inicioDescanso: const HoraDia(hora: 12, minuto: 0),
          finDescanso: const HoraDia(hora: 13, minuto: 0),
        ),
        HorarioDia(
          dia: DiaSemana.viernes,
          horaInicio: const HoraDia(hora: 9, minuto: 0),
          horaFin: const HoraDia(hora: 17, minuto: 0),
          inicioDescanso: const HoraDia(hora: 12, minuto: 0),
          finDescanso: const HoraDia(hora: 13, minuto: 0),
        ),
        const HorarioDia(dia: DiaSemana.sabado, esDiaLibre: true),
        const HorarioDia(dia: DiaSemana.domingo, esDiaLibre: true),
      ],
    );
  }

  /// Obtener horario para un día específico
  HorarioDia? obtenerHorarioDia(DiaSemana dia) {
    try {
      return horariosSemana.firstWhere((h) => h.dia == dia);
    } catch (e) {
      return null;
    }
  }

  /// Verificar si está disponible en una fecha y hora específica
  bool estaDisponible(DateTime fechaHora) {
    final dia = DiaSemana.values[fechaHora.weekday - 1];
    final horarioDia = obtenerHorarioDia(dia);
    
    if (horarioDia == null) return false;
    
    final hora = HoraDia(hora: fechaHora.hour, minuto: fechaHora.minute);
    return horarioDia.estaDisponible(hora);
  }

  @override
  List<Object> get props => [horariosSemana];
}

/// Entidad de terapeuta en el sistema hospitalario de masajes
class TerapeutaEntity extends Equatable {
  final String id;
  final String usuarioId;
  final String numeroLicencia;
  final List<EspecializacionMasaje> especializaciones;
  final bool disponible;
  final HorariosTrabajo horariosTrabajo;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  const TerapeutaEntity({
    required this.id,
    required this.usuarioId,
    required this.numeroLicencia,
    required this.especializaciones,
    required this.disponible,
    required this.horariosTrabajo,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  /// Verificar si el terapeuta tiene una especialización específica
  bool tieneEspecializacion(EspecializacionMasaje especializacion) {
    return especializaciones.contains(especializacion);
  }

  /// Obtener nombres de especializaciones
  List<String> get nombresEspecializaciones {
    return especializaciones.map((e) => e.nombre).toList();
  }

  /// Verificar si está disponible en una fecha y hora específica
  bool estaDisponible(DateTime fechaHora) {
    if (!disponible) return false;
    return horariosTrabajo.estaDisponible(fechaHora);
  }

  /// Crear una copia con valores actualizados
  TerapeutaEntity copyWith({
    String? id,
    String? usuarioId,
    String? numeroLicencia,
    List<EspecializacionMasaje>? especializaciones,
    bool? disponible,
    HorariosTrabajo? horariosTrabajo,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return TerapeutaEntity(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      numeroLicencia: numeroLicencia ?? this.numeroLicencia,
      especializaciones: especializaciones ?? this.especializaciones,
      disponible: disponible ?? this.disponible,
      horariosTrabajo: horariosTrabajo ?? this.horariosTrabajo,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  List<Object> get props => [
    id,
    usuarioId,
    numeroLicencia,
    especializaciones,
    disponible,
    horariosTrabajo,
    creadoEn,
    actualizadoEn,
  ];
} 