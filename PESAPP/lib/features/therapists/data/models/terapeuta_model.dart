import '../../../../shared/domain/entities/therapist_entity.dart';

/// Modelo de datos para terapeutas que extiende TerapeutaEntity y añade serialización JSON
/// 
/// Este modelo es responsable de:
/// - Convertir datos JSON de Supabase a entidades
/// - Convertir entidades a JSON para enviar a Supabase
/// - Mapear campos de base de datos a propiedades de entidad
/// - Serializar horarios de trabajo y especializaciones
class TerapeutaModel extends TerapeutaEntity {
  const TerapeutaModel({
    required super.id,
    required super.usuarioId,
    required super.numeroLicencia,
    required super.especializaciones,
    required super.disponible,
    required super.horariosTrabajo,
    required super.creadoEn,
    required super.actualizadoEn,
  });

  /// Crear TerapeutaModel desde JSON (datos de Supabase)
  factory TerapeutaModel.fromJson(Map<String, dynamic> json) {
    return TerapeutaModel(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      numeroLicencia: json['numero_licencia'] as String,
      especializaciones: _parseEspecializaciones(json['especializaciones'] as List<dynamic>?),
      disponible: json['disponible'] as bool? ?? true,
      horariosTrabajo: _parseHorariosTrabajo(json['horario_trabajo'] as Map<String, dynamic>?),
      creadoEn: DateTime.parse(json['created_at'] as String),
      actualizadoEn: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Crear TerapeutaModel desde JSON con joins (incluye datos de usuario)
  factory TerapeutaModel.fromJsonWithJoins(Map<String, dynamic> json) {
    return TerapeutaModel.fromJson(json);
  }

  /// Convertir TerapeutaModel a JSON para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'numero_licencia': numeroLicencia,
      'especializaciones': _serializeEspecializaciones(especializaciones),
      'disponible': disponible,
      'horario_trabajo': serializeHorariosTrabajo(horariosTrabajo),
      'created_at': creadoEn.toIso8601String(),
      'updated_at': actualizadoEn.toIso8601String(),
    };
  }

  /// Convertir a JSON para crear nuevo terapeuta (sin IDs generados automáticamente)
  Map<String, dynamic> toCreateJson() {
    return {
      'usuario_id': usuarioId,
      'numero_licencia': numeroLicencia,
      'especializaciones': _serializeEspecializaciones(especializaciones),
      'disponible': disponible,
      'horario_trabajo': serializeHorariosTrabajo(horariosTrabajo),
    };
  }

  /// Convertir a JSON para actualizar terapeuta (solo campos modificables)
  Map<String, dynamic> toUpdateJson() {
    return {
      'numero_licencia': numeroLicencia,
      'especializaciones': _serializeEspecializaciones(especializaciones),
      'disponible': disponible,
      'horario_trabajo': serializeHorariosTrabajo(horariosTrabajo),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Crear una copia con valores actualizados
  @override
  TerapeutaModel copyWith({
    String? id,
    String? usuarioId,
    String? numeroLicencia,
    List<EspecializacionMasaje>? especializaciones,
    bool? disponible,
    HorariosTrabajo? horariosTrabajo,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return TerapeutaModel(
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

  /// Parsear especializaciones desde array de strings
  static List<EspecializacionMasaje> _parseEspecializaciones(List<dynamic>? especializacionesJson) {
    if (especializacionesJson == null || especializacionesJson.isEmpty) {
      return [];
    }

    return especializacionesJson
        .cast<String>()
        .map((esp) {
          try {
            return EspecializacionMasaje.values.firstWhere(
              (e) => e.name == esp,
            );
          } catch (e) {
            // Si la especialización no existe, la ignoramos
            return null;
          }
        })
        .where((esp) => esp != null)
        .cast<EspecializacionMasaje>()
        .toList();
  }

  /// Serializar especializaciones a array de strings
  static List<String> _serializeEspecializaciones(List<EspecializacionMasaje> especializaciones) {
    return especializaciones.map((esp) => esp.name).toList();
  }

  /// Parsear horarios de trabajo desde JSON
  static HorariosTrabajo _parseHorariosTrabajo(Map<String, dynamic>? horariosJson) {
    if (horariosJson == null || horariosJson.isEmpty) {
      return HorariosTrabajo.estandar();
    }

    try {
      final horariosSemana = <HorarioDia>[];

      for (final dia in DiaSemana.values) {
        final diaData = horariosJson[dia.name] as Map<String, dynamic>?;
        
        if (diaData == null) {
          // Si no hay datos para este día, marcarlo como día libre
          horariosSemana.add(HorarioDia(dia: dia, esDiaLibre: true));
          continue;
        }

        final esDiaLibre = diaData['es_dia_libre'] as bool? ?? false;
        
        if (esDiaLibre) {
          horariosSemana.add(HorarioDia(dia: dia, esDiaLibre: true));
        } else {
          final horaInicioStr = diaData['hora_inicio'] as String?;
          final horaFinStr = diaData['hora_fin'] as String?;
          final inicioDescansoStr = diaData['inicio_descanso'] as String?;
          final finDescansoStr = diaData['fin_descanso'] as String?;

          horariosSemana.add(HorarioDia(
            dia: dia,
            esDiaLibre: false,
            horaInicio: horaInicioStr != null ? HoraDia.desde(horaInicioStr) : null,
            horaFin: horaFinStr != null ? HoraDia.desde(horaFinStr) : null,
            inicioDescanso: inicioDescansoStr != null ? HoraDia.desde(inicioDescansoStr) : null,
            finDescanso: finDescansoStr != null ? HoraDia.desde(finDescansoStr) : null,
          ));
        }
      }

      return HorariosTrabajo(horariosSemana: horariosSemana);
    } catch (e) {
      // Si hay error parseando, devolver horarios estándar
      return HorariosTrabajo.estandar();
    }
  }

  /// Serializar horarios de trabajo a JSON
  static Map<String, dynamic> serializeHorariosTrabajo(HorariosTrabajo horarios) {
    final horariosJson = <String, dynamic>{};

    for (final horarioDia in horarios.horariosSemana) {
      if (horarioDia.esDiaLibre) {
        horariosJson[horarioDia.dia.name] = {
          'es_dia_libre': true,
        };
      } else {
        horariosJson[horarioDia.dia.name] = {
          'es_dia_libre': false,
          'hora_inicio': horarioDia.horaInicio?.formato24h,
          'hora_fin': horarioDia.horaFin?.formato24h,
          'inicio_descanso': horarioDia.inicioDescanso?.formato24h,
          'fin_descanso': horarioDia.finDescanso?.formato24h,
        };
      }
    }

    return horariosJson;
  }

  /// Crear modelo desde entidad
  factory TerapeutaModel.fromEntity(TerapeutaEntity entity) {
    return TerapeutaModel(
      id: entity.id,
      usuarioId: entity.usuarioId,
      numeroLicencia: entity.numeroLicencia,
      especializaciones: entity.especializaciones,
      disponible: entity.disponible,
      horariosTrabajo: entity.horariosTrabajo,
      creadoEn: entity.creadoEn,
      actualizadoEn: entity.actualizadoEn,
    );
  }

  /// Convertir a entidad
  TerapeutaEntity toEntity() {
    return TerapeutaEntity(
      id: id,
      usuarioId: usuarioId,
      numeroLicencia: numeroLicencia,
      especializaciones: especializaciones,
      disponible: disponible,
      horariosTrabajo: horariosTrabajo,
      creadoEn: creadoEn,
      actualizadoEn: actualizadoEn,
    );
  }
} 