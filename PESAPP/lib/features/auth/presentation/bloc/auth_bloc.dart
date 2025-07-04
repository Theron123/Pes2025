import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/iniciar_sesion_usecase.dart';
import '../../domain/usecases/registrar_usuario_usecase.dart';
import '../../domain/usecases/cerrar_sesion_usecase.dart';
import '../../domain/usecases/obtener_usuario_actual_usecase.dart';
import '../../domain/usecases/configurar_2fa_usecase.dart';
import '../../domain/usecases/restablecer_password_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC principal de autenticación
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IniciarSesionUseCase iniciarSesionUseCase;
  final RegistrarUsuarioUseCase registrarUsuarioUseCase;
  final CerrarSesionUseCase cerrarSesionUseCase;
  final ObtenerUsuarioActualUseCase obtenerUsuarioActualUseCase;
  final Configurar2FAUseCase configurar2FAUseCase;
  final Verificar2FAUseCase verificar2FAUseCase;
  final Deshabilitar2FAUseCase deshabilitar2FAUseCase;
  final EnviarEmailRestablecimientoUseCase enviarEmailRestablecimientoUseCase;
  final RestablecerPasswordUseCase restablecerPasswordUseCase;
  final CambiarPasswordUseCase cambiarPasswordUseCase;
  final AuthRepository authRepository;

  StreamSubscription<dynamic>? _authStateSubscription;

  AuthBloc({
    required this.iniciarSesionUseCase,
    required this.registrarUsuarioUseCase,
    required this.cerrarSesionUseCase,
    required this.obtenerUsuarioActualUseCase,
    required this.configurar2FAUseCase,
    required this.verificar2FAUseCase,
    required this.deshabilitar2FAUseCase,
    required this.enviarEmailRestablecimientoUseCase,
    required this.restablecerPasswordUseCase,
    required this.cambiarPasswordUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    // Registrar manejadores de eventos
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthSendVerificationEmailRequested>(_onAuthSendVerificationEmailRequested);
    on<AuthVerifyEmailRequested>(_onAuthVerifyEmailRequested);
    on<AuthSendPasswordResetEmailRequested>(_onAuthSendPasswordResetEmailRequested);
    on<AuthResetPasswordRequested>(_onAuthResetPasswordRequested);
    on<AuthChangePasswordRequested>(_onAuthChangePasswordRequested);
    on<AuthSetup2FARequested>(_onAuthSetup2FARequested);
    on<AuthVerify2FARequested>(_onAuthVerify2FARequested);
    on<AuthDisable2FARequested>(_onAuthDisable2FARequested);
    on<AuthVerifyRecoveryCodeRequested>(_onAuthVerifyRecoveryCodeRequested);
    on<AuthGenerateRecoveryCodesRequested>(_onAuthGenerateRecoveryCodesRequested);
    on<AuthRefreshTokenRequested>(_onAuthRefreshTokenRequested);
    on<AuthUpdateProfileRequested>(_onAuthUpdateProfileRequested);
    on<AuthDeleteAccountRequested>(_onAuthDeleteAccountRequested);
    on<AuthValidateSessionRequested>(_onAuthValidateSessionRequested);
    on<AuthClearState>(_onAuthClearState);
    on<AuthUserUpdated>(_onAuthUserUpdated);

    // Escuchar cambios de estado de autenticación
    _authStateSubscription = authRepository.streamEstadoAuth.listen(
      (usuario) {
        add(AuthUserUpdated(isAuthenticated: usuario != null));
      },
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  /// Verificar estado de autenticación
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await obtenerUsuarioActualUseCase.call();
    
    if (result.isSuccess) {
      final usuario = result.value;
      if (usuario != null) {
        emit(AuthAuthenticated(usuario: usuario));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  /// Iniciar sesión
  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await iniciarSesionUseCase.call(
      IniciarSesionParams(
        email: event.email,
        password: event.password,
      ),
    );

    if (result.isSuccess) {
      emit(AuthAuthenticated(usuario: result.value!));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al iniciar sesión',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Registrar usuario
  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registrarUsuarioUseCase.call(
      RegistrarUsuarioParams(
        email: event.email,
        password: event.password,
        nombre: event.nombre,
        apellido: event.apellido,
        rol: event.rol,
        telefono: event.telefono,
        fechaNacimiento: event.fechaNacimiento,
      ),
    );

    if (result.isSuccess) {
      emit(AuthAuthenticated(usuario: result.value!));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al registrar usuario',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Cerrar sesión
  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await cerrarSesionUseCase.call();

    if (result.isSuccess) {
      emit(AuthUnauthenticated());
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al cerrar sesión',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Enviar email de verificación
  Future<void> _onAuthSendVerificationEmailRequested(
    AuthSendVerificationEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.enviarEmailVerificacion();

    if (result.isSuccess) {
      emit(AuthVerificationEmailSent(
        mensaje: 'Email de verificación enviado exitosamente',
      ));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al enviar email de verificación',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Verificar email
  Future<void> _onAuthVerifyEmailRequested(
    AuthVerifyEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.verificarEmail(token: event.token);

    if (result.isSuccess) {
      emit(AuthEmailVerified(
        mensaje: 'Email verificado exitosamente',
      ));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al verificar email',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Enviar email de restablecimiento de contraseña
  Future<void> _onAuthSendPasswordResetEmailRequested(
    AuthSendPasswordResetEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await enviarEmailRestablecimientoUseCase.call(
      EnviarEmailRestablecimientoParams(email: event.email),
    );

    if (result.isSuccess) {
      emit(AuthPasswordResetEmailSent(
        mensaje: 'Email de restablecimiento enviado exitosamente',
      ));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al enviar email de restablecimiento',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Restablecer contraseña
  Future<void> _onAuthResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await restablecerPasswordUseCase.call(
      RestablecerPasswordParams(
        token: event.token,
        nuevaPassword: event.nuevaPassword,
      ),
    );

    if (result.isSuccess) {
      emit(AuthPasswordResetSuccess(
        mensaje: 'Contraseña restablecida exitosamente',
      ));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al restablecer contraseña',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Cambiar contraseña
  Future<void> _onAuthChangePasswordRequested(
    AuthChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await cambiarPasswordUseCase.call(
      CambiarPasswordParams(
        passwordActual: event.passwordActual,
        nuevaPassword: event.nuevaPassword,
      ),
    );

    if (result.isSuccess) {
      emit(AuthPasswordChanged(
        mensaje: 'Contraseña cambiada exitosamente',
      ));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al cambiar contraseña',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Configurar 2FA
  Future<void> _onAuthSetup2FARequested(
    AuthSetup2FARequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await configurar2FAUseCase.call();

    if (result.isSuccess) {
      emit(Auth2FAConfigured(configuracion: result.value!));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al configurar 2FA',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Verificar 2FA
  Future<void> _onAuthVerify2FARequested(
    AuthVerify2FARequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await verificar2FAUseCase.call(
      Verificar2FAParams(codigo: event.codigo),
    );

    if (result.isSuccess) {
      emit(Auth2FAVerified(
        mensaje: '2FA verificado exitosamente',
      ));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al verificar 2FA',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Deshabilitar 2FA
  Future<void> _onAuthDisable2FARequested(
    AuthDisable2FARequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await deshabilitar2FAUseCase.call(
      Deshabilitar2FAParams(password: event.password),
    );

    if (result.isSuccess) {
      emit(Auth2FADisabled(
        mensaje: '2FA deshabilitado exitosamente',
      ));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al deshabilitar 2FA',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Verificar código de recuperación
  Future<void> _onAuthVerifyRecoveryCodeRequested(
    AuthVerifyRecoveryCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.verificarCodigoRecuperacion(
      codigo: event.codigo,
    );

    if (result.isSuccess) {
      emit(Auth2FAVerified(
        mensaje: 'Código de recuperación verificado exitosamente',
      ));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al verificar código de recuperación',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Generar códigos de recuperación
  Future<void> _onAuthGenerateRecoveryCodesRequested(
    AuthGenerateRecoveryCodesRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.generarCodigosRecuperacion();

    if (result.isSuccess) {
      emit(AuthRecoveryCodesGenerated(codigos: result.value!));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al generar códigos de recuperación',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Refrescar token
  Future<void> _onAuthRefreshTokenRequested(
    AuthRefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.refrescarToken();

    if (result.isSuccess) {
      emit(AuthAuthenticated(usuario: result.value!));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al refrescar token',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Actualizar perfil
  Future<void> _onAuthUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.actualizarPerfil(
      nombre: event.nombre,
      apellido: event.apellido,
      telefono: event.telefono,
      fechaNacimiento: event.fechaNacimiento,
      direccion: event.direccion,
      nombreContactoEmergencia: event.nombreContactoEmergencia,
      telefonoContactoEmergencia: event.telefonoContactoEmergencia,
    );

    if (result.isSuccess) {
      // Obtener usuario actualizado
      final usuarioActualResult = await obtenerUsuarioActualUseCase.call();
      if (usuarioActualResult.isSuccess && usuarioActualResult.value != null) {
        emit(AuthProfileUpdated(
          usuario: usuarioActualResult.value!,
          mensaje: 'Perfil actualizado exitosamente',
        ));
      } else {
        emit(AuthError(
          mensaje: 'Error al obtener perfil actualizado',
        ));
      }
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al actualizar perfil',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Eliminar cuenta
  Future<void> _onAuthDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.eliminarCuenta(password: event.password);

    if (result.isSuccess) {
      emit(AuthAccountDeleted(
        mensaje: 'Cuenta eliminada exitosamente',
      ));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al eliminar cuenta',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Validar sesión
  Future<void> _onAuthValidateSessionRequested(
    AuthValidateSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.verificarSesionValida();

    if (result.isSuccess) {
      emit(AuthSessionValidated(esValida: result.value!));
    } else {
      emit(AuthError(
        mensaje: result.error?.message ?? 'Error al validar sesión',
        codigo: result.error?.code?.toString(),
      ));
    }
  }

  /// Limpiar estado
  void _onAuthClearState(
    AuthClearState event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthInitial());
  }

  /// Actualizar usuario desde stream
  Future<void> _onAuthUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    if (event.isAuthenticated) {
      final result = await obtenerUsuarioActualUseCase.call();
      if (result.isSuccess && result.value != null) {
        emit(AuthAuthenticated(usuario: result.value!));
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }
} 