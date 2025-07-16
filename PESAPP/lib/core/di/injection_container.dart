import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// Core
import '../network/network_info.dart';

// Features - Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/cerrar_sesion_usecase.dart';
import '../../features/auth/domain/usecases/configurar_2fa_usecase.dart';
import '../../features/auth/domain/usecases/iniciar_sesion_usecase.dart';
import '../../features/auth/domain/usecases/obtener_usuario_actual_usecase.dart';
import '../../features/auth/domain/usecases/registrar_usuario_usecase.dart';
import '../../features/auth/domain/usecases/restablecer_password_usecase.dart';

// Features - Appointments (Citas)
import '../../features/appointments/data/datasources/citas_remote_datasource.dart';
import '../../features/appointments/data/repositories/citas_repository_impl.dart';
import '../../features/appointments/domain/repositories/citas_repository.dart';
import '../../features/appointments/domain/usecases/crear_cita_usecase.dart';
import '../../features/appointments/domain/usecases/obtener_citas_por_paciente_usecase.dart';
import '../../features/appointments/domain/usecases/obtener_todas_las_citas_usecase.dart';
import '../../features/appointments/domain/usecases/actualizar_estado_cita_usecase.dart';
import '../../features/appointments/presentation/bloc/citas_bloc.dart';

// Features - Therapists (Terapeutas)
import '../../features/therapists/data/datasources/terapeutas_remote_datasource.dart';
import '../../features/therapists/data/repositories/terapeutas_repository_impl.dart';
import '../../features/therapists/domain/repositories/terapeutas_repository.dart';
import '../../features/therapists/domain/usecases/crear_terapeuta_usecase.dart';
import '../../features/therapists/domain/usecases/obtener_terapeutas_usecase.dart';
import '../../features/therapists/presentation/bloc/terapeutas_bloc.dart';

/// Service Locator - Contenedor de inyección de dependencias
/// 
/// Configura todas las dependencias del sistema usando GetIt como service locator.
/// Sigue el patrón de Clean Architecture para mantener la separación de responsabilidades.
final sl = GetIt.instance;

/// Inicializa todas las dependencias del sistema
/// 
/// Debe ser llamado antes de ejecutar la aplicación.
/// Configura dependencias en el siguiente orden:
/// 1. External (HTTP client, Supabase client)
/// 2. Core (Network info, utilities)
/// 3. Data sources
/// 4. Repositories
/// 5. Use cases
/// 6. BLoCs
Future<void> init() async {
  //! Features - Authentication
  await _initAuth();
  
  //! Features - Appointments (Citas)
  await _initCitas();
  
  //! Features - Therapists (Terapeutas)
  await _initTerapeutas();
  
  //! Core
  await _initCore();
  
  //! External
  await _initExternal();
}

/// Inicializa las dependencias del módulo de autenticación
Future<void> _initAuth() async {
  // Use cases disponibles
  sl.registerLazySingleton(() => IniciarSesionUseCase(sl()));
  sl.registerLazySingleton(() => RegistrarUsuarioUseCase(sl()));
  sl.registerLazySingleton(() => CerrarSesionUseCase(sl()));
  sl.registerLazySingleton(() => ObtenerUsuarioActualUseCase(sl()));
  sl.registerLazySingleton(() => Configurar2FAUseCase(sl()));
  sl.registerLazySingleton(() => Verificar2FAUseCase(sl()));
  sl.registerLazySingleton(() => Deshabilitar2FAUseCase(sl()));
  sl.registerLazySingleton(() => EnviarEmailRestablecimientoUseCase(sl()));
  sl.registerLazySingleton(() => RestablecerPasswordUseCase(sl()));
  sl.registerLazySingleton(() => CambiarPasswordUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      client: sl(),
    ),
  );
}

/// Inicializa las dependencias del módulo de citas
Future<void> _initCitas() async {
  // BLoC - CitasBloc
  sl.registerFactory(
    () => CitasBloc(
      crearCitaUseCase: sl(),
      obtenerCitasPorPacienteUseCase: sl(),
      obtenerTodasLasCitasUseCase: sl(),
      actualizarEstadoCitaUseCase: sl(),
    ),
  );

  // Use cases - Casos de uso del dominio de citas
  sl.registerLazySingleton(() => CrearCitaUseCase(sl()));
  sl.registerLazySingleton(() => ObtenerCitasPorPacienteUseCase(sl()));
  sl.registerLazySingleton(() => ObtenerTodasLasCitasUseCase(sl()));
  sl.registerLazySingleton(() => ActualizarEstadoCitaUseCase(sl()));

  // Repository - Repositorio abstracto y su implementación
  sl.registerLazySingleton<CitasRepository>(
    () => CitasRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources - Fuente de datos remota
  sl.registerLazySingleton<CitasRemoteDataSource>(
    () => CitasRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );
}

/// Inicializa las dependencias del módulo de terapeutas
Future<void> _initTerapeutas() async {
  // BLoC - TerapeutasBloc
  sl.registerFactory(
    () => TerapeutasBloc(
      crearTerapeutaUseCase: sl(),
      obtenerTerapeutasUseCase: sl(),
    ),
  );

  // Use cases - Casos de uso del dominio de terapeutas
  sl.registerLazySingleton(() => CrearTerapeutaUseCase(terapeutasRepository: sl()));
  sl.registerLazySingleton(() => ObtenerTerapeutasUseCase(terapeutasRepository: sl()));

  // Repository - Repositorio abstracto y su implementación
  sl.registerLazySingleton<TerapeutasRepository>(
    () => TerapeutasRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources - Fuente de datos remota
  sl.registerLazySingleton<TerapeutasRemoteDataSource>(
    () => TerapeutasRemoteDataSourceImpl(sl()),
  );
}

/// Inicializa las dependencias del core del sistema
Future<void> _initCore() async {
  // Network info
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(),
  );
}

/// Inicializa las dependencias externas
Future<void> _initExternal() async {
  // HTTP client
  sl.registerLazySingleton(() => http.Client());

  // Supabase client
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );
}

/// Limpia todas las dependencias registradas
/// 
/// Útil para testing y reinicialización del sistema.
Future<void> reset() async {
  await sl.reset();
}

/// Verifica si una dependencia está registrada
/// 
/// Útil para debugging y testing.
bool isRegistered<T extends Object>() {
  return sl.isRegistered<T>();
}

/// Obtiene una instancia de una dependencia registrada
/// 
/// Shortcut para sl.get<T>()
T getIt<T extends Object>() {
  return sl<T>();
}

/// Extensión para facilitar el acceso a las dependencias
/// desde cualquier parte de la aplicación
extension ServiceLocatorExtension on GetIt {
  /// Obtiene el AuthRepository
  AuthRepository get authRepository => this<AuthRepository>();
  
  /// Obtiene el CitasRepository
  CitasRepository get citasRepository => this<CitasRepository>();
  
  /// Obtiene el TerapeutasRepository
  TerapeutasRepository get terapeutasRepository => this<TerapeutasRepository>();
  
  /// Obtiene el CitasBloc (nueva instancia cada vez)
  CitasBloc get citasBloc => this<CitasBloc>();
  
  /// Obtiene el TerapeutasBloc (nueva instancia cada vez)
  TerapeutasBloc get terapeutasBloc => this<TerapeutasBloc>();
  
  /// Obtiene el Supabase client
  SupabaseClient get supabaseClient => this<SupabaseClient>();
  
  /// Obtiene el NetworkInfo
  NetworkInfo get networkInfo => this<NetworkInfo>();
} 