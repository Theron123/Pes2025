import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/user_entity.dart';

/// Entidad de usuario autenticado que extiende la información básica del usuario
/// con datos específicos de autenticación
class UsuarioAutenticadoEntity extends Equatable {
  final String id;
  final String email;
  final UsuarioEntity? perfil;
  final bool emailVerificado;
  final String? tokenAcceso;
  final String? tokenRefresh;
  final DateTime? expiraEn;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  final Map<String, dynamic>? metadatos;

  const UsuarioAutenticadoEntity({
    required this.id,
    required this.email,
    this.perfil,
    required this.emailVerificado,
    this.tokenAcceso,
    this.tokenRefresh,
    this.expiraEn,
    required this.creadoEn,
    required this.actualizadoEn,
    this.metadatos,
  });

  /// Verificar si el usuario está completamente autenticado
  bool get estaAutenticado => tokenAcceso != null && !tokenExpirado;

  /// Verificar si el token de acceso ha expirado
  bool get tokenExpirado {
    if (expiraEn == null) return false;
    return DateTime.now().isAfter(expiraEn!);
  }

  /// Verificar si el usuario tiene perfil completo
  bool get tienePerfilCompleto => perfil != null;

  /// Obtener el rol del usuario (si tiene perfil)
  RolUsuario? get rol => perfil?.rol;

  /// Verificar si el usuario es administrador
  bool get esAdmin => perfil?.esAdmin ?? false;

  /// Verificar si el usuario es terapeuta
  bool get esTerapeuta => perfil?.esTerapeuta ?? false;

  /// Verificar si el usuario es recepcionista
  bool get esRecepcionista => perfil?.esRecepcionista ?? false;

  /// Verificar si el usuario es paciente
  bool get esPaciente => perfil?.esPaciente ?? false;

  /// Verificar si el usuario es personal (admin, terapeuta, recepcionista)
  bool get esPersonal => perfil?.esPersonal ?? false;

  /// Verificar si el usuario requiere 2FA
  bool get requiere2FA => perfil?.requiere2FA ?? false;

  /// Obtener el nombre para mostrar
  String get nombreMostrar => perfil?.nombreMostrar ?? email;

  /// Crear una copia con valores actualizados
  UsuarioAutenticadoEntity copyWith({
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
    return UsuarioAutenticadoEntity(
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

  @override
  List<Object?> get props => [
    id,
    email,
    perfil,
    emailVerificado,
    tokenAcceso,
    tokenRefresh,
    expiraEn,
    creadoEn,
    actualizadoEn,
    metadatos,
  ];
}

/// Credenciales de inicio de sesión
class CredencialesEntity extends Equatable {
  final String email;
  final String password;

  const CredencialesEntity({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Datos de registro de usuario
class RegistroUsuarioEntity extends Equatable {
  final String email;
  final String password;
  final String nombre;
  final String apellido;
  final RolUsuario rol;
  final String? telefono;
  final DateTime? fechaNacimiento;

  const RegistroUsuarioEntity({
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellido,
    required this.rol,
    this.telefono,
    this.fechaNacimiento,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    nombre,
    apellido,
    rol,
    telefono,
    fechaNacimiento,
  ];
}

/// Configuración de autenticación de dos factores
class Config2FAEntity extends Equatable {
  final String secreto;
  final String codigoQR;
  final List<String> codigosRecuperacion;

  const Config2FAEntity({
    required this.secreto,
    required this.codigoQR,
    required this.codigosRecuperacion,
  });

  @override
  List<Object> get props => [secreto, codigoQR, codigosRecuperacion];
}

/// Verificación de dos factores
class Verificacion2FAEntity extends Equatable {
  final String codigo;
  final String? codigoRecuperacion;

  const Verificacion2FAEntity({
    required this.codigo,
    this.codigoRecuperacion,
  });

  @override
  List<Object?> get props => [codigo, codigoRecuperacion];
} 