import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/domain/entities/appointment_entity.dart';
import '../bloc/citas_bloc.dart';

/// Página para mostrar los detalles completos de una cita médica
/// 
/// Características:
/// - Información detallada de la cita
/// - Acciones según el estado (cancelar, confirmar, etc.)
/// - Diseño hospitalario profesional
/// - Integración con CitasBloc para acciones
class CitaDetallesPage extends StatelessWidget {
  final CitaEntity cita;

  const CitaDetallesPage({
    super.key,
    required this.cita,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Detalles de Cita',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<CitasBloc, CitasState>(
        listener: (context, state) {
          if (state is CitaActualizada || state is CitaCancelada) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cita actualizada exitosamente'),
                backgroundColor: AppColors.successGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop();
          } else if (state is CitasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.errorRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildEncabezado(),
                const SizedBox(height: 20),
                _buildInformacionPrincipal(),
                const SizedBox(height: 20),
                _buildDetallesAdicionales(),
                const SizedBox(height: 20),
                if (_puedeRealizarAcciones())
                  _buildAcciones(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEncabezado() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue.withOpacity(0.1),
              AppColors.primaryBlueLight.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildEstadoChip(),
            const SizedBox(height: 16),
            Icon(
              Icons.spa,
              size: 48,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 12),
            Text(
              cita.tipoMasaje,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cita ID: ${cita.id}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoChip() {
    final color = _getEstadoColor();
    final texto = _getEstadoTexto();
    final icono = _getEstadoIcono();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformacionPrincipal() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de la Cita',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Fecha
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha',
              _formatearFecha(cita.fechaCita),
            ),
            const SizedBox(height: 12),
            
            // Hora
            _buildInfoRow(
              Icons.access_time,
              'Hora',
              _formatearHora(cita.horaCita),
            ),
            const SizedBox(height: 12),
            
            // Duración
            _buildInfoRow(
              Icons.schedule,
              'Duración',
              '${cita.duracionMinutos} minutos',
            ),
            const SizedBox(height: 12),
            
            // Terapeuta (si está asignado)
            if (cita.terapeutaId != null)
              _buildInfoRow(
                Icons.person,
                'Terapeuta',
                'Terapeuta asignado', // TODO: Obtener nombre del terapeuta
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetallesAdicionales() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles Adicionales',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Notas
            if (cita.notas != null && cita.notas!.isNotEmpty) ...[
              _buildInfoRow(
                Icons.note,
                'Notas',
                cita.notas!,
              ),
              const SizedBox(height: 12),
            ],
            
            // Fecha de creación
            _buildInfoRow(
              Icons.add_circle_outline,
              'Creada el',
              _formatearFechaCompleta(cita.creadoEn),
            ),
            const SizedBox(height: 12),
            
            // Última actualización
            _buildInfoRow(
              Icons.update,
              'Actualizada el',
              _formatearFechaCompleta(cita.actualizadoEn),
            ),
            
            // Información de cancelación si aplica
            if (cita.estado == EstadoCita.cancelada && cita.canceladoEn != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.cancel,
                'Cancelada el',
                _formatearFechaCompleta(cita.canceladoEn!),
              ),
              if (cita.razonCancelacion != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.info_outline,
                  'Razón',
                  cita.razonCancelacion!,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icono, String etiqueta, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icono,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcciones(BuildContext context, CitasState state) {
    final esLoading = state is CitasLoading;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Disponibles',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Botones de acción
            Row(
              children: [
                // Cancelar cita
                if (_puedeCancelar()) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: esLoading ? null : () => _cancelarCita(context),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Cancelar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                
                // Confirmar cita (si es pendiente)
                if (_puedeConfirmar()) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: esLoading ? null : () => _confirmarCita(context),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Confirmar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares
  bool _puedeRealizarAcciones() {
    return _puedeCancelar() || _puedeConfirmar();
  }

  bool _puedeCancelar() {
    final ahora = DateTime.now();
    final doceHorasAntes = cita.horaCita.subtract(const Duration(hours: 2));
    
    return (cita.estado == EstadoCita.pendiente || cita.estado == EstadoCita.confirmada) &&
           ahora.isBefore(doceHorasAntes);
  }

  bool _puedeConfirmar() {
    return cita.estado == EstadoCita.pendiente;
  }

  void _cancelarCita(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: const Text('¿Está seguro que desea cancelar esta cita? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CitasBloc>().add(
                CancelarCitaEvent(
                  citaId: cita.id,
                  usuarioId: 'current-user-id', // TODO: Obtener del contexto
                  razonCancelacion: 'Cancelada por el paciente',
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _confirmarCita(BuildContext context) {
    context.read<CitasBloc>().add(
      ActualizarEstadoCitaEvent(
        citaId: cita.id,
        nuevoEstado: EstadoCita.confirmada,
        usuarioId: 'current-user-id', // TODO: Obtener del contexto
        notas: 'Confirmada por el paciente',
      ),
    );
  }

  Color _getEstadoColor() {
    switch (cita.estado) {
      case EstadoCita.pendiente:
        return Colors.orange;
      case EstadoCita.confirmada:
        return AppColors.primaryBlue;
      case EstadoCita.enProgreso:
        return Colors.blue;
      case EstadoCita.completada:
        return AppColors.successGreen;
      case EstadoCita.cancelada:
        return AppColors.errorRed;
      case EstadoCita.noShow:
        return Colors.grey;
    }
  }

  String _getEstadoTexto() {
    switch (cita.estado) {
      case EstadoCita.pendiente:
        return 'Pendiente';
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.enProgreso:
        return 'En Progreso';
      case EstadoCita.completada:
        return 'Completada';
      case EstadoCita.cancelada:
        return 'Cancelada';
      case EstadoCita.noShow:
        return 'No Show';
    }
  }

  IconData _getEstadoIcono() {
    switch (cita.estado) {
      case EstadoCita.pendiente:
        return Icons.schedule;
      case EstadoCita.confirmada:
        return Icons.check_circle;
      case EstadoCita.enProgreso:
        return Icons.play_circle;
      case EstadoCita.completada:
        return Icons.check_circle_outline;
      case EstadoCita.cancelada:
        return Icons.cancel;
      case EstadoCita.noShow:
        return Icons.person_off;
    }
  }

  String _formatearFecha(DateTime fecha) {
    final formatter = DateFormat('EEEE, dd \'de\' MMMM \'de\' yyyy', 'es_ES');
    return formatter.format(fecha);
  }

  String _formatearHora(DateTime hora) {
    final formatter = DateFormat('HH:mm', 'es_ES');
    return '${formatter.format(hora)} hrs';
  }

  String _formatearFechaCompleta(DateTime fecha) {
    final formatter = DateFormat('dd/MM/yyyy \'a las\' HH:mm', 'es_ES');
    return formatter.format(fecha);
  }
}
