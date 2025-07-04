import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_user_entity.dart';

/// Estado base de autenticación
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {}

/// Estado de carga
class AuthLoading extends AuthState {}

/// Estado autenticado
class AuthAuthenticated extends AuthState {
  final UsuarioAutenticadoEntity usuario;

  AuthAuthenticated({required this.usuario});

  @override
  List<Object> get props => [usuario];
}

/// Estado no autenticado
class AuthUnauthenticated extends AuthState {}

/// Estado de error
class AuthError extends AuthState {
  final String mensaje;
  final String? codigo;

  AuthError({
    required this.mensaje,
    this.codigo,
  });

  @override
  List<Object?> get props => [mensaje, codigo];
}

/// Estado de email verificado exitosamente
class AuthEmailVerified extends AuthState {
  final String mensaje;

  AuthEmailVerified({required this.mensaje});

  @override
  List<Object> get props => [mensaje];
}

/// Estado de email de verificación enviado
class AuthVerificationEmailSent extends AuthState {
  final String mensaje;

  AuthVerificationEmailSent({required this.mensaje});

  @override
  List<Object> get props => [mensaje];
}

/// Estado de email de restablecimiento enviado
class AuthPasswordResetEmailSent extends AuthState {
  final String mensaje;

  AuthPasswordResetEmailSent({required this.mensaje});

  @override
  List<Object> get props => [mensaje];
}

/// Estado de contraseña restablecida exitosamente
class AuthPasswordResetSuccess extends AuthState {
  final String mensaje;

  AuthPasswordResetSuccess({required this.mensaje});

  @override
  List<Object> get props => [mensaje];
}

/// Estado de contraseña cambiada exitosamente
class AuthPasswordChanged extends AuthState {
  final String mensaje;

  AuthPasswordChanged({required this.mensaje});

  @override
  List<Object> get props => [mensaje];
}

/// Estado de 2FA configurado
class Auth2FAConfigured extends AuthState {
  final Config2FAEntity configuracion;

  Auth2FAConfigured({required this.configuracion});

  @override
  List<Object> get props => [configuracion];
}

/// Estado de 2FA verificado exitosamente
class Auth2FAVerified extends AuthState {
  final String mensaje;

  Auth2FAVerified({required this.mensaje});

  @override
  List<Object> get props => [mensaje];
}

/// Estado de 2FA deshabilitado
class Auth2FADisabled extends AuthState {
  final String mensaje;

  Auth2FADisabled({required this.mensaje});

  @override
  List<Object> get props => [mensaje];
}

/// Estado de códigos de recuperación generados
class AuthRecoveryCodesGenerated extends AuthState {
  final List<String> codigos;

  AuthRecoveryCodesGenerated({required this.codigos});

  @override
  List<Object> get props => [codigos];
}

/// Estado de perfil actualizado
class AuthProfileUpdated extends AuthState {
  final UsuarioAutenticadoEntity usuario;
  final String mensaje;

  AuthProfileUpdated({
    required this.usuario,
    required this.mensaje,
  });

  @override
  List<Object> get props => [usuario, mensaje];
}

/// Estado de cuenta eliminada
class AuthAccountDeleted extends AuthState {
  final String mensaje;

  AuthAccountDeleted({required this.mensaje});

  @override
  List<Object> get props => [mensaje];
}

/// Estado de validación de sesión
class AuthSessionValidated extends AuthState {
  final bool esValida;

  AuthSessionValidated({required this.esValida});

  @override
  List<Object> get props => [esValida];
} 