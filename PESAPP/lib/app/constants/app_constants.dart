/// Application-wide constants for Hospital Massage System
class AppConstants {
  // App Information
  static const String appName = 'Hospital Massage System';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Professional massage therapy appointment management';

  // Hospital Information
  static const String hospitalName = 'Medical Center Massage Workshop';
  static const String hospitalAddress = '123 Healthcare Ave, Medical District';
  static const String hospitalPhone = '+1 (555) 123-4567';
  static const String hospitalEmail = 'massage@hospitalcenter.com';

  // Appointment Constants
  static const int defaultAppointmentDurationMinutes = 60;
  static const int maxAppointmentsPerDay = 12;
  static const int reminderHoursBefore = 24;
  static const int minAdvanceBookingHours = 2;
  static const int maxAdvanceBookingDays = 30;

  // Notification Constants
  static const String notificationChannelId = 'hospital_massage_notifications';
  static const String notificationChannelName = 'Hospital Massage Notifications';
  static const String notificationChannelDescription = 'Notifications for appointment reminders and updates';

  // Security Constants
  static const int sessionTimeoutMinutes = 30;
  static const int maxLoginAttempts = 3;
  static const int passwordMinLength = 8;
  static const int auditDataRetentionYears = 5;

  // Pagination Constants
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Size Limits
  static const int maxProfileImageSizeMB = 5;
  static const int maxReportSizeMB = 10;

  // Date Formats
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'hh:mm a';
  static const String displayDateTimeFormat = 'MMM dd, yyyy - hh:mm a';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiTimeFormat = 'HH:mm:ss';
}

/// User roles in the hospital massage system
enum UserRole {
  admin('admin'),
  therapist('therapist'), 
  receptionist('receptionist'),
  patient('patient');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.patient,
    );
  }
}

/// Appointment status types
enum AppointmentStatus {
  pending('pending'),
  confirmed('confirmed'),
  canceled('canceled'),
  realized('realized'),
  noShow('no_show');

  const AppointmentStatus(this.value);
  final String value;

  static AppointmentStatus fromString(String value) {
    return AppointmentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AppointmentStatus.pending,
    );
  }
}

/// Massage types available in the system
enum MassageType {
  therapeutic('therapeutic'),
  relaxation('relaxation'),
  deepTissue('deep_tissue'),
  sports('sports'),
  prenatal('prenatal'),
  geriatric('geriatric');

  const MassageType(this.value);
  final String value;

  static MassageType fromString(String value) {
    return MassageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MassageType.therapeutic,
    );
  }
}

/// Notification types in the system
enum NotificationType {
  appointmentReminder('appointment_reminder'),
  appointmentConfirmed('appointment_confirmed'),
  appointmentCanceled('appointment_canceled'),
  scheduleUpdate('schedule_update'),
  systemUpdate('system_update');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.systemUpdate,
    );
  }
} 