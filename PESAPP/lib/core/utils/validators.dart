import 'package:formz/formz.dart';

/// Error de validación de email
enum EmailValidationError {
  empty,
  invalid;

  String get message {
    switch (this) {
      case EmailValidationError.empty:
        return 'El correo electrónico es requerido';
      case EmailValidationError.invalid:
        return 'Por favor ingrese un correo electrónico válido';
    }
  }
}

/// Validador de email
class EmailValidator extends FormzInput<String, EmailValidationError> {
  const EmailValidator.pure() : super.pure('');
  const EmailValidator.dirty([super.value = '']) : super.dirty();

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  @override
  EmailValidationError? validator(String? value) {
    if (value?.isEmpty ?? true) return EmailValidationError.empty;
    return _emailRegExp.hasMatch(value!) 
        ? null 
        : EmailValidationError.invalid;
  }
}

/// Error de validación de contraseña
enum PasswordValidationError {
  empty,
  tooShort,
  noUppercase,
  noLowercase,
  noDigit,
  noSpecialChar;

  String get message {
    switch (this) {
      case PasswordValidationError.empty:
        return 'La contraseña es requerida';
      case PasswordValidationError.tooShort:
        return 'La contraseña debe tener al menos 8 caracteres';
      case PasswordValidationError.noUppercase:
        return 'La contraseña debe contener al menos una letra mayúscula';
      case PasswordValidationError.noLowercase:
        return 'La contraseña debe contener al menos una letra minúscula';
      case PasswordValidationError.noDigit:
        return 'La contraseña debe contener al menos un número';
      case PasswordValidationError.noSpecialChar:
        return 'La contraseña debe contener al menos un carácter especial';
    }
  }
}

/// Validador de contraseña
class PasswordValidator extends FormzInput<String, PasswordValidationError> {
  const PasswordValidator.pure() : super.pure('');
  const PasswordValidator.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String? value) {
    if (value?.isEmpty ?? true) return PasswordValidationError.empty;
    if (value!.length < 8) return PasswordValidationError.tooShort;
    if (!value.contains(RegExp(r'[A-Z]'))) return PasswordValidationError.noUppercase;
    if (!value.contains(RegExp(r'[a-z]'))) return PasswordValidationError.noLowercase;
    if (!value.contains(RegExp(r'[0-9]'))) return PasswordValidationError.noDigit;
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return PasswordValidationError.noSpecialChar;
    return null;
  }
}

/// Error de validación de confirmación de contraseña
enum PasswordConfirmationError {
  empty,
  mismatch;

  String get message {
    switch (this) {
      case PasswordConfirmationError.empty:
        return 'La confirmación de contraseña es requerida';
      case PasswordConfirmationError.mismatch:
        return 'Las contraseñas no coinciden';
    }
  }
}

/// Validador de confirmación de contraseña
class PasswordConfirmationValidator extends FormzInput<String, PasswordConfirmationError> {
  final String originalPassword;

  const PasswordConfirmationValidator.pure({this.originalPassword = ''}) : super.pure('');
  const PasswordConfirmationValidator.dirty(String value, {required this.originalPassword}) : super.dirty(value);

  @override
  PasswordConfirmationError? validator(String? value) {
    if (value?.isEmpty ?? true) return PasswordConfirmationError.empty;
    return value == originalPassword ? null : PasswordConfirmationError.mismatch;
  }
}

/// Error de validación de nombre
enum NameValidationError {
  empty,
  tooShort,
  invalid;

  String get message {
    switch (this) {
      case NameValidationError.empty:
        return 'Este campo es requerido';
      case NameValidationError.tooShort:
        return 'Debe tener al menos 2 caracteres';
      case NameValidationError.invalid:
        return 'Solo se permiten letras y espacios';
    }
  }
}

/// Validador de nombre
class NameValidator extends FormzInput<String, NameValidationError> {
  const NameValidator.pure() : super.pure('');
  const NameValidator.dirty([super.value = '']) : super.dirty();

  static final RegExp _nameRegExp = RegExp(r'^[a-zA-ZáéíóúüñÁÉÍÓÚÜÑ\s]+$');

  @override
  NameValidationError? validator(String? value) {
    if (value?.isEmpty ?? true) return NameValidationError.empty;
    if (value!.trim().length < 2) return NameValidationError.tooShort;
    return _nameRegExp.hasMatch(value) ? null : NameValidationError.invalid;
  }
}

/// Error de validación de teléfono
enum PhoneValidationError {
  empty,
  invalid;

  String get message {
    switch (this) {
      case PhoneValidationError.empty:
        return 'El teléfono es requerido';
      case PhoneValidationError.invalid:
        return 'Por favor ingrese un número de teléfono válido';
    }
  }
}

/// Validador de teléfono
class PhoneValidator extends FormzInput<String, PhoneValidationError> {
  const PhoneValidator.pure() : super.pure('');
  const PhoneValidator.dirty([super.value = '']) : super.dirty();

  static final RegExp _phoneRegExp = RegExp(r'^\+?[0-9]{8,15}$');

  @override
  PhoneValidationError? validator(String? value) {
    if (value?.isEmpty ?? true) return PhoneValidationError.empty;
    final cleanValue = value!.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return _phoneRegExp.hasMatch(cleanValue) ? null : PhoneValidationError.invalid;
  }
}

/// Error de validación de código 2FA
enum TwoFactorCodeValidationError {
  empty,
  invalid;

  String get message {
    switch (this) {
      case TwoFactorCodeValidationError.empty:
        return 'El código es requerido';
      case TwoFactorCodeValidationError.invalid:
        return 'El código debe tener 6 dígitos';
    }
  }
}

/// Validador de código 2FA
class TwoFactorCodeValidator extends FormzInput<String, TwoFactorCodeValidationError> {
  const TwoFactorCodeValidator.pure() : super.pure('');
  const TwoFactorCodeValidator.dirty([super.value = '']) : super.dirty();

  @override
  TwoFactorCodeValidationError? validator(String? value) {
    if (value?.isEmpty ?? true) return TwoFactorCodeValidationError.empty;
    final cleanValue = value!.replaceAll(RegExp(r'\s'), '');
    return cleanValue.length == 6 && RegExp(r'^[0-9]{6}$').hasMatch(cleanValue)
        ? null 
        : TwoFactorCodeValidationError.invalid;
  }
} 