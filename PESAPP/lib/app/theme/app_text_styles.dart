import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Professional typography styles for Hospital Massage System
class AppTextStyles {
  // Base font family - can be customized for hospital branding
  static const String fontFamily = 'System'; // Will use system font for now

  // Display Styles - Large headlines
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  // Headline Styles - Section headers
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  // Title Styles - Screen titles and card headers
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  // Label Styles - Buttons and form labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );

  // Body Styles - Main content text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );

  // Custom Hospital-specific styles

  // App Bar Styles
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    fontFamily: fontFamily,
  );

  // Button Styles
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textOnPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.primaryBlue,
    fontFamily: fontFamily,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.primaryBlue,
    fontFamily: fontFamily,
  );

  // Form Styles
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    fontFamily: fontFamily,
  );

  static const TextStyle inputError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.errorRed,
    fontFamily: fontFamily,
  );

  // Card Styles
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );

  static const TextStyle cardBody = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  // Status Styles
  static const TextStyle statusSuccess = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.successGreen,
    fontFamily: fontFamily,
  );

  static const TextStyle statusWarning = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.warningOrange,
    fontFamily: fontFamily,
  );

  static const TextStyle statusError = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.errorRed,
    fontFamily: fontFamily,
  );

  static const TextStyle statusInfo = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.infoBlue,
    fontFamily: fontFamily,
  );

  // Navigation Styles
  static const TextStyle navigationLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );

  static const TextStyle navigationLabelActive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
    fontFamily: fontFamily,
  );

  // List Item Styles
  static const TextStyle listTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle listSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );

  static const TextStyle listTertiary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    fontFamily: fontFamily,
  );

  // Accessibility Styles
  static const TextStyle accessibilityHigh = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.accessibilityHighContrast,
    fontFamily: fontFamily,
  );

  // Caption and Helper Text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    fontFamily: fontFamily,
  );

  static const TextStyle helper = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );

  // Method to get appointment status text style
  static TextStyle getAppointmentStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return statusSuccess;
      case 'pending':
        return statusWarning;
      case 'canceled':
      case 'no_show':
        return statusError;
      case 'realized':
        return statusInfo;
      default:
        return bodyMedium;
    }
  }

  // Method to get user role text style
  static TextStyle getUserRoleStyle(String role) {
    return bodyMedium.copyWith(
      color: AppColors.getUserRoleColor(role),
      fontWeight: FontWeight.w600,
    );
  }
} 