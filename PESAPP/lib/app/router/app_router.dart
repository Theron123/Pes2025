import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_constants.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/appointments/presentation/pages/citas_lista_page.dart';
import '../../features/appointments/presentation/pages/crear_cita_page.dart';
import '../../features/appointments/presentation/pages/cita_detalles_page.dart';
import '../../shared/domain/entities/appointment_entity.dart';
import 'route_names.dart';

/// Configuración de rutas de la aplicación usando GoRouter
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: RouteNames.splash,
    redirect: _authGuard,
    routes: [
      // Splash Screen
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: RouteNames.signIn,
        name: 'sign-in',
        builder: (context, state) => const LoginPage(),
      ),
      
      GoRoute(
        path: RouteNames.signUp,
        name: 'sign-up',
        builder: (context, state) => const RegisterPage(),
      ),
      
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      GoRoute(
        path: RouteNames.emailVerification,
        name: 'email-verification',
        builder: (context, state) => const PlaceholderPage(
          title: 'Verificación de Email',
          message: 'Verificación de correo electrónico',
        ),
      ),

      // Main App Routes (Protected)
      GoRoute(
        path: RouteNames.dashboard,
        name: 'dashboard',
        builder: (context, state) => const MainAppScreen(),
      ),
      
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const PlaceholderPage(
          title: 'Perfil',
          message: 'Gestión de perfil de usuario',
        ),
      ),

      // Appointment Routes
      GoRoute(
        path: RouteNames.appointments,
        name: 'appointments',
        builder: (context, state) => const CitasListaPage(),
      ),
      
      GoRoute(
        path: RouteNames.createAppointment,
        name: 'create-appointment',
        builder: (context, state) => const CrearCitaPage(),
      ),
      
      GoRoute(
        path: RouteNames.appointmentDetails,
        name: 'appointment-details',
        builder: (context, state) {
          final cita = state.extra as CitaEntity?;
          if (cita == null) {
            return const ErrorPage(
              error: 'No se encontró la información de la cita',
            );
          }
          return CitaDetallesPage(cita: cita);
        },
      ),
      
      // Placeholder Routes
      GoRoute(
        path: RouteNames.therapists,
        name: 'therapists',
        builder: (context, state) => const PlaceholderPage(
          title: 'Terapeutas',
          message: 'Gestión de terapeutas',
        ),
      ),
      
      GoRoute(
        path: RouteNames.reports,
        name: 'reports',
        builder: (context, state) => const PlaceholderPage(
          title: 'Reportes',
          message: 'Generación de reportes',
        ),
      ),
      
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (context, state) => const PlaceholderPage(
          title: 'Notificaciones',
          message: 'Centro de notificaciones',
        ),
      ),
      
      GoRoute(
        path: RouteNames.users,
        name: 'users',
        builder: (context, state) => const PlaceholderPage(
          title: 'Usuarios',
          message: 'Gestión de usuarios',
        ),
      ),
      
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const PlaceholderPage(
          title: 'Configuración',
          message: 'Configuración del sistema',
        ),
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(
      error: state.error.toString(),
    ),
  );

  /// Guard de autenticación que redirige según el estado del usuario
  static String? _authGuard(BuildContext context, GoRouterState state) {
    // Obtener el BLoC de autenticación
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    
    // Rutas públicas que no requieren autenticación
    final publicRoutes = [
      RouteNames.signIn,
      RouteNames.signUp,
      RouteNames.forgotPassword,
      RouteNames.emailVerification,
      RouteNames.splash,
    ];
    
    // Rutas protegidas que requieren autenticación
    final protectedRoutes = [
      RouteNames.dashboard,
      RouteNames.profile,
      RouteNames.appointments,
      RouteNames.therapists,
      RouteNames.reports,
      RouteNames.notifications,
      RouteNames.users,
      RouteNames.settings,
    ];
    
    final currentPath = state.uri.path;
    
    // Si el estado es inicial o loading, mostrar splash
    if (authState is AuthInitial || authState is AuthLoading) {
      if (currentPath != RouteNames.splash) {
        return RouteNames.splash;
      }
      return null;
    }
    
    // Si estamos en una ruta protegida y no estamos autenticados
    if (protectedRoutes.contains(currentPath) && authState is! AuthAuthenticated) {
      return RouteNames.signIn;
    }
    
    // Si estamos autenticados y tratamos de acceder a rutas públicas
    if (authState is AuthAuthenticated && publicRoutes.contains(currentPath)) {
      return RouteNames.dashboard;
    }
    
    // Verificar permisos de ruta basados en rol del usuario
    if (authState is AuthAuthenticated) {
      final userRole = authState.usuario.rol?.name.toLowerCase() ?? 'patient';
      if (!RouteNames.isRouteAccessible(currentPath, userRole)) {
        return RouteNames.dashboard;
      }
    }
    
    // No redireccionar
    return null;
  }
}

/// Pantalla de splash para mostrar mientras se carga la aplicación
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthStatus();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _checkAuthStatus() {
    // Verificar el estado de autenticación
    context.read<AuthBloc>().add(AuthCheckRequested());
    
    // Después de un delay, navegar según el estado
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          context.go(RouteNames.dashboard);
        } else {
          context.go(RouteNames.signIn);
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo del hospital
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_hospital_rounded,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Título
                    Text(
                      AppConstants.hospitalName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Sistema de Gestión de Masajes',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Indicador de carga
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Pantalla principal de la aplicación
class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Masajes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go(RouteNames.profile),
            tooltip: 'Perfil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bienvenida
                    Text(
                      '¡Bienvenido!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      state.usuario.nombreMostrar,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    if (state.usuario.rol != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withAlpha(100),
                          ),
                        ),
                        child: Text(
                          state.usuario.rol!.nombreMostrar,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Opciones de navegación
                    Expanded(
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is AuthAuthenticated) {
                            final userRole = state.usuario.rol?.name.toLowerCase() ?? 'patient';
                            return GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              children: _buildNavigationCards(context, userRole),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  List<Widget> _buildNavigationCards(BuildContext context, String userRole) {
    final cards = <Widget>[];
    
    // Citas - Disponible para todos los roles
    cards.add(_buildNavigationCard(
      context,
      'Citas',
      'Gestionar citas médicas',
      Icons.calendar_today,
      RouteNames.appointments,
    ));
    
    // Terapeutas - Disponible para admin y recepcionista
    if (userRole == 'admin' || userRole == 'receptionist') {
      cards.add(_buildNavigationCard(
        context,
        'Terapeutas',
        'Gestionar terapeutas',
        Icons.people,
        RouteNames.therapists,
      ));
    }
    
    // Usuarios - Solo para administradores
    if (userRole == 'admin') {
      cards.add(_buildNavigationCard(
        context,
        'Usuarios',
        'Gestionar usuarios',
        Icons.person_add,
        RouteNames.users,
      ));
    }
    
    // Reportes - Disponible para admin, therapist y receptionist
    if (userRole != 'patient') {
      cards.add(_buildNavigationCard(
        context,
        'Reportes',
        'Generar reportes',
        Icons.analytics,
        RouteNames.reports,
      ));
    }
    
    // Notificaciones - Disponible para todos
    cards.add(_buildNavigationCard(
      context,
      'Notificaciones',
      'Centro de notificaciones',
      Icons.notifications,
      RouteNames.notifications,
    ));
    
    // Configuración - Solo para administradores
    if (userRole == 'admin') {
      cards.add(_buildNavigationCard(
        context,
        'Configuración',
        'Configuración del sistema',
        Icons.settings,
        RouteNames.settings,
      ));
    }
    
    return cards;
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Página placeholder para futuras funcionalidades
class PlaceholderPage extends StatelessWidget {
  final String title;
  final String message;
  
  const PlaceholderPage({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta funcionalidad se implementará en futuras versiones.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.dashboard),
              child: const Text('Volver al Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Página de error para rutas no encontradas
class ErrorPage extends StatelessWidget {
  final String error;
  
  const ErrorPage({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ha ocurrido un error',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.dashboard),
              child: const Text('Volver al Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
} 