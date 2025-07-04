import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../shared/domain/entities/user_entity.dart';

/// Caso de uso para registrar usuario
class RegistrarUsuarioUseCase implements UseCase<UsuarioAutenticadoEntity, RegistrarUsuarioParams> {
  final AuthRepository repository;

  const RegistrarUsuarioUseCase(this.repository);

  @override
  Future<Result<UsuarioAutenticadoEntity>> call(RegistrarUsuarioParams params) async {
    return await repository.registrarUsuario(
      email: params.email,
      password: params.password,
      nombre: params.nombre,
      apellido: params.apellido,
      rol: params.rol,
      telefono: params.telefono,
      fechaNacimiento: params.fechaNacimiento,
    );
  }
}

/// Parámetros para registrar usuario
class RegistrarUsuarioParams {
  final String email;
  final String password;
  final String nombre;
  final String apellido;
  final RolUsuario rol;
  final String? telefono;
  final DateTime? fechaNacimiento;

  const RegistrarUsuarioParams({
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellido,
    required this.rol,
    this.telefono,
    this.fechaNacimiento,
  });
} 