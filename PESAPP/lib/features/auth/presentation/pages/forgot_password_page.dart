import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/loading_overlay.dart';

/// Pantalla de restablecimiento de contraseña
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _sendResetEmail() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSendPasswordResetEmailRequested(
          email: _emailController.text.trim(),
        ),
      );
    }
  }

  void _backToLogin() {
    context.pop();
  }

  void _resendEmail() {
    _sendResetEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primaryBlue,
          ),
          onPressed: _backToLogin,
          tooltip: 'Volver al login',
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.errorRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AuthPasswordResetEmailSent) {
            setState(() => _emailSent = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.successGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Ilustración
                      _buildIllustration(),
                      
                      const SizedBox(height: 32),
                      
                      // Contenido principal
                      if (!_emailSent) ...[
                        _buildRequestForm(isLoading),
                      ] else ...[
                        _buildEmailSentContent(isLoading),
                      ],
                    ],
                  ),
                ),
              ),
              if (isLoading) const LoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIllustration() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryBlue.withOpacity(0.1),
            border: Border.all(
              color: AppColors.primaryBlue,
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.lock_reset_outlined,
            size: 60,
            color: AppColors.primaryBlue,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          _emailSent ? '¡Email Enviado!' : '¿Olvidó su Contraseña?',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          _emailSent 
              ? 'Hemos enviado las instrucciones a su correo'
              : 'No se preocupe, le ayudaremos a recuperarla',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRequestForm(bool isLoading) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Restablecer Contraseña',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Ingrese su correo electrónico y le enviaremos las instrucciones para restablecer su contraseña.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Campo de email
              AuthFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                label: 'Correo Electrónico',
                hint: 'Ingrese su correo registrado',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                required: true,
                validator: (value) => EmailValidator.dirty(value ?? '').error?.message,
                onFieldSubmitted: (_) => _sendResetEmail(),
              ),
              
              const SizedBox(height: 24),
              
              // Botón de envío
              AuthButton.primary(
                onPressed: isLoading ? null : _sendResetEmail,
                text: 'Enviar Instrucciones',
                icon: Icons.send_outlined,
                isLoading: isLoading,
              ),
              
              const SizedBox(height: 16),
              
              // Botón de volver
              AuthButton.secondary(
                onPressed: isLoading ? null : _backToLogin,
                text: 'Volver al Login',
                icon: Icons.arrow_back,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailSentContent(bool isLoading) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.successGreen.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 48,
                    color: AppColors.successGreen,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Revise su Bandeja de Entrada',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Hemos enviado un enlace de restablecimiento a:\n${_emailController.text}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instrucciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoBlueLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.infoBlue.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instrucciones:',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.infoBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '1. Revise su bandeja de entrada\n'
                    '2. Si no encuentra el email, revise la carpeta de spam\n'
                    '3. Haga clic en el enlace del email\n'
                    '4. Siga las instrucciones para crear una nueva contraseña',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botón de reenvío
            AuthButton.secondary(
              onPressed: isLoading ? null : _resendEmail,
              text: 'Reenviar Email',
              icon: Icons.refresh,
              isLoading: isLoading,
            ),
            
            const SizedBox(height: 12),
            
            // Botón de volver
            AuthButton.text(
              onPressed: _backToLogin,
              text: 'Volver al Login',
              icon: Icons.arrow_back,
            ),
          ],
        ),
      ),
    );
  }
} 