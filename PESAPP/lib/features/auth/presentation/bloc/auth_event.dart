import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/user_entity.dart';

/// Evento base de autenticación
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Evento para verificar estado de autenticación
class AuthCheckRequested extends AuthEvent {}

/// Evento para iniciar sesión
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Evento para registrar usuario
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String nombre;
  final String apellido;
  final RolUsuario rol;
  final String? telefono;
  final DateTime? fechaNacimiento;

  AuthSignUpRequested({
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

/// Evento para cerrar sesión
class AuthSignOutRequested extends AuthEvent {}

/// Evento para enviar email de verificación
class AuthSendVerificationEmailRequested extends AuthEvent {}

/// Evento para verificar email
class AuthVerifyEmailRequested extends AuthEvent {
  final String token;

  AuthVerifyEmailRequested({required this.token});

  @override
  List<Object> get props => [token];
}

/// Evento para enviar email de restablecimiento de contraseña
class AuthSendPasswordResetEmailRequested extends AuthEvent {
  final String email;

  AuthSendPasswordResetEmailRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Evento para restablecer contraseña
class AuthResetPasswordRequested extends AuthEvent {
  final String token;
  final String nuevaPassword;

  AuthResetPasswordRequested({
    required this.token,
    required this.nuevaPassword,
  });

  @override
  List<Object> get props => [token, nuevaPassword];
}

/// Evento para cambiar contraseña
class AuthChangePasswordRequested extends AuthEvent {
  final String passwordActual;
  final String nuevaPassword;

  AuthChangePasswordRequested({
    required this.passwordActual,
    required this.nuevaPassword,
  });

  @override
  List<Object> get props => [passwordActual, nuevaPassword];
}

/// Evento para configurar 2FA
class AuthSetup2FARequested extends AuthEvent {}

/// Evento para verificar código 2FA
class AuthVerify2FARequested extends AuthEvent {
  final String codigo;

  AuthVerify2FARequested({required this.codigo});

  @override
  List<Object> get props => [codigo];
}

/// Evento para deshabilitar 2FA
class AuthDisable2FARequested extends AuthEvent {
  final String password;

  AuthDisable2FARequested({required this.password});

  @override
  List<Object> get props => [password];
}

/// Evento para verificar código de recuperación
class AuthVerifyRecoveryCodeRequested extends AuthEvent {
  final String codigo;

  AuthVerifyRecoveryCodeRequested({required this.codigo});

  @override
  List<Object> get props => [codigo];
}

/// Evento para generar nuevos códigos de recuperación
class AuthGenerateRecoveryCodesRequested extends AuthEvent {}

/// Evento para refrescar token
class AuthRefreshTokenRequested extends AuthEvent {}

/// Evento para actualizar perfil
class AuthUpdateProfileRequested extends AuthEvent {
  final String nombre;
  final String apellido;
  final String? telefono;
  final DateTime? fechaNacimiento;
  final String? direccion;
  final String? nombreContactoEmergencia;
  final String? telefonoContactoEmergencia;

  AuthUpdateProfileRequested({
    required this.nombre,
    required this.apellido,
    this.telefono,
    this.fechaNacimiento,
    this.direccion,
    this.nombreContactoEmergencia,
    this.telefonoContactoEmergencia,
  });

  @override
  List<Object?> get props => [
    nombre,
    apellido,
    telefono,
    fechaNacimiento,
    direccion,
    nombreContactoEmergencia,
    telefonoContactoEmergencia,
  ];
}

/// Evento para eliminar cuenta
class AuthDeleteAccountRequested extends AuthEvent {
  final String password;

  AuthDeleteAccountRequested({required this.password});

  @override
  List<Object> get props => [password];
}

/// Evento para validar sesión
class AuthValidateSessionRequested extends AuthEvent {}

/// Evento para limpiar estado
class AuthClearState extends AuthEvent {}

/// Evento para actualizar usuario desde stream
class AuthUserUpdated extends AuthEvent {
  final bool isAuthenticated;

  AuthUserUpdated({required this.isAuthenticated});

  @override
  List<Object> get props => [isAuthenticated];
} 