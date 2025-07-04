import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para configurar autenticación de dos factores
class Configurar2FAUseCase implements NoParamsUseCase<Config2FAEntity> {
  final AuthRepository repository;

  const Configurar2FAUseCase(this.repository);

  @override
  Future<Result<Config2FAEntity>> call() async {
    return await repository.configurar2FA();
  }
}

/// Caso de uso para verificar código de dos factores
class Verificar2FAUseCase implements UseCase<void, Verificar2FAParams> {
  final AuthRepository repository;

  const Verificar2FAUseCase(this.repository);

  @override
  Future<Result<void>> call(Verificar2FAParams params) async {
    return await repository.verificar2FA(codigo: params.codigo);
  }
}

/// Caso de uso para deshabilitar 2FA
class Deshabilitar2FAUseCase implements UseCase<void, Deshabilitar2FAParams> {
  final AuthRepository repository;

  const Deshabilitar2FAUseCase(this.repository);

  @override
  Future<Result<void>> call(Deshabilitar2FAParams params) async {
    return await repository.deshabilitar2FA(password: params.password);
  }
}

/// Parámetros para verificar 2FA
class Verificar2FAParams {
  final String codigo;

  const Verificar2FAParams({required this.codigo});
}

/// Parámetros para deshabilitar 2FA
class Deshabilitar2FAParams {
  final String password;

  const Deshabilitar2FAParams({required this.password});
} 