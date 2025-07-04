import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para iniciar sesión
class IniciarSesionUseCase implements UseCase<UsuarioAutenticadoEntity, IniciarSesionParams> {
  final AuthRepository repository;

  const IniciarSesionUseCase(this.repository);

  @override
  Future<Result<UsuarioAutenticadoEntity>> call(IniciarSesionParams params) async {
    return await repository.iniciarSesion(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parámetros para iniciar sesión
class IniciarSesionParams {
  final String email;
  final String password;

  const IniciarSesionParams({
    required this.email,
    required this.password,
  });
} 