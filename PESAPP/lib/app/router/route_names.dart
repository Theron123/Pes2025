/// Route names for navigation in the Hospital Massage System
class RouteNames {
  // Authentication Routes
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String emailVerification = '/email-verification';
  static const String twoFactorAuth = '/two-factor-auth';
  static const String setupTwoFactor = '/setup-two-factor';

  // Main App Routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Profile Routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String emergencyContacts = '/profile/emergency-contacts';
  static const String preferences = '/profile/preferences';
  static const String security = '/profile/security';

  // Appointment Routes
  static const String appointments = '/appointments';
  static const String appointmentDetails = '/appointments/details';
  static const String createAppointment = '/appointments/create';
  static const String editAppointment = '/appointments/edit';
  static const String appointmentHistory = '/appointments/history';
  static const String therapistSchedule = '/appointments/therapist-schedule';

  // Therapist Management Routes (Admin/Receptionist)
  static const String therapists = '/therapists';
  static const String therapistDetails = '/therapists/details';
  static const String therapistProfile = '/therapists/profile';
  static const String therapistAvailability = '/therapists/availability';
  static const String manageTherapist = '/therapists/manage';

  // User Management Routes (Admin only)
  static const String users = '/users';
  static const String userDetails = '/users/details';
  static const String createUser = '/users/create';
  static const String editUser = '/users/edit';
  static const String userRoles = '/users/roles';

  // Notification Routes
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notifications/settings';
  static const String notificationHistory = '/notifications/history';

  // Reporting Routes
  static const String reports = '/reports';
  static const String reportViewer = '/reports/viewer';
  static const String createReport = '/reports/create';
  static const String reportHistory = '/reports/history';
  static const String reportSchedule = '/reports/schedule';

  // Settings Routes
  static const String settings = '/settings';
  static const String appSettings = '/settings/app';
  static const String systemSettings = '/settings/system';
  static const String auditLogs = '/settings/audit-logs';
  static const String dataManagement = '/settings/data';

  // Error and Support Routes
  static const String error = '/error';
  static const String notFound = '/not-found';
  static const String unauthorized = '/unauthorized';
  static const String maintenance = '/maintenance';
  static const String help = '/help';
  static const String about = '/about';

  // Deep Link Routes
  static const String appointmentDeepLink = '/appointment';
  static const String notificationDeepLink = '/notification';
  static const String reportDeepLink = '/report';

  // Route Parameters
  static const String appointmentIdParam = 'appointmentId';
  static const String therapistIdParam = 'therapistId';
  static const String userIdParam = 'userId';
  static const String reportIdParam = 'reportId';
  static const String notificationIdParam = 'notificationId';

  // Helper methods to build routes with parameters
  static String appointmentDetailsPath(String appointmentId) =>
      '$appointmentDetails?$appointmentIdParam=$appointmentId';

  static String editAppointmentPath(String appointmentId) =>
      '$editAppointment?$appointmentIdParam=$appointmentId';

  static String therapistDetailsPath(String therapistId) =>
      '$therapistDetails?$therapistIdParam=$therapistId';

  static String therapistSchedulePath(String therapistId) =>
      '$therapistSchedule?$therapistIdParam=$therapistId';

  static String userDetailsPath(String userId) =>
      '$userDetails?$userIdParam=$userId';

  static String editUserPath(String userId) =>
      '$editUser?$userIdParam=$userId';

  static String reportViewerPath(String reportId) =>
      '$reportViewer?$reportIdParam=$reportId';

  // Route lists for different user roles
  static const List<String> adminRoutes = [
    home,
    dashboard,
    profile,
    appointments,
    therapists,
    users,
    reports,
    settings,
    notifications,
  ];

  static const List<String> therapistRoutes = [
    home,
    dashboard,
    profile,
    appointments,
    notifications,
    reports, // Limited reporting
  ];

  static const List<String> receptionistRoutes = [
    home,
    dashboard,
    profile,
    appointments,
    therapists, // View only
    reports, // Limited reporting
    notifications,
  ];

  static const List<String> patientRoutes = [
    home,
    profile,
    appointments,
    notifications,
  ];

  /// Check if a route is accessible for a given user role
  static bool isRouteAccessible(String route, String userRole) {
    switch (userRole.toLowerCase()) {
      case 'admin':
        return adminRoutes.contains(route) || 
               route.startsWith('/users') || 
               route.startsWith('/settings');
      case 'therapist':
        return therapistRoutes.contains(route) ||
               route.startsWith('/appointments') ||
               route.startsWith('/profile');
      case 'receptionist':
        return receptionistRoutes.contains(route) ||
               route.startsWith('/appointments') ||
               route.startsWith('/therapists') ||
               route.startsWith('/profile');
      case 'patient':
        return patientRoutes.contains(route) ||
               route.startsWith('/appointments') ||
               route.startsWith('/profile');
      default:
        return false;
    }
  }
} 