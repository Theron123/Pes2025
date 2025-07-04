import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/domain/entities/appointment_entity.dart';

/// Widget de tarjeta para mostrar información de una cita médica
/// 
/// Características:
/// - Diseño hospitalario profesional
/// - Información esencial de la cita
/// - Estado visual con colores
/// - Accesibilidad completa
/// - Tema azul/blanco hospitalario
class CitaCard extends StatelessWidget {
  final CitaEntity cita;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  const CitaCard({
    super.key,
    required this.cita,
    this.onTap,
    this.onEdit,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getEstadoColor().withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado y fecha
              _buildHeader(),
              const SizedBox(height: 12),
              
              // Información principal
              _buildInfoPrincipal(),
              const SizedBox(height: 12),
              
              // Detalles adicionales
              _buildDetalles(),
              
              // Acciones si están disponibles
              if (onEdit != null || onCancel != null) ...[
                const SizedBox(height: 16),
                _buildAcciones(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildEstadoChip(),
        Text(
          _formatearFecha(cita.fechaCita),
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoChip() {
    final color = _getEstadoColor();
    final texto = _getEstadoTexto();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPrincipal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tipo de masaje con icono
        Row(
          children: [
            Icon(
              Icons.spa,
              size: 20,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                cita.tipoMasaje,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Hora con icono
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              _formatearHora(cita.horaCita),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.schedule,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              '${cita.duracionMinutos} min',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetalles() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Terapeuta (si está disponible)
          if (cita.terapeutaId != null) ...[
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Terapeuta asignado',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          
          // Notas si están disponibles
          if (cita.notas != null && cita.notas!.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.note,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cita.notas!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAcciones(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onEdit != null)
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Editar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
            ),
          ),
        if (onCancel != null) ...[
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Cancelar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
          ),
        ],
      ],
    );
  }

  // Métodos auxiliares
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

  String _formatearFecha(DateTime fecha) {
    final formatter = DateFormat('dd/MM/yyyy', 'es_ES');
    final hoy = DateTime.now();
    final manana = hoy.add(const Duration(days: 1));
    
    if (fecha.year == hoy.year && fecha.month == hoy.month && fecha.day == hoy.day) {
      return 'Hoy';
    } else if (fecha.year == manana.year && fecha.month == manana.month && fecha.day == manana.day) {
      return 'Mañana';
    } else {
      return formatter.format(fecha);
    }
  }

  String _formatearHora(DateTime hora) {
    final formatter = DateFormat('HH:mm', 'es_ES');
    return formatter.format(hora);
  }
}
