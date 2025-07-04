import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/loading_overlay.dart';

/// Página de inicio de sesión del sistema hospitalario
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _onForgotPasswordPressed() {
    context.push(RouteNames.forgotPassword);
  }

  void _onRegisterPressed() {
    context.push(RouteNames.signUp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
          } else if (state is AuthAuthenticated) {
            // Navigation will be handled by app-level auth guard
            context.go(RouteNames.dashboard);
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
                      const SizedBox(height: 60),
                      
                      // Logo y título
                      _buildHeader(),
                      
                      const SizedBox(height: 48),
                      
                      // Formulario de inicio de sesión
                      _buildLoginForm(),
                      
                      const SizedBox(height: 24),
                      
                      // Botones de acción
                      _buildActionButtons(isLoading),
                      
                      const SizedBox(height: 32),
                      
                      // Enlaces de ayuda
                      _buildHelpLinks(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo del hospital
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_hospital_rounded,
            size: 60,
            color: Colors.white,
            semanticLabel: 'Logo del Hospital',
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Título principal
        Text(
          'Sistema Hospitalario\nde Masajes',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Subtítulo
        Text(
          'Inicie sesión para acceder al sistema',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
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
                'Iniciar Sesión',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Campo de email
              AuthFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                label: 'Correo Electrónico',
                hint: 'Ingrese su correo electrónico',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) => EmailValidator.dirty(value ?? '').error?.message,
                onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
              ),
              
              const SizedBox(height: 16),
              
              // Campo de contraseña
              AuthFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                label: 'Contraseña',
                hint: 'Ingrese su contraseña',
                prefixIcon: Icons.lock_outline,
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.done,
                validator: (value) => PasswordValidator.dirty(value ?? '').error?.message,
                onFieldSubmitted: (_) => _onLoginPressed(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible 
                        ? Icons.visibility_off_outlined 
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  tooltip: _isPasswordVisible 
                      ? 'Ocultar contraseña' 
                      : 'Mostrar contraseña',
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Checkbox "Recordarme"
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    activeColor: AppColors.primaryBlue,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _rememberMe = !_rememberMe;
                        });
                      },
                      child: Text(
                        'Recordar mi sesión',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón de iniciar sesión
        AuthButton.primary(
          onPressed: isLoading ? null : _onLoginPressed,
          text: 'Iniciar Sesión',
          isLoading: isLoading,
        ),
        
        const SizedBox(height: 12),
        
        // Botón de registrarse
        AuthButton.secondary(
          onPressed: isLoading ? null : _onRegisterPressed,
          text: 'Crear Nueva Cuenta',
        ),
      ],
    );
  }

  Widget _buildHelpLinks() {
    return Column(
      children: [
        // Enlace de contraseña olvidada
        TextButton(
          onPressed: _onForgotPasswordPressed,
          child: Text(
            '¿Olvidó su contraseña?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Información de contacto
        Text(
          'Para asistencia técnica, contacte al administrador del sistema',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // Footer
        Text(
          '© 2024 Sistema Hospitalario de Masajes\nTodos los derechos reservados',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 