import '../../../../shared/domain/entities/therapist_entity.dart';
import '../../../../shared/domain/entities/user_entity.dart';
import '../../../../core/usecases/usecase.dart';

/// Repositorio abstracto para gestión de terapeutas en el sistema hospitalario
abstract class TerapeutasRepository {
  /// Crear un nuevo terapeuta
  /// 
  /// [usuarioId] ID del usuario asociado al terapeuta
  /// [numeroLicencia] Número de licencia profesional único
  /// [especializaciones] Lista de especializaciones del terapeuta
  /// [horariosTrabajo] Horarios de trabajo semanales
  /// [disponible] Estado de disponibilidad inicial
  /// 
  /// Retorna [Result<TerapeutaEntity>] con el terapeuta creado o el error
  Future<Result<TerapeutaEntity>> crearTerapeuta({
    required String usuarioId,
    required String numeroLicencia,
    required List<EspecializacionMasaje> especializaciones,
    required HorariosTrabajo horariosTrabajo,
    bool disponible = true,
  });

  /// Obtener terapeuta por ID
  /// 
  /// [terapeutaId] ID del terapeuta a buscar
  /// 
  /// Retorna [Result<TerapeutaEntity>] con el terapeuta encontrado
  Future<Result<TerapeutaEntity>> obtenerTerapeutaPorId(String terapeutaId);

  /// Obtener terapeuta por ID de usuario
  /// 
  /// [usuarioId] ID del usuario asociado
  /// 
  /// Retorna [Result<TerapeutaEntity>] con el terapeuta encontrado
  Future<Result<TerapeutaEntity>> obtenerTerapeutaPorUsuarioId(String usuarioId);

  /// Obtener todos los terapeutas
  /// 
  /// [disponibleSolo] Si true, solo obtiene terapeutas disponibles
  /// [especializacion] Filtro opcional por especialización
  /// [limite] Número máximo de terapeutas a obtener
  /// [pagina] Página para paginación
  /// 
  /// Retorna [Result<List<TerapeutaEntity>>] con la lista de terapeutas
  Future<Result<List<TerapeutaEntity>>> obtenerTerapeutas({
    bool disponibleSolo = false,
    EspecializacionMasaje? especializacion,
    int limite = 50,
    int pagina = 1,
  });

  /// Obtener terapeutas disponibles para una fecha y hora específica
  /// 
  /// [fechaHora] Fecha y hora específica para verificar disponibilidad
  /// [duracionMinutos] Duración del servicio en minutos
  /// [especializacion] Filtro opcional por especialización
  /// 
  /// Retorna [Result<List<TerapeutaEntity>>] con terapeutas disponibles
  Future<Result<List<TerapeutaEntity>>> obtenerTerapeutasDisponibles({
    required DateTime fechaHora,
    required int duracionMinutos,
    EspecializacionMasaje? especializacion,
  });

  /// Actualizar información del terapeuta
  /// 
  /// [terapeutaId] ID del terapeuta a actualizar
  /// [numeroLicencia] Nuevo número de licencia (opcional)
  /// [especializaciones] Nuevas especializaciones (opcional)
  /// [horariosTrabajo] Nuevos horarios de trabajo (opcional)
  /// [disponible] Nuevo estado de disponibilidad (opcional)
  /// 
  /// Retorna [Result<TerapeutaEntity>] con el terapeuta actualizado
  Future<Result<TerapeutaEntity>> actualizarTerapeuta({
    required String terapeutaId,
    String? numeroLicencia,
    List<EspecializacionMasaje>? especializaciones,
    HorariosTrabajo? horariosTrabajo,
    bool? disponible,
  });

  /// Cambiar estado de disponibilidad del terapeuta
  /// 
  /// [terapeutaId] ID del terapeuta
  /// [disponible] Nuevo estado de disponibilidad
  /// 
  /// Retorna [Result<TerapeutaEntity>] con el terapeuta actualizado
  Future<Result<TerapeutaEntity>> cambiarDisponibilidad({
    required String terapeutaId,
    required bool disponible,
  });

  /// Actualizar horarios de trabajo del terapeuta
  /// 
  /// [terapeutaId] ID del terapeuta
  /// [horariosTrabajo] Nuevos horarios de trabajo
  /// 
  /// Retorna [Result<TerapeutaEntity>] con el terapeuta actualizado
  Future<Result<TerapeutaEntity>> actualizarHorarios({
    required String terapeutaId,
    required HorariosTrabajo horariosTrabajo,
  });

  /// Agregar especialización al terapeuta
  /// 
  /// [terapeutaId] ID del terapeuta
  /// [especializacion] Especialización a agregar
  /// 
  /// Retorna [Result<TerapeutaEntity>] con el terapeuta actualizado
  Future<Result<TerapeutaEntity>> agregarEspecializacion({
    required String terapeutaId,
    required EspecializacionMasaje especializacion,
  });

  /// Eliminar especialización del terapeuta
  /// 
  /// [terapeutaId] ID del terapeuta
  /// [especializacion] Especialización a eliminar
  /// 
  /// Retorna [Result<TerapeutaEntity>] con el terapeuta actualizado
  Future<Result<TerapeutaEntity>> eliminarEspecializacion({
    required String terapeutaId,
    required EspecializacionMasaje especializacion,
  });

  /// Verificar si un terapeuta está disponible
  /// 
  /// [terapeutaId] ID del terapeuta
  /// [fechaHora] Fecha y hora a verificar
  /// [duracionMinutos] Duración del servicio
  /// 
  /// Retorna [Result<bool>] indicando disponibilidad
  Future<Result<bool>> verificarDisponibilidad({
    required String terapeutaId,
    required DateTime fechaHora,
    required int duracionMinutos,
  });

  /// Obtener estadísticas del terapeuta
  /// 
  /// [terapeutaId] ID del terapeuta
  /// [fechaDesde] Fecha inicial para estadísticas
  /// [fechaHasta] Fecha final para estadísticas
  /// 
  /// Retorna [Result<Map<String, dynamic>>] con estadísticas
  Future<Result<Map<String, dynamic>>> obtenerEstadisticasTerapeuta({
    required String terapeutaId,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
  });

  /// Eliminar terapeuta (soft delete - cambiar a inactivo)
  /// 
  /// [terapeutaId] ID del terapeuta a eliminar
  /// 
  /// Retorna [Result<bool>] indicando éxito de la operación
  Future<Result<bool>> eliminarTerapeuta(String terapeutaId);

  /// Buscar terapeutas por texto
  /// 
  /// [textoBusqueda] Texto a buscar en nombre, especialidades, etc.
  /// [disponibleSolo] Si true, solo busca entre terapeutas disponibles
  /// 
  /// Retorna [Result<List<TerapeutaEntity>>] con terapeutas encontrados
  Future<Result<List<TerapeutaEntity>>> buscarTerapeutas({
    required String textoBusqueda,
    bool disponibleSolo = false,
  });

  /// Verificar si número de licencia ya existe
  /// 
  /// [numeroLicencia] Número de licencia a verificar
  /// [terapeutaIdExcluir] ID de terapeuta a excluir de la verificación (para updates)
  /// 
  /// Retorna [Result<bool>] true si ya existe, false si está disponible
  Future<Result<bool>> verificarLicenciaExiste({
    required String numeroLicencia,
    String? terapeutaIdExcluir,
  });
} 