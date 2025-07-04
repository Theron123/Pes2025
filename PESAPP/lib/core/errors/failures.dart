import 'package:equatable/equatable.dart';

/// Abstract base class for all failures in the hospital system
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

/// Network/Connection related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
}

/// Authentication related failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required super.message,
    super.code,
  });
}

/// Authorization related failures
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    required super.message,
    super.code,
  });
}

/// Validation related failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

/// Database related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
  });
}

/// File operation failures
class FileFailure extends Failure {
  const FileFailure({
    required super.message,
    super.code,
  });
}

/// Appointment booking related failures
class AppointmentFailure extends Failure {
  const AppointmentFailure({
    required super.message,
    super.code,
  });
}

/// Notification related failures
class NotificationFailure extends Failure {
  const NotificationFailure({
    required super.message,
    super.code,
  });
}

/// Report generation failures
class ReportFailure extends Failure {
  const ReportFailure({
    required super.message,
    super.code,
  });
}

/// Two-factor authentication failures
class TwoFactorAuthFailure extends Failure {
  const TwoFactorAuthFailure({
    required super.message,
    super.code,
  });
}

/// Session timeout failures
class SessionTimeoutFailure extends Failure {
  const SessionTimeoutFailure({
    required super.message,
    super.code,
  });
}

/// Permission denied failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
  });
}

/// Not found failures (for entities that don't exist)
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
  });
}

/// Unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required super.message,
    super.code,
  });
} 