import '../../domain/entities/notification_entity.dart';

/// Modelo de datos para notificaciones que maneja la serialización JSON
/// 
/// Extiende NotificationEntity y añade funcionalidades de conversión
/// hacia/desde JSON para integración con Supabase.
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.usuarioId,
    required super.tipo,
    required super.titulo,
    required super.mensaje,
    required super.estado,
    required super.canal,
    required super.fechaCreacion,
    super.citaId,
    super.terapeutaId,
    super.reporteId,
    super.datosAdicionales,
    super.fechaProgramada,
    super.fechaEnvio,
    super.fechaLectura,
    super.intentosEnvio = 0,
    super.mensajeError,
    super.requiereAccion = false,
    super.accion,
    super.cancelable = true,
    super.fechaExpiracion,
  });

  /// Crea un NotificationModel desde un Map (JSON)
  /// 
  /// Utilizado para deserializar datos desde Supabase
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationModel(
        id: json['id']?.toString() ?? '',
        usuarioId: json['usuario_id']?.toString() ?? '',
        tipo: _tipoFromString(json['tipo']?.toString() ?? ''),
        titulo: json['titulo']?.toString() ?? '',
        mensaje: json['mensaje']?.toString() ?? '',
        estado: _estadoFromString(json['estado']?.toString() ?? ''),
        canal: _canalFromString(json['canal']?.toString() ?? ''),
        citaId: json['cita_id']?.toString(),
        terapeutaId: json['terapeuta_id']?.toString(),
        reporteId: json['reporte_id']?.toString(),
        datosAdicionales: json['datos_adicionales'] as Map<String, dynamic>?,
        fechaCreacion: _parseDateTime(json['fecha_creacion']) ?? DateTime.now(),
        fechaProgramada: _parseDateTime(json['fecha_programada']),
        fechaEnvio: _parseDateTime(json['fecha_envio']),
        fechaLectura: _parseDateTime(json['fecha_lectura']),
        intentosEnvio: _parseInt(json['intentos_envio']) ?? 0,
        mensajeError: json['mensaje_error']?.toString(),
        requiereAccion: _parseBool(json['requiere_accion']) ?? false,
        accion: json['accion']?.toString(),
        cancelable: _parseBool(json['cancelable']) ?? true,
        fechaExpiracion: _parseDateTime(json['fecha_expiracion']),
      );
    } catch (e) {
      throw FormatException('Error al deserializar NotificationModel: $e');
    }
  }

  /// Convierte el modelo a Map (JSON)
  /// 
  /// Utilizado para serializar datos hacia Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'tipo': _tipoToString(tipo),
      'titulo': titulo,
      'mensaje': mensaje,
      'estado': _estadoToString(estado),
      'canal': _canalToString(canal),
      'cita_id': citaId,
      'terapeuta_id': terapeutaId,
      'reporte_id': reporteId,
      'datos_adicionales': datosAdicionales,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_programada': fechaProgramada?.toIso8601String(),
      'fecha_envio': fechaEnvio?.toIso8601String(),
      'fecha_lectura': fechaLectura?.toIso8601String(),
      'intentos_envio': intentosEnvio,
      'mensaje_error': mensajeError,
      'requiere_accion': requiereAccion,
      'accion': accion,
      'cancelable': cancelable,
      'fecha_expiracion': fechaExpiracion?.toIso8601String(),
    };
  }

  /// Crea un NotificationModel desde una NotificationEntity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      usuarioId: entity.usuarioId,
      tipo: entity.tipo,
      titulo: entity.titulo,
      mensaje: entity.mensaje,
      estado: entity.estado,
      canal: entity.canal,
      citaId: entity.citaId,
      terapeutaId: entity.terapeutaId,
      reporteId: entity.reporteId,
      datosAdicionales: entity.datosAdicionales,
      fechaCreacion: entity.fechaCreacion,
      fechaProgramada: entity.fechaProgramada,
      fechaEnvio: entity.fechaEnvio,
      fechaLectura: entity.fechaLectura,
      intentosEnvio: entity.intentosEnvio,
      mensajeError: entity.mensajeError,
      requiereAccion: entity.requiereAccion,
      accion: entity.accion,
      cancelable: entity.cancelable,
      fechaExpiracion: entity.fechaExpiracion,
    );
  }

  /// Convierte el modelo a NotificationEntity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      usuarioId: usuarioId,
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      estado: estado,
      canal: canal,
      citaId: citaId,
      terapeutaId: terapeutaId,
      reporteId: reporteId,
      datosAdicionales: datosAdicionales,
      fechaCreacion: fechaCreacion,
      fechaProgramada: fechaProgramada,
      fechaEnvio: fechaEnvio,
      fechaLectura: fechaLectura,
      intentosEnvio: intentosEnvio,
      mensajeError: mensajeError,
      requiereAccion: requiereAccion,
      accion: accion,
      cancelable: cancelable,
      fechaExpiracion: fechaExpiracion,
    );
  }

  /// Factory para crear notificación para crear en BD
  factory NotificationModel.forCreate({
    required String usuarioId,
    required TipoNotificacion tipo,
    required String titulo,
    required String mensaje,
    required CanalNotificacion canal,
    String? citaId,
    String? terapeutaId,
    String? reporteId,
    Map<String, dynamic>? datosAdicionales,
    DateTime? fechaProgramada,
    bool requiereAccion = false,
    String? accion,
    bool cancelable = true,
    DateTime? fechaExpiracion,
  }) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      usuarioId: usuarioId,
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      estado: EstadoNotificacion.pendiente,
      canal: canal,
      citaId: citaId,
      terapeutaId: terapeutaId,
      reporteId: reporteId,
      datosAdicionales: datosAdicionales,
      fechaCreacion: DateTime.now(),
      fechaProgramada: fechaProgramada,
      requiereAccion: requiereAccion,
      accion: accion,
      cancelable: cancelable,
      fechaExpiracion: fechaExpiracion,
    );
  }

  /// Factory para crear notificación para actualizar en BD
  factory NotificationModel.forUpdate({
    required String id,
    required String usuarioId,
    required TipoNotificacion tipo,
    required String titulo,
    required String mensaje,
    required EstadoNotificacion estado,
    required CanalNotificacion canal,
    required DateTime fechaCreacion,
    String? citaId,
    String? terapeutaId,
    String? reporteId,
    Map<String, dynamic>? datosAdicionales,
    DateTime? fechaProgramada,
    DateTime? fechaEnvio,
    DateTime? fechaLectura,
    int intentosEnvio = 0,
    String? mensajeError,
    bool requiereAccion = false,
    String? accion,
    bool cancelable = true,
    DateTime? fechaExpiracion,
  }) {
    return NotificationModel(
      id: id,
      usuarioId: usuarioId,
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      estado: estado,
      canal: canal,
      citaId: citaId,
      terapeutaId: terapeutaId,
      reporteId: reporteId,
      datosAdicionales: datosAdicionales,
      fechaCreacion: fechaCreacion,
      fechaProgramada: fechaProgramada,
      fechaEnvio: fechaEnvio,
      fechaLectura: fechaLectura,
      intentosEnvio: intentosEnvio,
      mensajeError: mensajeError,
      requiereAccion: requiereAccion,
      accion: accion,
      cancelable: cancelable,
      fechaExpiracion: fechaExpiracion,
    );
  }

  /// Crea una copia del modelo con campos actualizados
  NotificationModel copyWith({
    String? id,
    String? usuarioId,
    TipoNotificacion? tipo,
    String? titulo,
    String? mensaje,
    EstadoNotificacion? estado,
    CanalNotificacion? canal,
    String? citaId,
    String? terapeutaId,
    String? reporteId,
    Map<String, dynamic>? datosAdicionales,
    DateTime? fechaCreacion,
    DateTime? fechaProgramada,
    DateTime? fechaEnvio,
    DateTime? fechaLectura,
    int? intentosEnvio,
    String? mensajeError,
    bool? requiereAccion,
    String? accion,
    bool? cancelable,
    DateTime? fechaExpiracion,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      estado: estado ?? this.estado,
      canal: canal ?? this.canal,
      citaId: citaId ?? this.citaId,
      terapeutaId: terapeutaId ?? this.terapeutaId,
      reporteId: reporteId ?? this.reporteId,
      datosAdicionales: datosAdicionales ?? this.datosAdicionales,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaProgramada: fechaProgramada ?? this.fechaProgramada,
      fechaEnvio: fechaEnvio ?? this.fechaEnvio,
      fechaLectura: fechaLectura ?? this.fechaLectura,
      intentosEnvio: intentosEnvio ?? this.intentosEnvio,
      mensajeError: mensajeError ?? this.mensajeError,
      requiereAccion: requiereAccion ?? this.requiereAccion,
      accion: accion ?? this.accion,
      cancelable: cancelable ?? this.cancelable,
      fechaExpiracion: fechaExpiracion ?? this.fechaExpiracion,
    );
  }

  // ==================== MÉTODOS AUXILIARES DE CONVERSIÓN ====================

  /// Convierte string a TipoNotificacion
  static TipoNotificacion _tipoFromString(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'recordatorio_cita':
        return TipoNotificacion.recordatorioTarot;
      case 'cita_confirmada':
        return TipoNotificacion.citaConfirmada;
      case 'cita_cancelada':
        return TipoNotificacion.citaCancelada;
      case 'cita_reprogramada':
        return TipoNotificacion.citaReprogramada;
      case 'terapeuta_asignado':
        return TipoNotificacion.terapeutaAsignado;
      case 'recordatorio_24h':
        return TipoNotificacion.recordatorio24h;
      case 'recordatorio_2h':
        return TipoNotificacion.recordatorio2h;
      case 'cita_completada':
        return TipoNotificacion.citaCompletada;
      case 'reporte_generado':
        return TipoNotificacion.reporteGenerado;
      case 'notificacion_sistema':
        return TipoNotificacion.notificacionSistema;
      case 'actualizacion_perfil':
        return TipoNotificacion.actualizacionPerfil;
      case 'cambio_terapeuta':
        return TipoNotificacion.cambioTerapeuta;
      case 'mantenimiento_sistema':
        return TipoNotificacion.mantenimientoSistema;
      default:
        return TipoNotificacion.notificacionSistema;
    }
  }

  /// Convierte TipoNotificacion a string
  static String _tipoToString(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.recordatorioTarot:
        return 'recordatorio_cita';
      case TipoNotificacion.citaConfirmada:
        return 'cita_confirmada';
      case TipoNotificacion.citaCancelada:
        return 'cita_cancelada';
      case TipoNotificacion.citaReprogramada:
        return 'cita_reprogramada';
      case TipoNotificacion.terapeutaAsignado:
        return 'terapeuta_asignado';
      case TipoNotificacion.recordatorio24h:
        return 'recordatorio_24h';
      case TipoNotificacion.recordatorio2h:
        return 'recordatorio_2h';
      case TipoNotificacion.citaCompletada:
        return 'cita_completada';
      case TipoNotificacion.reporteGenerado:
        return 'reporte_generado';
      case TipoNotificacion.notificacionSistema:
        return 'notificacion_sistema';
      case TipoNotificacion.actualizacionPerfil:
        return 'actualizacion_perfil';
      case TipoNotificacion.cambioTerapeuta:
        return 'cambio_terapeuta';
      case TipoNotificacion.mantenimientoSistema:
        return 'mantenimiento_sistema';
    }
  }

  /// Convierte string a EstadoNotificacion
  static EstadoNotificacion _estadoFromString(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return EstadoNotificacion.pendiente;
      case 'enviada':
        return EstadoNotificacion.enviada;
      case 'leida':
        return EstadoNotificacion.leida;
      case 'error':
        return EstadoNotificacion.error;
      case 'cancelada':
        return EstadoNotificacion.cancelada;
      default:
        return EstadoNotificacion.pendiente;
    }
  }

  /// Convierte EstadoNotificacion a string
  static String _estadoToString(EstadoNotificacion estado) {
    switch (estado) {
      case EstadoNotificacion.pendiente:
        return 'pendiente';
      case EstadoNotificacion.enviada:
        return 'enviada';
      case EstadoNotificacion.leida:
        return 'leida';
      case EstadoNotificacion.error:
        return 'error';
      case EstadoNotificacion.cancelada:
        return 'cancelada';
    }
  }

  /// Convierte string a CanalNotificacion
  static CanalNotificacion _canalFromString(String canal) {
    switch (canal.toLowerCase()) {
      case 'push':
        return CanalNotificacion.push;
      case 'email':
        return CanalNotificacion.email;
      case 'sms':
        return CanalNotificacion.sms;
      case 'in_app':
        return CanalNotificacion.inApp;
      default:
        return CanalNotificacion.push;
    }
  }

  /// Convierte CanalNotificacion a string
  static String _canalToString(CanalNotificacion canal) {
    switch (canal) {
      case CanalNotificacion.push:
        return 'push';
      case CanalNotificacion.email:
        return 'email';
      case CanalNotificacion.sms:
        return 'sms';
      case CanalNotificacion.inApp:
        return 'in_app';
    }
  }

  /// Parsea DateTime desde string o timestamp
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    try {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value is DateTime) {
        return value;
      }
    } catch (e) {
      // Ignorar errores de parsing y retornar null
    }
    
    return null;
  }

  /// Parsea int desde dynamic
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    
    try {
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.parse(value);
      } else if (value is double) {
        return value.toInt();
      }
    } catch (e) {
      // Ignorar errores de parsing y retornar null
    }
    
    return null;
  }

  /// Parsea bool desde dynamic
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    
    try {
      if (value is bool) {
        return value;
      } else if (value is String) {
        return value.toLowerCase() == 'true';
      } else if (value is int) {
        return value == 1;
      }
    } catch (e) {
      // Ignorar errores de parsing y retornar null
    }
    
    return null;
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, tipo: ${tipo.nombre}, titulo: $titulo, estado: ${estado.nombre})';
  }
} 