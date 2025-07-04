import 'package:flutter/material.dart';

/// Hospital-themed color palette with professional blue and white scheme
class AppColors {
  // Primary Colors - Medical Blue Theme
  static const Color primaryBlue = Color(0xFF1976D2); // Material Blue 700
  static const Color primaryBlueLight = Color(0xFF42A5F5); // Material Blue 400
  static const Color primaryBlueDark = Color(0xFF0D47A1); // Material Blue 900
  
  // Secondary Colors - Accent Blues
  static const Color secondaryBlue = Color(0xFF2196F3); // Material Blue 500
  static const Color secondaryBlueLight = Color(0xFF90CAF9); // Material Blue 200
  static const Color secondaryBlueDark = Color(0xFF1565C0); // Material Blue 800

  // Specific colors for appointment pages
  static const Color lightBlue = Color(0xFFE3F2FD); // Material Blue 50
  static const Color mediumBlue = Color(0xFF1E88E5); // Material Blue 600
  static const Color darkBlue = Color(0xFF0D47A1); // Material Blue 900

  // Background Colors
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundGray = Color(0xFFF5F5F5);
  static const Color backgroundCard = Color(0xFFFFFFFF);

  // Surface Colors
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Dark Gray
  static const Color textSecondary = Color(0xFF757575); // Medium Gray
  static const Color textTertiary = Color(0xFF9E9E9E); // Light Gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White text on blue
  static const Color textOnSecondary = Color(0xFFFFFFFF); // White text on secondary

  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50); // Material Green 500
  static const Color successGreenLight = Color(0xFFC8E6C9); // Material Green 100
  static const Color warningOrange = Color(0xFFFF9800); // Material Orange 500
  static const Color warningOrangeLight = Color(0xFFFFE0B2); // Material Orange 100
  static const Color errorRed = Color(0xFFF44336); // Material Red 500
  static const Color errorRedLight = Color(0xFFFFCDD2); // Material Red 100
  static const Color infoBlue = Color(0xFF2196F3); // Material Blue 500
  static const Color infoBlueLight = Color(0xFFBBDEFB); // Material Blue 100

  // Appointment Status Colors
  static const Color appointmentPending = Color(0xFFFF9800); // Orange
  static const Color appointmentConfirmed = Color(0xFF4CAF50); // Green
  static const Color appointmentCanceled = Color(0xFFF44336); // Red
  static const Color appointmentRealized = Color(0xFF2196F3); // Blue
  static const Color appointmentNoShow = Color(0xFF9E9E9E); // Gray

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFBDBDBD);
  static const Color borderDark = Color(0xFF757575);
  static const Color borderFocus = Color(0xFF2196F3);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000); // 10% black
  static const Color shadowMedium = Color(0x33000000); // 20% black
  static const Color shadowDark = Color(0x4D000000); // 30% black

  // Accessibility Colors (High Contrast)
  static const Color accessibilityFocus = Color(0xFF0D47A1); // Dark blue for focus
  static const Color accessibilityHighContrast = Color(0xFF000000); // Black for high contrast
  static const Color accessibilityBackground = Color(0xFFFFFF00); // Yellow background for high contrast

  // Interactive Colors
  static const Color buttonPrimary = primaryBlue;
  static const Color buttonPrimaryHover = primaryBlueDark;
  static const Color buttonSecondary = Color(0xFFE3F2FD); // Light blue
  static const Color buttonSecondaryHover = Color(0xFFBBDEFB); // Slightly darker light blue
  static const Color buttonDisabled = Color(0xFFE0E0E0);

  // Medical Professional Colors
  static const Color medicalCross = Color(0xFFE53935); // Medical red
  static const Color medicalClean = Color(0xFFFFFFFF); // Pure white
  static const Color medicalSafe = Color(0xFF4CAF50); // Safety green
  static const Color medicalCaution = Color(0xFFFF9800); // Caution orange

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlueLight, primaryBlue],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundWhite, backgroundLight],
  );

  // Material Color Swatches
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF1976D2,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF2196F3),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );

  // Helper method to get appointment status color
  static Color getAppointmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return appointmentPending;
      case 'confirmed':
        return appointmentConfirmed;
      case 'canceled':
        return appointmentCanceled;
      case 'realized':
        return appointmentRealized;
      case 'no_show':
        return appointmentNoShow;
      default:
        return appointmentPending;
    }
  }

  // Helper method to get user role color
  static Color getUserRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return primaryBlueDark;
      case 'therapist':
        return primaryBlue;
      case 'receptionist':
        return secondaryBlue;
      case 'patient':
        return secondaryBlueLight;
      default:
        return textSecondary;
    }
  }
} 