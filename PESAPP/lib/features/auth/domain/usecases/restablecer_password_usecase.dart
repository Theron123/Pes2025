import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para enviar email de restablecimiento de contraseña
class EnviarEmailRestablecimientoUseCase implements UseCase<void, EnviarEmailRestablecimientoParams> {
  final AuthRepository repository;

  const EnviarEmailRestablecimientoUseCase(this.repository);

  @override
  Future<Result<void>> call(EnviarEmailRestablecimientoParams params) async {
    return await repository.enviarEmailRestablecimiento(email: params.email);
  }
}

/// Caso de uso para restablecer contraseña con token
class RestablecerPasswordUseCase implements UseCase<void, RestablecerPasswordParams> {
  final AuthRepository repository;

  const RestablecerPasswordUseCase(this.repository);

  @override
  Future<Result<void>> call(RestablecerPasswordParams params) async {
    return await repository.restablecerPassword(
      token: params.token,
      nuevaPassword: params.nuevaPassword,
    );
  }
}

/// Caso de uso para cambiar contraseña (usuario autenticado)
class CambiarPasswordUseCase implements UseCase<void, CambiarPasswordParams> {
  final AuthRepository repository;

  const CambiarPasswordUseCase(this.repository);

  @override
  Future<Result<void>> call(CambiarPasswordParams params) async {
    return await repository.cambiarPassword(
      passwordActual: params.passwordActual,
      nuevaPassword: params.nuevaPassword,
    );
  }
}

/// Parámetros para enviar email de restablecimiento
class EnviarEmailRestablecimientoParams {
  final String email;

  const EnviarEmailRestablecimientoParams({required this.email});
}

/// Parámetros para restablecer contraseña
class RestablecerPasswordParams {
  final String token;
  final String nuevaPassword;

  const RestablecerPasswordParams({
    required this.token,
    required this.nuevaPassword,
  });
}

/// Parámetros para cambiar contraseña
class CambiarPasswordParams {
  final String passwordActual;
  final String nuevaPassword;

  const CambiarPasswordParams({
    required this.passwordActual,
    required this.nuevaPassword,
  });
} 