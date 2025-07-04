/// Base exception class for the hospital system
abstract class AppException implements Exception {
  final String message;
  final int? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'ServerException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Network/Connection related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'NetworkException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Authentication related exceptions
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'AuthenticationException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Authorization related exceptions
class AuthorizationException extends AppException {
  const AuthorizationException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'AuthorizationException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Validation related exceptions
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'ValidationException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'CacheException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'DatabaseException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// File operation exceptions
class FileException extends AppException {
  const FileException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'FileException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Appointment booking related exceptions
class AppointmentException extends AppException {
  const AppointmentException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'AppointmentException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Notification related exceptions
class NotificationException extends AppException {
  const NotificationException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'NotificationException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Report generation exceptions
class ReportException extends AppException {
  const ReportException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'ReportException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Two-factor authentication exceptions
class TwoFactorAuthException extends AppException {
  const TwoFactorAuthException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'TwoFactorAuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Session timeout exceptions
class SessionTimeoutException extends AppException {
  const SessionTimeoutException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'SessionTimeoutException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Permission denied exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'PermissionException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'TimeoutException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Format exceptions (for data parsing)
class FormatException extends AppException {
  const FormatException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'FormatException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Conflict exceptions (for appointment scheduling conflicts)
class ConflictException extends AppException {
  const ConflictException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'ConflictException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'NotFoundException: $message${code != null ? ' (Code: $code)' : ''}';
} 