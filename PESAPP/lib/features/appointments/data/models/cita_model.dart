import '../../../../shared/domain/entities/appointment_entity.dart';

/// Modelo de datos para citas que extiende CitaEntity y añade serialización JSON
/// 
/// Este modelo es responsable de:
/// - Convertir datos JSON de Supabase a entidades
/// - Convertir entidades a JSON para enviar a Supabase
/// - Mapear campos de base de datos a propiedades de entidad
class CitaModel extends CitaEntity {
  const CitaModel({
    required super.id,
    required super.pacienteId,
    required super.terapeutaId,
    required super.fechaCita,
    required super.horaCita,
    required super.duracionMinutos,
    required super.tipoMasaje,
    required super.estado,
    super.notas,
    super.creadoPor,
    required super.creadoEn,
    required super.actualizadoEn,
    super.canceladoEn,
    super.canceladoPor,
    super.razonCancelacion,
  });

  /// Crear CitaModel desde JSON (datos de Supabase)
  factory CitaModel.fromJson(Map<String, dynamic> json) {
    return CitaModel(
      id: json['id'] as String,
      pacienteId: json['patient_id'] as String,
      terapeutaId: json['therapist_id'] as String,
      fechaCita: DateTime.parse(json['appointment_date'] as String),
      horaCita: _parseTimeFromString(json['appointment_time'] as String),
      duracionMinutos: json['duration_minutes'] as int? ?? 60,
      tipoMasaje: json['massage_type'] as String,
      estado: EstadoCita.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EstadoCita.pendiente,
      ),
      notas: json['notes'] as String?,
      creadoPor: json['created_by'] as String?,
      creadoEn: DateTime.parse(json['created_at'] as String),
      actualizadoEn: DateTime.parse(json['updated_at'] as String),
      canceladoEn: json['canceled_at'] != null 
          ? DateTime.parse(json['canceled_at'] as String)
          : null,
      canceladoPor: json['canceled_by'] as String?,
      razonCancelacion: json['cancellation_reason'] as String?,
    );
  }

  /// Crear CitaModel desde JSON con joins (incluye datos de paciente y terapeuta)
  factory CitaModel.fromJsonWithJoins(Map<String, dynamic> json) {
    final citaModel = CitaModel.fromJson(json);
    
    // Los datos de paciente y terapeuta vienen en campos separados
    // Esto permite mostrar información adicional sin hacer queries adicionales
    return citaModel;
  }

  /// Convertir CitaModel a JSON para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': pacienteId,
      'therapist_id': terapeutaId,
      'appointment_date': fechaCita.toIso8601String().split('T')[0], // Solo fecha
      'appointment_time': _formatTimeToString(horaCita),
      'duration_minutes': duracionMinutos,
      'massage_type': tipoMasaje,
      'status': estado.name,
      'notes': notas,
      'created_by': creadoPor,
      'created_at': creadoEn.toIso8601String(),
      'updated_at': actualizadoEn.toIso8601String(),
      'canceled_at': canceladoEn?.toIso8601String(),
      'canceled_by': canceladoPor,
      'cancellation_reason': razonCancelacion,
    };
  }

  /// Convertir a JSON para crear nueva cita (sin IDs generados automáticamente)
  Map<String, dynamic> toCreateJson() {
    return {
      'patient_id': pacienteId,
      'therapist_id': terapeutaId,
      'appointment_date': fechaCita.toIso8601String().split('T')[0],
      'appointment_time': _formatTimeToString(horaCita),
      'duration_minutes': duracionMinutos,
      'massage_type': tipoMasaje,
      'status': estado.name,
      'notes': notas,
      'created_by': creadoPor,
    };
  }

  /// Convertir a JSON para actualizar cita (solo campos modificables)
  Map<String, dynamic> toUpdateJson() {
    return {
      'appointment_date': fechaCita.toIso8601String().split('T')[0],
      'appointment_time': _formatTimeToString(horaCita),
      'duration_minutes': duracionMinutos,
      'massage_type': tipoMasaje,
      'status': estado.name,
      'notes': notas,
      'updated_at': DateTime.now().toIso8601String(),
      'canceled_at': canceladoEn?.toIso8601String(),
      'canceled_by': canceladoPor,
      'cancellation_reason': razonCancelacion,
    };
  }

  /// Crear CitaModel desde CitaEntity
  factory CitaModel.fromEntity(CitaEntity entity) {
    return CitaModel(
      id: entity.id,
      pacienteId: entity.pacienteId,
      terapeutaId: entity.terapeutaId,
      fechaCita: entity.fechaCita,
      horaCita: entity.horaCita,
      duracionMinutos: entity.duracionMinutos,
      tipoMasaje: entity.tipoMasaje,
      estado: entity.estado,
      notas: entity.notas,
      creadoPor: entity.creadoPor,
      creadoEn: entity.creadoEn,
      actualizadoEn: entity.actualizadoEn,
      canceladoEn: entity.canceladoEn,
      canceladoPor: entity.canceladoPor,
      razonCancelacion: entity.razonCancelacion,
    );
  }

  /// Copiar CitaModel con algunos campos modificados
  @override
  CitaModel copyWith({
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
    return CitaModel(
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

  /// Parsear hora desde string formato HH:MM:SS
  static DateTime _parseTimeFromString(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    // Usamos fecha arbitraria, solo nos interesa la hora
    return DateTime(2023, 1, 1, hour, minute);
  }

  /// Formatear hora a string formato HH:MM:SS
  static String _formatTimeToString(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  @override
  String toString() {
    return 'CitaModel(id: $id, pacienteId: $pacienteId, terapeutaId: $terapeutaId, '
           'fechaCita: $fechaCita, estado: $estado, tipoMasaje: $tipoMasaje)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CitaModel &&
        other.id == id &&
        other.pacienteId == pacienteId &&
        other.terapeutaId == terapeutaId &&
        other.fechaCita == fechaCita &&
        other.horaCita == horaCita &&
        other.duracionMinutos == duracionMinutos &&
        other.tipoMasaje == tipoMasaje &&
        other.estado == estado &&
        other.notas == notas;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        pacienteId.hashCode ^
        terapeutaId.hashCode ^
        fechaCita.hashCode ^
        horaCita.hashCode ^
        duracionMinutos.hashCode ^
        tipoMasaje.hashCode ^
        estado.hashCode ^
        notas.hashCode;
  }
} 