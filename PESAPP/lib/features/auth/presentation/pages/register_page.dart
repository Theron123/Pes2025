import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/loading_overlay.dart';

/// Pantalla de registro del Sistema Hospitalario de Masajes
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  // Controladores de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  
  // Estado del formulario
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  RolUsuario _selectedRole = RolUsuario.paciente;
  DateTime? _fechaNacimiento;
  
  int _currentStep = 0;
  final int _totalSteps = 3;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submitRegistration();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _emailController.text.isNotEmpty && 
               _passwordController.text.isNotEmpty &&
               _passwordController.text == _confirmPasswordController.text;
      case 1:
        return _nombreController.text.isNotEmpty && 
               _apellidoController.text.isNotEmpty &&
               _telefonoController.text.isNotEmpty &&
               _fechaNacimiento != null;
      case 2:
        return _acceptTerms;
      default:
        return false;
    }
  }

  void _submitRegistration() {
    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        fechaNacimiento: _fechaNacimiento!,
        rol: _selectedRole,
      ),
    );
  }

  void _handleSuccessfulRegistration(BuildContext context) async {
    // Esperar un momento para que el usuario vea el mensaje
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Navegar directamente al LoginPage
    if (context.mounted) {
      context.go(RouteNames.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Registro de Usuario'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Volver',
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.errorRed,
              ),
            );
          } else if (state is AuthRegistrationSuccess) {
            // Mostrar mensaje de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.successGreen,
                duration: const Duration(seconds: 1),
              ),
            );
            
            // Navegar inmediatamente al login sin cerrar sesión
            _handleSuccessfulRegistration(context);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          
          return Stack(
            children: [
              Column(
                children: [
                  _buildProgressIndicator(),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1(),
                        _buildStep2(),
                        _buildStep3(),
                      ],
                    ),
                  ),
                  _buildNavigationButtons(isLoading),
                ],
              ),
              if (isLoading) const LoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: AppColors.primaryBlue,
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              final isActive = index <= _currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'Paso ${_currentStep + 1} de $_totalSteps',
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Credenciales de Acceso',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AuthFormField(
                controller: _emailController,
                label: 'Correo Electrónico',
                hint: 'Ingrese su correo electrónico',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => EmailValidator.dirty(value ?? '').error?.message,
              ),
              const SizedBox(height: 16),
              AuthFormField(
                controller: _passwordController,
                label: 'Contraseña',
                hint: 'Mínimo 8 caracteres',
                prefixIcon: Icons.lock_outline,
                obscureText: !_isPasswordVisible,
                validator: (value) => PasswordValidator.dirty(value ?? '').error?.message,
                onChanged: (value) => setState(() {}), // Actualizar en tiempo real
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
              // Agregar información detallada sobre requisitos de contraseña
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Requisitos de contraseña:',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement(
                          '• Mínimo 8 caracteres',
                          _passwordController.text.length >= 8,
                        ),
                        _buildPasswordRequirement(
                          '• Al menos una letra mayúscula (A-Z)',
                          _passwordController.text.contains(RegExp(r'[A-Z]')),
                        ),
                        _buildPasswordRequirement(
                          '• Al menos una letra minúscula (a-z)',
                          _passwordController.text.contains(RegExp(r'[a-z]')),
                        ),
                        _buildPasswordRequirement(
                          '• Al menos un número (0-9)',
                          _passwordController.text.contains(RegExp(r'[0-9]')),
                        ),
                        _buildPasswordRequirement(
                          '• Al menos un carácter especial (!@#\$%^&*)',
                          _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              AuthFormField(
                controller: _confirmPasswordController,
                label: 'Confirmar Contraseña',
                hint: 'Repita la contraseña',
                prefixIcon: Icons.lock_outline,
                obscureText: !_isConfirmPasswordVisible,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Información Personal',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AuthFormField(
                controller: _nombreController,
                label: 'Nombre',
                hint: 'Ingrese su nombre',
                prefixIcon: Icons.person_outline,
                validator: (value) => value?.isEmpty == true ? 'Nombre requerido' : null,
              ),
              const SizedBox(height: 16),
              AuthFormField(
                controller: _apellidoController,
                label: 'Apellido',
                hint: 'Ingrese su apellido',
                prefixIcon: Icons.person_outline,
                validator: (value) => value?.isEmpty == true ? 'Apellido requerido' : null,
              ),
              const SizedBox(height: 16),
              AuthFormField(
                controller: _telefonoController,
                label: 'Teléfono',
                hint: 'Ej: +1 555 0123',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) => PhoneValidator.dirty(value ?? '').error?.message,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                    firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
                    lastDate: DateTime.now().subtract(const Duration(days: 365 * 12)),
                  );
                  if (date != null) {
                    setState(() => _fechaNacimiento = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined),
                      const SizedBox(width: 12),
                      Text(
                        _fechaNacimiento != null
                            ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                            : 'Fecha de Nacimiento',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AuthFormField(
                controller: _direccionController,
                label: 'Dirección (Opcional)',
                hint: 'Dirección completa',
                prefixIcon: Icons.home_outlined,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Configuración de Cuenta',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Tipo de Usuario',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ...RolUsuario.values.map((rol) => _buildRoleOption(rol)),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                    activeColor: AppColors.primaryBlue,
                  ),
                  Expanded(
                    child: Text(
                      'Acepto los términos y condiciones del Sistema Hospitalario de Masajes',
                      style: AppTextStyles.bodyMedium,
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

  Widget _buildRoleOption(RolUsuario rol) {
    final isSelected = _selectedRole == rol;
    String title, description;
    IconData icon;
    
    switch (rol) {
      case RolUsuario.paciente:
        title = 'Paciente';
        description = 'Reservar y gestionar citas';
        icon = Icons.person;
        break;
      case RolUsuario.recepcionista:
        title = 'Recepcionista';
        description = 'Gestionar citas de pacientes';
        icon = Icons.support_agent;
        break;
      case RolUsuario.terapeuta:
        title = 'Terapeuta';
        description = 'Ver y actualizar mis citas';
        icon = Icons.healing;
        break;
      case RolUsuario.admin:
        title = 'Administrador';
        description = 'Control total del sistema';
        icon = Icons.admin_panel_settings;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedRole = rol),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    Text(description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryBlue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isValid ? AppColors.successGreen : AppColors.textTertiary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: isValid ? AppColors.successGreen : AppColors.textSecondary,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: AuthButton.secondary(
                onPressed: isLoading ? null : _previousStep,
                text: 'Anterior',
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: AuthButton.primary(
              onPressed: isLoading ? null : _nextStep,
              text: _currentStep == _totalSteps - 1 ? 'Crear Cuenta' : 'Siguiente',
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
} 