import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para cerrar sesión
class CerrarSesionUseCase implements NoParamsUseCase<void> {
  final AuthRepository repository;

  const CerrarSesionUseCase(this.repository);

  @override
  Future<Result<void>> call() async {
    return await repository.cerrarSesion();
  }
} 