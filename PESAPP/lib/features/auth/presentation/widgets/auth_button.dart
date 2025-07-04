import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Botón personalizado para autenticación con diseño hospitalario
class AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;

  const AuthButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
  });

  /// Botón primario (azul)
  const AuthButton.primary({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 56,
  }) : isSecondary = false,
       backgroundColor = null,
       textColor = null;

  /// Botón secundario (outline)
  const AuthButton.secondary({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 56,
  }) : isSecondary = true,
       backgroundColor = null,
       textColor = null;

  /// Botón de texto
  const AuthButton.text({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
  }) : isSecondary = false,
       backgroundColor = Colors.transparent,
       textColor = AppColors.primaryBlue;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;
    
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Semantics(
        button: true,
        enabled: isEnabled,
        label: text,
        child: _buildButton(isEnabled),
      ),
    );
  }

  Widget _buildButton(bool isEnabled) {
    if (backgroundColor == Colors.transparent) {
      // Botón de texto
      return TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primaryBlue,
          disabledForegroundColor: AppColors.textTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildButtonContent(),
      );
    }

    if (isSecondary) {
      // Botón secundario (outline)
      return OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primaryBlue,
          disabledForegroundColor: AppColors.textTertiary,
          backgroundColor: backgroundColor ?? Colors.transparent,
          side: BorderSide(
            color: isEnabled 
                ? AppColors.primaryBlue 
                : AppColors.borderLight,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _buildButtonContent(),
      );
    }

    // Botón primario (relleno)
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor ?? AppColors.textOnPrimary,
        backgroundColor: backgroundColor ?? AppColors.primaryBlue,
        disabledForegroundColor: AppColors.textTertiary,
        disabledBackgroundColor: AppColors.buttonDisabled,
        elevation: isEnabled ? 2 : 0,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: SpinKitRing(
              color: isSecondary 
                  ? AppColors.primaryBlue 
                  : (textColor ?? AppColors.textOnPrimary),
              size: 20,
              lineWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Cargando...',
            style: _getTextStyle(),
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: _getTextStyle(),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyle(),
    );
  }

  TextStyle _getTextStyle() {
    if (backgroundColor == Colors.transparent) {
      return AppTextStyles.buttonText;
    }
    
    return isSecondary 
        ? AppTextStyles.buttonSecondary
        : AppTextStyles.buttonPrimary;
  }
} 