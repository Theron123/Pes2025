import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Campo de formulario personalizado para autenticación con diseño hospitalario
class AuthFormField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final bool required;

  const AuthFormField({
    super.key,
    this.controller,
    this.focusNode,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta del campo
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.inputLabel,
            children: required
                ? [
                    TextSpan(
                      text: ' *',
                      style: AppTextStyles.inputLabel.copyWith(
                        color: AppColors.errorRed,
                      ),
                    ),
                  ]
                : null,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Campo de texto con accesibilidad
        Semantics(
          label: label,
          hint: hint,
          textField: true,
          obscured: obscureText,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            enabled: enabled,
            maxLines: maxLines,
            maxLength: maxLength,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.inputHint,
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppColors.textSecondary,
                    )
                  : null,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: enabled ? AppColors.backgroundWhite : AppColors.backgroundGray,
              border: _buildBorder(AppColors.borderLight),
              enabledBorder: _buildBorder(AppColors.borderLight),
              focusedBorder: _buildBorder(AppColors.borderFocus),
              errorBorder: _buildBorder(AppColors.errorRed),
              focusedErrorBorder: _buildBorder(AppColors.errorRed),
              disabledBorder: _buildBorder(AppColors.borderLight),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              errorStyle: AppTextStyles.inputError,
              counterStyle: AppTextStyles.bodySmall,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: 1.5,
      ),
    );
  }
} 