/// API configuration constants for Supabase integration
class ApiConstants {
  // Supabase Configuration - CORRECT CREDENTIALS
  static const String supabaseUrl = 'https://kvcbafrudpznlkcbkbnv.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt2Y2JhZnJ1ZHB6bmxrY2JrYm52Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1OTc1MDMsImV4cCI6MjA2NzE3MzUwM30.VXZM4oPg3XsP-2y3GdmU1M2RSVOWlepPsVxqhqPY9wI';

  // Database Table Names
  static const String usersTable = 'usuarios';
  static const String therapistsTable = 'terapeutas';
  static const String appointmentsTable = 'citas';
  static const String auditLogsTable = 'registros_auditoria';
  static const String notificationsTable = 'notificaciones';

  // Storage Buckets
  static const String profileImagesBucket = 'profile-images';
  static const String reportsBucket = 'reports';
  static const String systemFilesBucket = 'system-files';

  // Edge Functions
  static const String sendNotificationFunction = 'send-appointment-reminders';
  static const String generateReportFunction = 'generate-report';
  static const String auditLogFunction = 'audit-logger';

  // API Response Codes
  static const int successCode = 200;
  static const int createdCode = 201;
  static const int noContentCode = 204;
  static const int badRequestCode = 400;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int conflictCode = 409;
  static const int serverErrorCode = 500;

  // Request Timeouts
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int sendTimeoutSeconds = 30;

  // Headers
  static const String contentTypeJson = 'application/json';
  static const String authHeaderKey = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  // Query Parameters
  static const String selectParam = 'select';
  static const String filterParam = 'filter';
  static const String orderParam = 'order';
  static const String limitParam = 'limit';
  static const String offsetParam = 'offset';

  // File Upload Limits
  static const int maxFileUploadSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  // Realtime Configuration
  static const String realtimeEndpoint = '/realtime/v1';
  static const List<String> realtimeEvents = [
    'INSERT',
    'UPDATE', 
    'DELETE'
  ];

  // Error Messages
  static const String networkErrorMessage = 'Network connection error';
  static const String serverErrorMessage = 'Server error occurred';
  static const String unauthorizedErrorMessage = 'Authentication required';
  static const String forbiddenErrorMessage = 'Access denied';
  static const String notFoundErrorMessage = 'Resource not found';
  static const String validationErrorMessage = 'Data validation failed';

  // Cache Configuration
  static const int cacheTimeoutMinutes = 15;
  static const int maxCacheSize = 50; // Number of cached items

  // Pagination Defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const String defaultOrderBy = 'created_at';
  static const bool defaultAscending = false;
} 