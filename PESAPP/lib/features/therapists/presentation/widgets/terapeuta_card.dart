import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/domain/entities/therapist_entity.dart';

/// Widget de tarjeta para mostrar información de un terapeuta
class TerapeutaCard extends StatelessWidget {
  final TerapeutaEntity terapeuta;
  final VoidCallback? onTap;
  final Function(bool)? onDisponibilidadCambiada;

  const TerapeutaCard({
    super.key,
    required this.terapeuta,
    this.onTap,
    this.onDisponibilidadCambiada,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryBlue,
                    child: Text(
                      'T', // TODO: Obtener inicial del nombre cuando esté disponible
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terapeuta ID: ${terapeuta.id}', // TODO: Mostrar nombre cuando esté disponible
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Licencia: ${terapeuta.numeroLicencia}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: terapeuta.disponible,
                    onChanged: onDisponibilidadCambiada,
                    activeColor: AppColors.successGreen,
                    inactiveTrackColor: AppColors.textTertiary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: terapeuta.especializaciones.map((esp) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      esp.descripcion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
