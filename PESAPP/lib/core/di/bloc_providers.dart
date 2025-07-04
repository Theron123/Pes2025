import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/domain/entities/auth_user_entity.dart';
import '../../features/appointments/presentation/bloc/citas_bloc.dart';
import 'injection_container.dart' as di;

/// Proveedores BLoC para la aplicación
/// 
/// Configura todos los BLoCs necesarios usando el sistema de inyección de dependencias.
/// Esto permite una gestión centralizada del estado y facilita el testing.
class BlocProviders {
  /// Crea un MultiBlocProvider con todos los BLoCs necesarios
  /// 
  /// Uso:
  /// ```dart
  /// MaterialApp(
  ///   home: BlocProviders.configure(
  ///     child: HomePage(),
  ///   ),
  /// )
  /// ```
  static Widget configure({required Widget child}) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC
        BlocProvider<AuthBloc>(
          create: (context) => _createAuthBloc(),
        ),
        
        // Citas BLoC
        BlocProvider<CitasBloc>(
          create: (context) => di.sl<CitasBloc>(),
        ),
      ],
      child: child,
    );
  }

  /// Crea una instancia del AuthBloc usando el sistema de inyección de dependencias
  static AuthBloc _createAuthBloc() {
    return AuthBloc(
      iniciarSesionUseCase: di.sl(),
      registrarUsuarioUseCase: di.sl(),
      cerrarSesionUseCase: di.sl(),
      obtenerUsuarioActualUseCase: di.sl(),
      configurar2FAUseCase: di.sl(),
      verificar2FAUseCase: di.sl(),
      deshabilitar2FAUseCase: di.sl(),
      enviarEmailRestablecimientoUseCase: di.sl(),
      restablecerPasswordUseCase: di.sl(),
      cambiarPasswordUseCase: di.sl(),
      authRepository: di.sl(),
    );
  }
}

/// Extensión para facilitar el acceso a los BLoCs
/// desde cualquier parte del widget tree
extension BlocProvidersExtension on BuildContext {
  /// Obtiene el AuthBloc del contexto actual
  AuthBloc get authBloc => read<AuthBloc>();
  
  /// Obtiene el estado actual del AuthBloc
  AuthState get authState => read<AuthBloc>().state;
  
  /// Obtiene el CitasBloc del contexto actual
  CitasBloc get citasBloc => read<CitasBloc>();
  
  /// Obtiene el estado actual del CitasBloc
  CitasState get citasState => read<CitasBloc>().state;
  
  /// Verifica si el usuario está autenticado
  bool get isAuthenticated => authState is AuthAuthenticated;
  
  /// Obtiene el usuario autenticado (si existe)
  UsuarioAutenticadoEntity? get currentUser {
    final state = authState;
    if (state is AuthAuthenticated) {
      return state.usuario;
    }
    return null;
  }
  
  /// Verifica si hay citas cargadas en el estado
  bool get hasCitasLoaded => citasState is CitasLoaded;
  
  /// Verifica si las citas están cargando
  bool get isCitasLoading => citasState is CitasLoading;
}

/// Mixin para widgets que necesitan acceso fácil a los BLoCs
/// 
/// Uso:
/// ```dart
/// class MyWidget extends StatelessWidget with BlocAccessMixin {
///   @override
///   Widget build(BuildContext context) {
///     final user = getCurrentUser(context);
///     final citas = getCitasBloc(context);
///     // ...
///   }
/// }
/// ```
mixin BlocAccessMixin {
  /// Obtiene el AuthBloc del contexto
  AuthBloc getAuthBloc(BuildContext context) => context.authBloc;
  
  /// Obtiene el estado actual de autenticación
  AuthState getAuthState(BuildContext context) => context.authState;
  
  /// Obtiene el CitasBloc del contexto
  CitasBloc getCitasBloc(BuildContext context) => context.citasBloc;
  
  /// Obtiene el estado actual de citas
  CitasState getCitasState(BuildContext context) => context.citasState;
  
  /// Verifica si el usuario está autenticado
  bool isAuthenticated(BuildContext context) => context.isAuthenticated;
  
  /// Obtiene el usuario actual
  UsuarioAutenticadoEntity? getCurrentUser(BuildContext context) => context.currentUser;
  
  /// Verifica si hay citas cargadas
  bool hasCitasLoaded(BuildContext context) => context.hasCitasLoaded;
  
  /// Verifica si las citas están cargando
  bool isCitasLoading(BuildContext context) => context.isCitasLoading;
}

/// Configuración de proveedores para testing
/// 
/// Permite crear un entorno de testing con BLoCs mockeados
class TestBlocProviders {
  /// Crea un MultiBlocProvider para testing
  static Widget configure({
    required Widget child,
    AuthBloc? authBloc,
    CitasBloc? citasBloc,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => authBloc ?? _createMockAuthBloc(),
        ),
        BlocProvider<CitasBloc>(
          create: (context) => citasBloc ?? _createMockCitasBloc(),
        ),
      ],
      child: child,
    );
  }

  /// Crea un AuthBloc mockeado para testing
  static AuthBloc _createMockAuthBloc() {
    // Implementación mockeada para testing
    // TODO: Implementar con mockito o similar
    throw UnimplementedError('Mock AuthBloc no implementado');
  }
  
  /// Crea un CitasBloc mockeado para testing
  static CitasBloc _createMockCitasBloc() {
    // Implementación mockeada para testing
    // TODO: Implementar con mockito o similar
    throw UnimplementedError('Mock CitasBloc no implementado');
  }
} 