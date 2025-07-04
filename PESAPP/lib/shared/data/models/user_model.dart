import '../../domain/entities/user_entity.dart';

/// Modelo de datos para usuario
class UsuarioModel extends UsuarioEntity {
  const UsuarioModel({
    required super.id,
    required super.email,
    required super.rol,
    required super.nombre,
    required super.apellido,
    super.telefono,
    super.fechaNacimiento,
    super.direccion,
    super.nombreContactoEmergencia,
    super.telefonoContactoEmergencia,
    required super.activo,
    required super.requiere2FA,
    required super.emailVerificado,
    required super.creadoEn,
    required super.actualizadoEn,
    super.ultimoLogin,
  });

  /// Crear modelo desde JSON (respuesta de Supabase)
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      email: json['email'] as String,
      rol: RolUsuario.values.firstWhere(
        (e) => e.name == json['rol'],
        orElse: () => RolUsuario.paciente,
      ),
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      telefono: json['telefono'] as String?,
      fechaNacimiento: json['fecha_nacimiento'] != null 
          ? DateTime.parse(json['fecha_nacimiento'] as String)
          : null,
      direccion: json['direccion'] as String?,
      nombreContactoEmergencia: json['nombre_contacto_emergencia'] as String?,
      telefonoContactoEmergencia: json['telefono_contacto_emergencia'] as String?,
      activo: json['activo'] as bool? ?? true,
      requiere2FA: json['requiere_2fa'] as bool? ?? false,
      emailVerificado: json['email_verificado'] as bool? ?? false,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      actualizadoEn: DateTime.parse(json['actualizado_en'] as String),
      ultimoLogin: json['ultimo_login'] != null 
          ? DateTime.parse(json['ultimo_login'] as String)
          : null,
    );
  }

  /// Convertir a JSON para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'rol': rol.name,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'direccion': direccion,
      'nombre_contacto_emergencia': nombreContactoEmergencia,
      'telefono_contacto_emergencia': telefonoContactoEmergencia,
      'activo': activo,
      'requiere_2fa': requiere2FA,
      'email_verificado': emailVerificado,
      'creado_en': creadoEn.toIso8601String(),
      'actualizado_en': actualizadoEn.toIso8601String(),
      'ultimo_login': ultimoLogin?.toIso8601String(),
    };
  }

  /// Crear copia con valores actualizados
  UsuarioModel copyWith({
    String? id,
    String? email,
    RolUsuario? rol,
    String? nombre,
    String? apellido,
    String? telefono,
    DateTime? fechaNacimiento,
    String? direccion,
    String? nombreContactoEmergencia,
    String? telefonoContactoEmergencia,
    bool? activo,
    bool? requiere2FA,
    bool? emailVerificado,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    DateTime? ultimoLogin,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      telefono: telefono ?? this.telefono,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      direccion: direccion ?? this.direccion,
      nombreContactoEmergencia: nombreContactoEmergencia ?? this.nombreContactoEmergencia,
      telefonoContactoEmergencia: telefonoContactoEmergencia ?? this.telefonoContactoEmergencia,
      activo: activo ?? this.activo,
      requiere2FA: requiere2FA ?? this.requiere2FA,
      emailVerificado: emailVerificado ?? this.emailVerificado,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      ultimoLogin: ultimoLogin ?? this.ultimoLogin,
    );
  }

  /// Convertir a entidad de dominio
  UsuarioEntity toEntity() {
    return UsuarioEntity(
      id: id,
      email: email,
      rol: rol,
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
      fechaNacimiento: fechaNacimiento,
      direccion: direccion,
      nombreContactoEmergencia: nombreContactoEmergencia,
      telefonoContactoEmergencia: telefonoContactoEmergencia,
      activo: activo,
      requiere2FA: requiere2FA,
      emailVerificado: emailVerificado,
      creadoEn: creadoEn,
      actualizadoEn: actualizadoEn,
      ultimoLogin: ultimoLogin,
    );
  }
} 