import '../../../../shared/domain/entities/user_entity.dart';
import '../../domain/entities/auth_user_entity.dart';

/// Modelo de datos para usuario autenticado
class UsuarioAutenticadoModel extends UsuarioAutenticadoEntity {
  const UsuarioAutenticadoModel({
    required super.id,
    required super.email,
    super.perfil,
    required super.emailVerificado,
    super.tokenAcceso,
    super.tokenRefresh,
    super.expiraEn,
    required super.creadoEn,
    required super.actualizadoEn,
    super.metadatos,
  });

  /// Crear modelo desde JSON (respuesta de Supabase Auth)
  factory UsuarioAutenticadoModel.fromJson(Map<String, dynamic> json) {
    return UsuarioAutenticadoModel(
      id: json['id'] as String,
      email: json['email'] as String,
      emailVerificado: json['email_confirmed_at'] != null,
      tokenAcceso: json['access_token'] as String?,
      tokenRefresh: json['refresh_token'] as String?,
      expiraEn: json['expires_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((json['expires_at'] as int) * 1000)
          : null,
      creadoEn: DateTime.parse(json['created_at'] as String),
      actualizadoEn: DateTime.parse(json['updated_at'] as String),
      metadatos: json['app_metadata'] as Map<String, dynamic>?,
    );
  }

  /// Crear modelo desde respuesta de Supabase Auth User
  factory UsuarioAutenticadoModel.fromSupabaseUser(
    Map<String, dynamic> user,
    String? accessToken,
    String? refreshToken,
  ) {
    return UsuarioAutenticadoModel(
      id: user['id'] as String,
      email: user['email'] as String,
      emailVerificado: user['email_confirmed_at'] != null,
      tokenAcceso: accessToken,
      tokenRefresh: refreshToken,
      expiraEn: user['expires_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((user['expires_at'] as int) * 1000)
          : null,
      creadoEn: DateTime.parse(user['created_at'] as String),
      actualizadoEn: DateTime.parse(user['updated_at'] as String),
      metadatos: user['app_metadata'] as Map<String, dynamic>?,
    );
  }

  /// Crear modelo con perfil de usuario
  factory UsuarioAutenticadoModel.fromSupabaseUserWithProfile(
    Map<String, dynamic> user,
    String? accessToken,
    String? refreshToken,
    UsuarioEntity? perfil,
  ) {
    return UsuarioAutenticadoModel(
      id: user['id'] as String,
      email: user['email'] as String,
      perfil: perfil,
      emailVerificado: user['email_confirmed_at'] != null,
      tokenAcceso: accessToken,
      tokenRefresh: refreshToken,
      expiraEn: user['expires_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((user['expires_at'] as int) * 1000)
          : null,
      creadoEn: DateTime.parse(user['created_at'] as String),
      actualizadoEn: DateTime.parse(user['updated_at'] as String),
      metadatos: user['app_metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'email_confirmed_at': emailVerificado ? DateTime.now().toIso8601String() : null,
      'access_token': tokenAcceso,
      'refresh_token': tokenRefresh,
      'expires_at': (expiraEn?.millisecondsSinceEpoch ?? 0) ~/ 1000,
      'created_at': creadoEn.toIso8601String(),
      'updated_at': actualizadoEn.toIso8601String(),
      'app_metadata': metadatos,
    };
  }

  /// Crear copia con valores actualizados
  @override
  UsuarioAutenticadoModel copyWith({
    String? id,
    String? email,
    UsuarioEntity? perfil,
    bool? emailVerificado,
    String? tokenAcceso,
    String? tokenRefresh,
    DateTime? expiraEn,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    Map<String, dynamic>? metadatos,
  }) {
    return UsuarioAutenticadoModel(
      id: id ?? this.id,
      email: email ?? this.email,
      perfil: perfil ?? this.perfil,
      emailVerificado: emailVerificado ?? this.emailVerificado,
      tokenAcceso: tokenAcceso ?? this.tokenAcceso,
      tokenRefresh: tokenRefresh ?? this.tokenRefresh,
      expiraEn: expiraEn ?? this.expiraEn,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      metadatos: metadatos ?? this.metadatos,
    );
  }

  /// Convertir a entidad de dominio
  UsuarioAutenticadoEntity toEntity() {
    return UsuarioAutenticadoEntity(
      id: id,
      email: email,
      perfil: perfil,
      emailVerificado: emailVerificado,
      tokenAcceso: tokenAcceso,
      tokenRefresh: tokenRefresh,
      expiraEn: expiraEn,
      creadoEn: creadoEn,
      actualizadoEn: actualizadoEn,
      metadatos: metadatos,
    );
  }
}

/// Modelo de configuración de 2FA
class Config2FAModel extends Config2FAEntity {
  const Config2FAModel({
    required super.secreto,
    required super.codigoQR,
    required super.codigosRecuperacion,
  });

  /// Crear modelo desde JSON
  factory Config2FAModel.fromJson(Map<String, dynamic> json) {
    return Config2FAModel(
      secreto: json['secret'] as String,
      codigoQR: json['qr_code'] as String,
      codigosRecuperacion: (json['recovery_codes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'secret': secreto,
      'qr_code': codigoQR,
      'recovery_codes': codigosRecuperacion,
    };
  }

  /// Convertir a entidad de dominio
  Config2FAEntity toEntity() {
    return Config2FAEntity(
      secreto: secreto,
      codigoQR: codigoQR,
      codigosRecuperacion: codigosRecuperacion,
    );
  }
} 