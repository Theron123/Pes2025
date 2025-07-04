import 'package:equatable/equatable.dart';

/// Entidad de usuario que representa un usuario en el sistema hospitalario de masajes
/// Esta es la entidad de dominio principal para todos los tipos de usuario
class UsuarioEntity extends Equatable {
  final String id;
  final String email;
  final RolUsuario rol;
  final String nombre;
  final String apellido;
  final String? telefono;
  final DateTime? fechaNacimiento;
  final String? direccion;
  final String? nombreContactoEmergencia;
  final String? telefonoContactoEmergencia;
  final bool activo;
  final bool requiere2FA;
  final bool emailVerificado;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  final DateTime? ultimoLogin;

  const UsuarioEntity({
    required this.id,
    required this.email,
    required this.rol,
    required this.nombre,
    required this.apellido,
    this.telefono,
    this.fechaNacimiento,
    this.direccion,
    this.nombreContactoEmergencia,
    this.telefonoContactoEmergencia,
    required this.activo,
    required this.requiere2FA,
    required this.emailVerificado,
    required this.creadoEn,
    required this.actualizadoEn,
    this.ultimoLogin,
  });

  /// Obtener el nombre completo del usuario
  String get nombreCompleto => '$nombre $apellido';

  /// Obtener el nombre para mostrar (para UI)
  String get nombreMostrar => nombreCompleto;

  /// Obtener las iniciales del usuario (para avatar)
  String get iniciales {
    final primera = nombre.isNotEmpty ? nombre[0].toUpperCase() : '';
    final ultima = apellido.isNotEmpty ? apellido[0].toUpperCase() : '';
    return '$primera$ultima';
  }

  /// Verificar si el usuario ha completado su perfil
  bool get perfilCompleto {
    return telefono != null && 
           fechaNacimiento != null && 
           direccion != null;
  }

  /// Verificar si el usuario tiene información de contacto de emergencia
  bool get tieneContactoEmergencia {
    return nombreContactoEmergencia != null && 
           telefonoContactoEmergencia != null;
  }

  /// Verificar si el usuario puede realizar acciones administrativas
  bool get esAdmin => rol == RolUsuario.admin;

  /// Verificar si el usuario es un terapeuta
  bool get esTerapeuta => rol == RolUsuario.terapeuta;

  /// Verificar si el usuario es un recepcionista
  bool get esRecepcionista => rol == RolUsuario.recepcionista;

  /// Verificar si el usuario es un paciente
  bool get esPaciente => rol == RolUsuario.paciente;

  /// Verificar si el usuario tiene privilegios de personal (admin, terapeuta, recepcionista)
  bool get esPersonal => rol != RolUsuario.paciente;

  /// Verificar si el usuario requiere autenticación de dos factores
  bool get requiereDosFactor => requiere2FA;

  /// Verificar si el email del usuario está verificado
  bool get esEmailVerificado => emailVerificado;

  /// Verificar si la cuenta del usuario está activa
  bool get esCuentaActiva => activo;

  /// Obtener la edad del usuario (si la fecha de nacimiento está disponible)
  int? get edad {
    if (fechaNacimiento == null) return null;
    
    final ahora = DateTime.now();
    final cumpleanos = fechaNacimiento!;
    int edad = ahora.year - cumpleanos.year;
    
    if (ahora.month < cumpleanos.month || 
        (ahora.month == cumpleanos.month && ahora.day < cumpleanos.day)) {
      edad--;
    }
    
    return edad;
  }

  /// Crear una copia de este usuario con valores actualizados
  UsuarioEntity copyWith({
    String? id,
    String? email,
    RolUsuario? rol,
    String? nombre,
    String? apellido,
    String? telefono,
    DateTime? fechaNacimiento,
    String? direccion,
    String? nombreContactoEmergencia,
    String? telefonoContactoEmergencia,
    bool? activo,
    bool? requiere2FA,
    bool? emailVerificado,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    DateTime? ultimoLogin,
  }) {
    return UsuarioEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      telefono: telefono ?? this.telefono,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      direccion: direccion ?? this.direccion,
      nombreContactoEmergencia: nombreContactoEmergencia ?? this.nombreContactoEmergencia,
      telefonoContactoEmergencia: telefonoContactoEmergencia ?? this.telefonoContactoEmergencia,
      activo: activo ?? this.activo,
      requiere2FA: requiere2FA ?? this.requiere2FA,
      emailVerificado: emailVerificado ?? this.emailVerificado,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      ultimoLogin: ultimoLogin ?? this.ultimoLogin,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    rol,
    nombre,
    apellido,
    telefono,
    fechaNacimiento,
    direccion,
    nombreContactoEmergencia,
    telefonoContactoEmergencia,
    activo,
    requiere2FA,
    emailVerificado,
    creadoEn,
    actualizadoEn,
    ultimoLogin,
  ];
}

/// Roles de usuario en el sistema hospitalario de masajes
enum RolUsuario {
  admin,
  terapeuta,
  recepcionista,
  paciente;

  /// Obtener el nombre para mostrar del rol
  String get nombreMostrar {
    switch (this) {
      case RolUsuario.admin:
        return 'Administrador';
      case RolUsuario.terapeuta:
        return 'Terapeuta';
      case RolUsuario.recepcionista:
        return 'Recepcionista';
      case RolUsuario.paciente:
        return 'Paciente';
    }
  }

  /// Obtener la descripción del rol
  String get descripcion {
    switch (this) {
      case RolUsuario.admin:
        return 'Acceso completo al sistema con privilegios administrativos';
      case RolUsuario.terapeuta:
        return 'Terapeuta de masajes licenciado con acceso a tratamiento de pacientes';
      case RolUsuario.recepcionista:
        return 'Personal de recepción con acceso a gestión de citas';
      case RolUsuario.paciente:
        return 'Paciente con acceso a reservas y gestión de perfil';
    }
  }

  /// Obtener el color asociado con el rol
  int get valorColor {
    switch (this) {
      case RolUsuario.admin:
        return 0xFF1976D2; // Azul Primario
      case RolUsuario.terapeuta:
        return 0xFF2196F3; // Azul Secundario
      case RolUsuario.recepcionista:
        return 0xFF42A5F5; // Azul Claro
      case RolUsuario.paciente:
        return 0xFF90CAF9; // Azul Muy Claro
    }
  }

  /// Verificar si el rol requiere autenticación de dos factores
  bool get requiereDosFactor {
    switch (this) {
      case RolUsuario.admin:
      case RolUsuario.terapeuta:
        return true;
      case RolUsuario.recepcionista:
      case RolUsuario.paciente:
        return false;
    }
  }

  /// Verificar si el rol tiene privilegios de personal
  bool get esPersonal {
    switch (this) {
      case RolUsuario.admin:
      case RolUsuario.terapeuta:
      case RolUsuario.recepcionista:
        return true;
      case RolUsuario.paciente:
        return false;
    }
  }

  /// Obtener los permisos predeterminados para el rol
  List<String> get permisosPredeterminados {
    switch (this) {
      case RolUsuario.admin:
        return [
          'ver_todos_usuarios',
          'gestionar_usuarios',
          'ver_todas_citas',
          'gestionar_citas',
          'ver_reportes',
          'generar_reportes',
          'ver_registros_auditoria',
          'gestionar_configuracion_sistema',
          'gestionar_terapeutas',
          'gestionar_notificaciones',
        ];
      case RolUsuario.terapeuta:
        return [
          'ver_propio_perfil',
          'actualizar_propio_perfil',
          'ver_citas_asignadas',
          'actualizar_estado_cita',
          'ver_info_paciente',
          'gestionar_propia_disponibilidad',
          'ver_propios_reportes',
        ];
      case RolUsuario.recepcionista:
        return [
          'ver_propio_perfil',
          'actualizar_propio_perfil',
          'ver_citas',
          'crear_citas',
          'actualizar_citas',
          'ver_disponibilidad_terapeutas',
          'enviar_notificaciones',
        ];
      case RolUsuario.paciente:
        return [
          'ver_propio_perfil',
          'actualizar_propio_perfil',
          'ver_propias_citas',
          'crear_propias_citas',
          'cancelar_propias_citas',
          'ver_lista_terapeutas',
        ];
    }
  }
}

/// Métodos de extensión para RolUsuario
extension RolUsuarioExtension on RolUsuario {
  /// Crear RolUsuario desde string
  static RolUsuario desde(String valor) {
    switch (valor.toLowerCase()) {
      case 'admin':
        return RolUsuario.admin;
      case 'terapeuta':
        return RolUsuario.terapeuta;
      case 'recepcionista':
        return RolUsuario.recepcionista;
      case 'paciente':
        return RolUsuario.paciente;
      default:
        throw ArgumentError('Rol de usuario inválido: $valor');
    }
  }

  /// Convertir RolUsuario a string
  String get valor {
    switch (this) {
      case RolUsuario.admin:
        return 'admin';
      case RolUsuario.terapeuta:
        return 'terapeuta';
      case RolUsuario.recepcionista:
        return 'recepcionista';
      case RolUsuario.paciente:
        return 'paciente';
    }
  }
} 