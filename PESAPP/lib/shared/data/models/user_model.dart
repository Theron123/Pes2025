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

  /// Crear modelo desde JSON (respuesta de Supabase tabla 'users' con columnas en inglés)
  factory UsuarioModel.fromEnglishJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      email: json['email'] as String,
      rol: RolUsuario.values.firstWhere(
        (e) => e.name == _mapRoleFromEnglish(json['role']),
        orElse: () => RolUsuario.paciente,
      ),
      nombre: json['first_name'] as String,
      apellido: json['last_name'] as String,
      telefono: json['phone'] as String?,
      fechaNacimiento: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      direccion: json['address'] as String?,
      nombreContactoEmergencia: json['emergency_contact_name'] as String?,
      telefonoContactoEmergencia: json['emergency_contact_phone'] as String?,
      activo: json['active'] as bool? ?? true,
      requiere2FA: json['requires_2fa'] as bool? ?? false,
      emailVerificado: json['email_verified'] as bool? ?? false,
      creadoEn: DateTime.parse(json['created_at'] as String),
      actualizadoEn: DateTime.parse(json['updated_at'] as String),
      ultimoLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }

  /// Crear modelo desde JSON (respuesta de Supabase tabla 'usuarios' con columnas en español)
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      email: json['email'] as String,
      rol: RolUsuario.values.firstWhere(
        (e) => e.name == _mapRoleFromDatabase(json['rol']),
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

  /// Mapear roles del inglés al español
  static String _mapRoleFromEnglish(String englishRole) {
    switch (englishRole) {
      case 'admin':
        return 'admin';
      case 'therapist':
        return 'terapeuta';
      case 'receptionist':
        return 'recepcionista';
      case 'patient':
        return 'paciente';
      default:
        return 'paciente';
    }
  }

  /// Mapear roles de la base de datos al enum
  static String _mapRoleFromDatabase(String databaseRole) {
    switch (databaseRole) {
      case 'admin':
        return 'admin';
      case 'terapeuta':
        return 'terapeuta';
      case 'recepcionista':
        return 'recepcionista';
      case 'paciente':
        return 'paciente';
      default:
        return 'paciente';
    }
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