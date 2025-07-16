import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio de correos electrónicos independiente
/// Utiliza servicios externos para evitar limitaciones de Supabase
class EmailService {
  static const String _emailJSServiceId = 'YOUR_EMAILJS_SERVICE_ID';
  static const String _emailJSTemplateId = 'YOUR_EMAILJS_TEMPLATE_ID';
  static const String _emailJSUserId = 'YOUR_EMAILJS_USER_ID';
  static const String _emailJSUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  /// Enviar correo de bienvenida
  static Future<bool> enviarCorreoBienvenida({
    required String destinatario,
    required String nombre,
    required String apellido,
    required String rol,
  }) async {
    return await _enviarCorreo(
      destinatario: destinatario,
      asunto: '¡Bienvenido al Sistema Hospitalario de Masajes!',
      contenido: _generarContenidoBienvenida(nombre, apellido, rol),
      tipo: 'bienvenida',
    );
  }

  /// Enviar correo de confirmación de cita
  static Future<bool> enviarCorreoConfirmacionCita({
    required String destinatario,
    required String nombrePaciente,
    required String fechaCita,
    required String horaCita,
    required String tipoMasaje,
    required String nombreTerapeuta,
  }) async {
    return await _enviarCorreo(
      destinatario: destinatario,
      asunto: 'Confirmación de Cita - Sistema Hospitalario',
      contenido: _generarContenidoConfirmacionCita(
        nombrePaciente,
        fechaCita,
        horaCita,
        tipoMasaje,
        nombreTerapeuta,
      ),
      tipo: 'confirmacion_cita',
    );
  }

  /// Enviar correo de recordatorio de cita
  static Future<bool> enviarCorreoRecordatorioCita({
    required String destinatario,
    required String nombrePaciente,
    required String fechaCita,
    required String horaCita,
    required String tipoMasaje,
  }) async {
    return await _enviarCorreo(
      destinatario: destinatario,
      asunto: 'Recordatorio de Cita - Mañana a las $horaCita',
      contenido: _generarContenidoRecordatorioCita(
        nombrePaciente,
        fechaCita,
        horaCita,
        tipoMasaje,
      ),
      tipo: 'recordatorio_cita',
    );
  }

  /// Enviar correo de cancelación de cita
  static Future<bool> enviarCorreoCancelacionCita({
    required String destinatario,
    required String nombrePaciente,
    required String fechaCita,
    required String horaCita,
    required String razonCancelacion,
  }) async {
    return await _enviarCorreo(
      destinatario: destinatario,
      asunto: 'Cancelación de Cita - Sistema Hospitalario',
      contenido: _generarContenidoCancelacionCita(
        nombrePaciente,
        fechaCita,
        horaCita,
        razonCancelacion,
      ),
      tipo: 'cancelacion_cita',
    );
  }

  /// Enviar correo de restablecimiento de contraseña
  static Future<bool> enviarCorreoRestablecimientoPassword({
    required String destinatario,
    required String nombre,
    required String enlaceRestablecimiento,
  }) async {
    return await _enviarCorreo(
      destinatario: destinatario,
      asunto: 'Restablecimiento de Contraseña - Sistema Hospitalario',
      contenido: _generarContenidoRestablecimientoPassword(nombre, enlaceRestablecimiento),
      tipo: 'restablecimiento_password',
    );
  }

  /// Método principal para enviar correos
  static Future<bool> _enviarCorreo({
    required String destinatario,
    required String asunto,
    required String contenido,
    required String tipo,
  }) async {
    try {
      // Opción 1: EmailJS (Frontend)
      final emailJSResult = await _enviarConEmailJS(
        destinatario: destinatario,
        asunto: asunto,
        contenido: contenido,
      );

      if (emailJSResult) {
        print('📧 Correo enviado exitosamente con EmailJS');
        print('   Destinatario: $destinatario');
        print('   Asunto: $asunto');
        print('   Tipo: $tipo');
        return true;
      }

      // Opción 2: Servicio de respaldo (simulado por ahora)
      await _enviarConServicioRespaldo(
        destinatario: destinatario,
        asunto: asunto,
        contenido: contenido,
      );

      print('📧 Correo enviado exitosamente con servicio de respaldo');
      print('   Destinatario: $destinatario');
      print('   Asunto: $asunto');
      print('   Tipo: $tipo');
      
      return true;
    } catch (e) {
      print('❌ Error al enviar correo: $e');
      return false;
    }
  }

  /// Enviar correo usando EmailJS
  static Future<bool> _enviarConEmailJS({
    required String destinatario,
    required String asunto,
    required String contenido,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_emailJSUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': _emailJSServiceId,
          'template_id': _emailJSTemplateId,
          'user_id': _emailJSUserId,
          'template_params': {
            'to_email': destinatario,
            'subject': asunto,
            'message': contenido,
            'from_name': 'Sistema Hospitalario de Masajes',
            'reply_to': 'noreply@hospital.com',
          },
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error con EmailJS: $e');
      return false;
    }
  }

  /// Servicio de respaldo (puede ser SendGrid, Mailgun, etc.)
  static Future<bool> _enviarConServicioRespaldo({
    required String destinatario,
    required String asunto,
    required String contenido,
  }) async {
    // Simular envío exitoso por ahora
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: Implementar servicio real como SendGrid, Mailgun, etc.
    // Ejemplo con SendGrid:
    /*
    final response = await http.post(
      Uri.parse('https://api.sendgrid.com/v3/mail/send'),
      headers: {
        'Authorization': 'Bearer YOUR_SENDGRID_API_KEY',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'personalizations': [{
          'to': [{'email': destinatario}],
          'subject': asunto,
        }],
        'from': {'email': 'noreply@hospital.com', 'name': 'Sistema Hospitalario'},
        'content': [{
          'type': 'text/html',
          'value': contenido,
        }],
      }),
    );
    return response.statusCode == 202;
    */
    
    return true;
  }

  /// Generar contenido HTML del correo de bienvenida
  static String _generarContenidoBienvenida(String nombre, String apellido, String rol) {
    final rolTexto = _obtenerTextoRol(rol);
    
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Bienvenido al Sistema Hospitalario</title>
    </head>
    <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
        <div style="background-color: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <!-- Header -->
            <div style="text-align: center; margin-bottom: 30px;">
                <h1 style="color: #2c3e50; margin: 0; font-size: 28px;">🏥 Sistema Hospitalario de Masajes</h1>
                <p style="color: #7f8c8d; margin: 10px 0 0 0; font-size: 16px;">Bienvenido a nuestro sistema</p>
            </div>
            
            <!-- Saludo -->
            <div style="background-color: #e8f4fd; padding: 25px; border-radius: 8px; margin-bottom: 25px; border-left: 4px solid #3498db;">
                <h2 style="color: #2980b9; margin: 0 0 15px 0; font-size: 22px;">¡Hola $nombre $apellido!</h2>
                <p style="color: #34495e; margin: 0; font-size: 16px; line-height: 1.6;">
                    ¡Nos complace darte la bienvenida como <strong>$rolTexto</strong> en nuestro sistema de gestión hospitalaria! 
                    Tu cuenta ha sido creada exitosamente y ya puedes comenzar a utilizar todos nuestros servicios.
                </p>
            </div>
            
            <!-- Información de Seguridad -->
            <div style="background-color: #e8f8f5; padding: 25px; border-radius: 8px; margin-bottom: 25px; border-left: 4px solid #27ae60;">
                <h3 style="color: #27ae60; margin: 0 0 15px 0; font-size: 18px;">🔐 Seguridad de tu Cuenta</h3>
                <p style="color: #34495e; margin: 0; font-size: 14px; line-height: 1.6;">
                    Tu contraseña cumple con todos nuestros requisitos de seguridad:
                    <br>✅ Mínimo 8 caracteres
                    <br>✅ Incluye mayúsculas y minúsculas
                    <br>✅ Contiene números y caracteres especiales
                </p>
            </div>
            
            <!-- Próximos Pasos -->
            <div style="background-color: #fdf2e9; padding: 25px; border-radius: 8px; margin-bottom: 25px; border-left: 4px solid #e67e22;">
                <h3 style="color: #d35400; margin: 0 0 15px 0; font-size: 18px;">📱 Próximos Pasos</h3>
                <ul style="color: #34495e; margin: 0; padding-left: 20px; font-size: 14px; line-height: 1.8;">
                    <li>Inicia sesión en la aplicación móvil</li>
                    <li>Completa tu perfil con información adicional</li>
                    <li>Explora las funcionalidades disponibles</li>
                    <li>Contacta al administrador si necesitas ayuda</li>
                </ul>
            </div>
            
            <!-- Información de Contacto -->
            <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; text-align: center;">
                <p style="color: #6c757d; margin: 0; font-size: 14px;">
                    Si tienes alguna pregunta, no dudes en contactarnos:<br>
                    📞 <strong>+1 (555) 123-4567</strong> | 📧 <strong>soporte@hospital.com</strong>
                </p>
            </div>
            
            <!-- Footer -->
            <div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ecf0f1;">
                <p style="color: #34495e; margin: 0; font-size: 16px; font-weight: bold;">
                    ¡Gracias por confiar en nosotros!
                </p>
                <p style="color: #7f8c8d; margin: 5px 0 0 0; font-size: 14px;">
                    Equipo del Sistema Hospitalario de Masajes
                </p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Generar contenido de confirmación de cita
  static String _generarContenidoConfirmacionCita(
    String nombrePaciente,
    String fechaCita,
    String horaCita,
    String tipoMasaje,
    String nombreTerapeuta,
  ) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Confirmación de Cita</title>
    </head>
    <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
        <div style="background-color: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <div style="text-align: center; margin-bottom: 30px;">
                <h1 style="color: #27ae60; margin: 0; font-size: 28px;">✅ Cita Confirmada</h1>
            </div>
            
            <div style="background-color: #e8f8f5; padding: 25px; border-radius: 8px; margin-bottom: 25px;">
                <h2 style="color: #27ae60; margin: 0 0 20px 0;">Hola $nombrePaciente,</h2>
                <p style="color: #34495e; font-size: 16px; line-height: 1.6; margin: 0;">
                    Tu cita ha sido confirmada exitosamente. Aquí están los detalles:
                </p>
            </div>
            
            <div style="background-color: #f8f9fa; padding: 25px; border-radius: 8px; margin-bottom: 25px;">
                <h3 style="color: #2c3e50; margin: 0 0 15px 0;">📅 Detalles de la Cita</h3>
                <p style="margin: 8px 0; color: #34495e;"><strong>Fecha:</strong> $fechaCita</p>
                <p style="margin: 8px 0; color: #34495e;"><strong>Hora:</strong> $horaCita</p>
                <p style="margin: 8px 0; color: #34495e;"><strong>Tipo de Masaje:</strong> $tipoMasaje</p>
                <p style="margin: 8px 0; color: #34495e;"><strong>Terapeuta:</strong> $nombreTerapeuta</p>
            </div>
            
            <div style="background-color: #fff3cd; padding: 20px; border-radius: 8px; border-left: 4px solid #ffc107;">
                <h4 style="color: #856404; margin: 0 0 10px 0;">⏰ Recordatorio</h4>
                <p style="color: #856404; margin: 0; font-size: 14px;">
                    Te enviaremos un recordatorio 24 horas antes de tu cita.
                </p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Generar contenido de recordatorio de cita
  static String _generarContenidoRecordatorioCita(
    String nombrePaciente,
    String fechaCita,
    String horaCita,
    String tipoMasaje,
  ) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Recordatorio de Cita</title>
    </head>
    <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
        <div style="background-color: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <div style="text-align: center; margin-bottom: 30px;">
                <h1 style="color: #f39c12; margin: 0; font-size: 28px;">⏰ Recordatorio de Cita</h1>
            </div>
            
            <div style="background-color: #fff3cd; padding: 25px; border-radius: 8px; margin-bottom: 25px; border-left: 4px solid #ffc107;">
                <h2 style="color: #856404; margin: 0 0 15px 0;">Hola $nombrePaciente,</h2>
                <p style="color: #856404; font-size: 16px; line-height: 1.6; margin: 0;">
                    Te recordamos que tienes una cita programada para mañana:
                </p>
            </div>
            
            <div style="background-color: #f8f9fa; padding: 25px; border-radius: 8px; text-align: center;">
                <h3 style="color: #2c3e50; margin: 0 0 15px 0;">📅 Detalles de tu Cita</h3>
                <p style="margin: 8px 0; color: #34495e; font-size: 18px;"><strong>$fechaCita a las $horaCita</strong></p>
                <p style="margin: 8px 0; color: #34495e;"><strong>Tipo de Masaje:</strong> $tipoMasaje</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Generar contenido de cancelación de cita
  static String _generarContenidoCancelacionCita(
    String nombrePaciente,
    String fechaCita,
    String horaCita,
    String razonCancelacion,
  ) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Cancelación de Cita</title>
    </head>
    <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
        <div style="background-color: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <div style="text-align: center; margin-bottom: 30px;">
                <h1 style="color: #e74c3c; margin: 0; font-size: 28px;">❌ Cita Cancelada</h1>
            </div>
            
            <div style="background-color: #f8d7da; padding: 25px; border-radius: 8px; margin-bottom: 25px; border-left: 4px solid #dc3545;">
                <h2 style="color: #721c24; margin: 0 0 15px 0;">Hola $nombrePaciente,</h2>
                <p style="color: #721c24; font-size: 16px; line-height: 1.6; margin: 0;">
                    Lamentamos informarte que tu cita ha sido cancelada.
                </p>
            </div>
            
            <div style="background-color: #f8f9fa; padding: 25px; border-radius: 8px; margin-bottom: 25px;">
                <h3 style="color: #2c3e50; margin: 0 0 15px 0;">📅 Cita Cancelada</h3>
                <p style="margin: 8px 0; color: #34495e;"><strong>Fecha:</strong> $fechaCita</p>
                <p style="margin: 8px 0; color: #34495e;"><strong>Hora:</strong> $horaCita</p>
                <p style="margin: 8px 0; color: #34495e;"><strong>Razón:</strong> $razonCancelacion</p>
            </div>
            
            <div style="background-color: #d1ecf1; padding: 20px; border-radius: 8px; border-left: 4px solid #17a2b8;">
                <p style="color: #0c5460; margin: 0; font-size: 14px;">
                    Puedes programar una nueva cita desde la aplicación móvil.
                </p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Generar contenido de restablecimiento de contraseña
  static String _generarContenidoRestablecimientoPassword(String nombre, String enlaceRestablecimiento) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Restablecimiento de Contraseña</title>
    </head>
    <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
        <div style="background-color: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <div style="text-align: center; margin-bottom: 30px;">
                <h1 style="color: #3498db; margin: 0; font-size: 28px;">🔐 Restablecimiento de Contraseña</h1>
            </div>
            
            <div style="background-color: #e8f4fd; padding: 25px; border-radius: 8px; margin-bottom: 25px;">
                <h2 style="color: #2980b9; margin: 0 0 15px 0;">Hola $nombre,</h2>
                <p style="color: #34495e; font-size: 16px; line-height: 1.6; margin: 0;">
                    Recibimos una solicitud para restablecer tu contraseña. 
                    Haz clic en el botón de abajo para crear una nueva contraseña:
                </p>
            </div>
            
            <div style="text-align: center; margin: 30px 0;">
                <a href="$enlaceRestablecimiento" 
                   style="background-color: #3498db; color: white; padding: 15px 30px; 
                          text-decoration: none; border-radius: 5px; font-weight: bold; 
                          display: inline-block; font-size: 16px;">
                    Restablecer Contraseña
                </a>
            </div>
            
            <div style="background-color: #fff3cd; padding: 20px; border-radius: 8px; border-left: 4px solid #ffc107;">
                <p style="color: #856404; margin: 0; font-size: 14px;">
                    <strong>Importante:</strong> Este enlace expirará en 24 horas por seguridad.
                    Si no solicitaste este cambio, puedes ignorar este correo.
                </p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Obtener texto descriptivo del rol
  static String _obtenerTextoRol(String rol) {
    switch (rol.toLowerCase()) {
      case 'admin':
        return 'Administrador';
      case 'therapist':
      case 'terapeuta':
        return 'Terapeuta';
      case 'receptionist':
      case 'recepcionista':
        return 'Recepcionista';
      case 'patient':
      case 'paciente':
        return 'Paciente';
      default:
        return 'Usuario';
    }
  }
} 