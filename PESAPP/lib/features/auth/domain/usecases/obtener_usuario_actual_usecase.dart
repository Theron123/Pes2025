import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para obtener usuario actual
class ObtenerUsuarioActualUseCase implements NoParamsUseCase<UsuarioAutenticadoEntity?> {
  final AuthRepository repository;

  const ObtenerUsuarioActualUseCase(this.repository);

  @override
  Future<Result<UsuarioAutenticadoEntity?>> call() async {
    return await repository.obtenerUsuarioActual();
  }
} 