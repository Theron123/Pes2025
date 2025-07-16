import 'package:equatable/equatable.dart';

/// Tipos de notificación disponibles en el sistema hospitalario
enum TipoNotificacion {
  recordatorioTarot,
  citaConfirmada,
  citaCancelada,
  citaReprogramada,
  terapeutaAsignado,
  recordatorio24h,
  recordatorio2h,
  citaCompletada,
  reporteGenerado,
  notificacionSistema,
  actualizacionPerfil,
  cambioTerapeuta,
  mantenimientoSistema,
}

/// Extensión para obtener información descriptiva de los tipos de notificación
extension TipoNotificacionExtension on TipoNotificacion {
  /// Nombre descriptivo del tipo de notificación
  String get nombre {
    switch (this) {
      case TipoNotificacion.recordatorioTarot:
        return 'Recordatorio de Cita';
      case TipoNotificacion.citaConfirmada:
        return 'Cita Confirmada';
      case TipoNotificacion.citaCancelada:
        return 'Cita Cancelada';
      case TipoNotificacion.citaReprogramada:
        return 'Cita Reprogramada';
      case TipoNotificacion.terapeutaAsignado:
        return 'Terapeuta Asignado';
      case TipoNotificacion.recordatorio24h:
        return 'Recordatorio 24 Horas';
      case TipoNotificacion.recordatorio2h:
        return 'Recordatorio 2 Horas';
      case TipoNotificacion.citaCompletada:
        return 'Cita Completada';
      case TipoNotificacion.reporteGenerado:
        return 'Reporte Generado';
      case TipoNotificacion.notificacionSistema:
        return 'Notificación del Sistema';
      case TipoNotificacion.actualizacionPerfil:
        return 'Perfil Actualizado';
      case TipoNotificacion.cambioTerapeuta:
        return 'Cambio de Terapeuta';
      case TipoNotificacion.mantenimientoSistema:
        return 'Mantenimiento del Sistema';
    }
  }

  /// Icono recomendado para el tipo de notificación
  String get icono {
    switch (this) {
      case TipoNotificacion.recordatorioTarot:
      case TipoNotificacion.recordatorio24h:
      case TipoNotificacion.recordatorio2h:
        return 'alarm';
      case TipoNotificacion.citaConfirmada:
        return 'check_circle';
      case TipoNotificacion.citaCancelada:
        return 'cancel';
      case TipoNotificacion.citaReprogramada:
        return 'schedule';
      case TipoNotificacion.terapeutaAsignado:
      case TipoNotificacion.cambioTerapeuta:
        return 'person';
      case TipoNotificacion.citaCompletada:
        return 'done_all';
      case TipoNotificacion.reporteGenerado:
        return 'description';
      case TipoNotificacion.notificacionSistema:
      case TipoNotificacion.mantenimientoSistema:
        return 'info';
      case TipoNotificacion.actualizacionPerfil:
        return 'account_circle';
    }
  }

  /// Prioridad de la notificación (1 = alta, 3 = baja)
  int get prioridad {
    switch (this) {
      case TipoNotificacion.recordatorio2h:
      case TipoNotificacion.citaCancelada:
      case TipoNotificacion.mantenimientoSistema:
        return 1; // Alta prioridad
      case TipoNotificacion.recordatorioTarot:
      case TipoNotificacion.recordatorio24h:
      case TipoNotificacion.citaConfirmada:
      case TipoNotificacion.citaReprogramada:
      case TipoNotificacion.terapeutaAsignado:
      case TipoNotificacion.cambioTerapeuta:
        return 2; // Prioridad media
      case TipoNotificacion.citaCompletada:
      case TipoNotificacion.reporteGenerado:
      case TipoNotificacion.notificacionSistema:
      case TipoNotificacion.actualizacionPerfil:
        return 3; // Prioridad baja
    }
  }
}

/// Estado de la notificación
enum EstadoNotificacion {
  pendiente,
  enviada,
  leida,
  error,
  cancelada,
}

/// Extensión para el estado de notificación
extension EstadoNotificacionExtension on EstadoNotificacion {
  String get nombre {
    switch (this) {
      case EstadoNotificacion.pendiente:
        return 'Pendiente';
      case EstadoNotificacion.enviada:
        return 'Enviada';
      case EstadoNotificacion.leida:
        return 'Leída';
      case EstadoNotificacion.error:
        return 'Error';
      case EstadoNotificacion.cancelada:
        return 'Cancelada';
    }
  }

  String get color {
    switch (this) {
      case EstadoNotificacion.pendiente:
        return 'orange';
      case EstadoNotificacion.enviada:
        return 'blue';
      case EstadoNotificacion.leida:
        return 'green';
      case EstadoNotificacion.error:
        return 'red';
      case EstadoNotificacion.cancelada:
        return 'gray';
    }
  }
}

/// Canal de entrega de notificación
enum CanalNotificacion {
  push,
  email,
  sms,
  inApp,
}

/// Entidad principal de notificación del sistema hospitalario
/// 
/// Representa una notificación que puede ser enviada a un usuario específico
/// a través de diferentes canales (push, email, SMS, in-app).
class NotificationEntity extends Equatable {
  /// ID único de la notificación
  final String id;

  /// ID del usuario destinatario
  final String usuarioId;

  /// Tipo de notificación
  final TipoNotificacion tipo;

  /// Título de la notificación
  final String titulo;

  /// Mensaje/contenido de la notificación
  final String mensaje;

  /// Estado actual de la notificación
  final EstadoNotificacion estado;

  /// Canal por el cual se envió la notificación
  final CanalNotificacion canal;

  /// ID de la cita asociada (si aplica)
  final String? citaId;

  /// ID del terapeuta asociado (si aplica)
  final String? terapeutaId;

  /// ID del reporte asociado (si aplica)
  final String? reporteId;

  /// Datos adicionales en formato JSON (opcional)
  final Map<String, dynamic>? datosAdicionales;

  /// Fecha y hora de creación
  final DateTime fechaCreacion;

  /// Fecha y hora programada para envío
  final DateTime? fechaProgramada;

  /// Fecha y hora de envío real
  final DateTime? fechaEnvio;

  /// Fecha y hora de lectura
  final DateTime? fechaLectura;

  /// Número de intentos de envío
  final int intentosEnvio;

  /// Mensaje de error si hubo problemas en el envío
  final String? mensajeError;

  /// Si la notificación requiere acción del usuario
  final bool requiereAccion;

  /// URL o acción específica a ejecutar al tocar la notificación
  final String? accion;

  /// Si la notificación puede ser cancelada por el usuario
  final bool cancelable;

  /// Fecha de expiración de la notificación
  final DateTime? fechaExpiracion;

  const NotificationEntity({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.estado,
    required this.canal,
    required this.fechaCreacion,
    this.citaId,
    this.terapeutaId,
    this.reporteId,
    this.datosAdicionales,
    this.fechaProgramada,
    this.fechaEnvio,
    this.fechaLectura,
    this.intentosEnvio = 0,
    this.mensajeError,
    this.requiereAccion = false,
    this.accion,
    this.cancelable = true,
    this.fechaExpiracion,
  });

  /// Crea una copia de la notificación con campos actualizados
  NotificationEntity copyWith({
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
    return NotificationEntity(
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

  /// Verifica si la notificación está leída
  bool get esLeida => estado == EstadoNotificacion.leida;

  /// Verifica si la notificación está pendiente
  bool get esPendiente => estado == EstadoNotificacion.pendiente;

  /// Verifica si la notificación ha expirado
  bool get haExpirado {
    if (fechaExpiracion == null) return false;
    return DateTime.now().isAfter(fechaExpiracion!);
  }

  /// Verifica si la notificación es de alta prioridad
  bool get esAltaPrioridad => tipo.prioridad == 1;

  /// Verifica si la notificación está asociada a una cita
  bool get tieneActaAsociada => citaId != null;

  /// Verifica si la notificación está asociada a un terapeuta
  bool get tieneTerapeutaAsociado => terapeutaId != null;

  /// Verifica si la notificación está asociada a un reporte
  bool get tieneReporteAsociado => reporteId != null;

  /// Obtiene el tiempo transcurrido desde la creación
  Duration get tiempoTranscurrido => DateTime.now().difference(fechaCreacion);

  /// Verifica si la notificación puede ser enviada
  bool get puedeSerEnviada {
    if (estado != EstadoNotificacion.pendiente) return false;
    if (haExpirado) return false;
    if (fechaProgramada != null && DateTime.now().isBefore(fechaProgramada!)) {
      return false;
    }
    return true;
  }

  /// Marca la notificación como leída
  NotificationEntity marcarComoLeida() {
    return copyWith(
      estado: EstadoNotificacion.leida,
      fechaLectura: DateTime.now(),
    );
  }

  /// Marca la notificación como enviada
  NotificationEntity marcarComoEnviada() {
    return copyWith(
      estado: EstadoNotificacion.enviada,
      fechaEnvio: DateTime.now(),
    );
  }

  /// Marca la notificación con error
  NotificationEntity marcarConError(String error) {
    return copyWith(
      estado: EstadoNotificacion.error,
      mensajeError: error,
      intentosEnvio: intentosEnvio + 1,
    );
  }

  /// Cancela la notificación
  NotificationEntity cancelar() {
    return copyWith(estado: EstadoNotificacion.cancelada);
  }

  @override
  List<Object?> get props => [
        id,
        usuarioId,
        tipo,
        titulo,
        mensaje,
        estado,
        canal,
        citaId,
        terapeutaId,
        reporteId,
        datosAdicionales,
        fechaCreacion,
        fechaProgramada,
        fechaEnvio,
        fechaLectura,
        intentosEnvio,
        mensajeError,
        requiereAccion,
        accion,
        cancelable,
        fechaExpiracion,
      ];

  @override
  String toString() {
    return 'NotificationEntity(id: $id, tipo: ${tipo.nombre}, titulo: $titulo, estado: ${estado.nombre})';
  }
}

/// Factory para crear notificaciones predefinidas del sistema hospitalario
class NotificationFactory {
  /// Crea una notificación de recordatorio de cita
  static NotificationEntity recordatorioTarot({
    required String usuarioId,
    required String citaId,
    required DateTime fechaActa,
    required String nombreTerapeuta,
    TipoNotificacion tipo = TipoNotificacion.recordatorioTarot,
  }) {
    final String mensaje = tipo == TipoNotificacion.recordatorio2h
        ? 'Su cita con $nombreTerapeuta es en 2 horas. Recuerde llegar 10 minutos antes.'
        : 'Recordatorio: Tiene una cita mañana con $nombreTerapeuta. Recuerde asistir puntualmente.';

    return NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      usuarioId: usuarioId,
      tipo: tipo,
      titulo: tipo.nombre,
      mensaje: mensaje,
      estado: EstadoNotificacion.pendiente,
      canal: CanalNotificacion.push,
      citaId: citaId,
      fechaCreacion: DateTime.now(),
      fechaProgramada: tipo == TipoNotificacion.recordatorio2h
          ? fechaActa.subtract(const Duration(hours: 2))
          : fechaActa.subtract(const Duration(hours: 24)),
      requiereAccion: true,
      accion: '/appointments/details/$citaId',
      fechaExpiracion: fechaActa.add(const Duration(hours: 1)),
    );
  }

  /// Crea una notificación de confirmación de cita
  static NotificationEntity citaConfirmada({
    required String usuarioId,
    required String citaId,
    required DateTime fechaActa,
    required String nombreTerapeuta,
  }) {
    return NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      usuarioId: usuarioId,
      tipo: TipoNotificacion.citaConfirmada,
      titulo: 'Cita Confirmada',
      mensaje: 'Su cita con $nombreTerapeuta ha sido confirmada para el ${_formatearFecha(fechaActa)}.',
      estado: EstadoNotificacion.pendiente,
      canal: CanalNotificacion.push,
      citaId: citaId,
      fechaCreacion: DateTime.now(),
      requiereAccion: true,
      accion: '/appointments/details/$citaId',
    );
  }

  /// Crea una notificación de cancelación de cita
  static NotificationEntity citaCancelada({
    required String usuarioId,
    required String citaId,
    required String razonCancelacion,
  }) {
    return NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      usuarioId: usuarioId,
      tipo: TipoNotificacion.citaCancelada,
      titulo: 'Cita Cancelada',
      mensaje: 'Su cita ha sido cancelada. Motivo: $razonCancelacion. Puede reagendar en cualquier momento.',
      estado: EstadoNotificacion.pendiente,
      canal: CanalNotificacion.push,
      citaId: citaId,
      fechaCreacion: DateTime.now(),
      requiereAccion: true,
      accion: '/appointments/create',
    );
  }

  /// Crea una notificación de reporte generado
  static NotificationEntity reporteGenerado({
    required String usuarioId,
    required String reporteId,
    required String tipoReporte,
  }) {
    return NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      usuarioId: usuarioId,
      tipo: TipoNotificacion.reporteGenerado,
      titulo: 'Reporte Generado',
      mensaje: 'Su reporte de $tipoReporte ha sido generado y está listo para descarga.',
      estado: EstadoNotificacion.pendiente,
      canal: CanalNotificacion.push,
      reporteId: reporteId,
      fechaCreacion: DateTime.now(),
      requiereAccion: true,
      accion: '/reports/viewer/$reporteId',
      fechaExpiracion: DateTime.now().add(const Duration(days: 30)),
    );
  }

  /// Formatea una fecha para mostrar en notificaciones
  static String _formatearFecha(DateTime fecha) {
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} a las ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
} 