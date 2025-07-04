import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/constants/api_constants.dart';

/// Supabase client configuration for Hospital Massage System
class SupabaseConfig {
  static late final SupabaseClient _client;
  static bool _isInitialized = false;

  /// Initialize Supabase client
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
      debug: false, // Set to true for development debugging
    );

    _client = Supabase.instance.client;
    _isInitialized = true;
  }

  /// Get the Supabase client instance
  static SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('Supabase client not initialized. Call SupabaseConfig.initialize() first.');
    }
    return _client;
  }

  /// Check if client is initialized
  static bool get isInitialized => _isInitialized;

  /// Get current user
  static User? get currentUser => _client.auth.currentUser;

  /// Get current session
  static Session? get currentSession => _client.auth.currentSession;

  /// Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  /// Sign out current user
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;

  /// Database client for direct queries
  static SupabaseClient get database => _client;

  /// Storage client for file operations
  static SupabaseStorageClient get storage => _client.storage;

  /// Auth client for authentication operations
  static GoTrueClient get auth => _client.auth;

  /// Realtime client for real-time subscriptions
  static RealtimeClient get realtime => _client.realtime;

  /// Functions client for edge functions
  static FunctionsClient get functions => _client.functions;
}

/// Extension to add hospital-specific helper methods
extension HospitalSupabaseClient on SupabaseClient {
  /// Get users table
  SupabaseQueryBuilder get users => from(ApiConstants.usersTable);

  /// Get therapists table
  SupabaseQueryBuilder get therapists => from(ApiConstants.therapistsTable);

  /// Get appointments table
  SupabaseQueryBuilder get appointments => from(ApiConstants.appointmentsTable);

  /// Get audit logs table
  SupabaseQueryBuilder get auditLogs => from(ApiConstants.auditLogsTable);

  /// Get notifications table
  SupabaseQueryBuilder get notifications => from(ApiConstants.notificationsTable);

  /// Get profile images storage bucket
  StorageFileApi get profileImages => storage.from(ApiConstants.profileImagesBucket);

  /// Get reports storage bucket
  StorageFileApi get reports => storage.from(ApiConstants.reportsBucket);

  /// Get system files storage bucket
  StorageFileApi get systemFiles => storage.from(ApiConstants.systemFilesBucket);

  /// Execute edge function for sending notifications
  Future<FunctionResponse> sendNotificationFunction(Map<String, dynamic> params) {
    return functions.invoke(ApiConstants.sendNotificationFunction, body: params);
  }

  /// Execute edge function for generating reports
  Future<FunctionResponse> generateReportFunction(Map<String, dynamic> params) {
    return functions.invoke(ApiConstants.generateReportFunction, body: params);
  }

  /// Execute edge function for audit logging
  Future<FunctionResponse> auditLogFunction(Map<String, dynamic> params) {
    return functions.invoke(ApiConstants.auditLogFunction, body: params);
  }
}

/// Supabase error handler
class SupabaseErrorHandler {
  /// Convert Supabase error to user-friendly message
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.statusCode) {
        case '400':
          return 'Invalid credentials. Please check your email and password.';
        case '401':
          return 'Authentication failed. Please sign in again.';
        case '403':
          return 'Access denied. You do not have permission to perform this action.';
        case '422':
          return 'Invalid data. Please check your input and try again.';
        case '429':
          return 'Too many requests. Please wait a moment and try again.';
        default:
          return error.message ?? 'Authentication error occurred.';
      }
    }

    if (error is PostgrestException) {
      switch (error.code) {
        case '23505':
          return 'This record already exists.';
        case '23503':
          return 'Cannot delete this record as it is referenced by other data.';
        case '23514':
          return 'Data validation failed. Please check your input.';
        case '42501':
          return 'Insufficient permissions to access this data.';
        default:
          return error.message ?? 'Database error occurred.';
      }
    }

    if (error is StorageException) {
      switch (error.statusCode) {
        case '400':
          return 'Invalid file format or size.';
        case '401':
          return 'Authentication required for file operations.';
        case '403':
          return 'Access denied for file operations.';
        case '413':
          return 'File size exceeds the maximum allowed limit.';
        default:
          return error.message ?? 'File operation error occurred.';
      }
    }

    if (error is FunctionException) {
      return error.details ?? error.reasonPhrase ?? 'Function execution error occurred.';
    }

    // Generic error handling
    if (error.toString().contains('network')) {
      return 'Network connection error. Please check your internet connection.';
    }

    return error.toString().isNotEmpty 
        ? error.toString() 
        : 'An unexpected error occurred. Please try again.';
  }

  /// Check if error is network related
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('socket');
  }

  /// Check if error requires re-authentication
  static bool requiresReAuth(dynamic error) {
    if (error is AuthException) {
      return ['401', '403', 'invalid_token', 'expired_token']
          .contains(error.statusCode ?? error.message);
    }
    return false;
  }
} 