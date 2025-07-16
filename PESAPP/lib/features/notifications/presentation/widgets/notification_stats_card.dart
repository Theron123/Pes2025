import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Widget para mostrar estadísticas de notificaciones
/// 
/// Muestra un resumen visual de las notificaciones del usuario
class NotificationStatsCard extends StatelessWidget {
  final int total;
  final int noLeidas;
  final double porcentajeLeidas;

  const NotificationStatsCard({
    Key? key,
    required this.total,
    required this.noLeidas,
    required this.porcentajeLeidas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.notifications,
              label: 'Total',
              value: total.toString(),
              color: Colors.blue,
            ),
            _buildStatItem(
              icon: Icons.mark_email_unread,
              label: 'No leídas',
              value: noLeidas.toString(),
              color: Colors.orange,
            ),
            _buildStatItem(
              icon: Icons.mark_email_read,
              label: 'Leídas',
              value: '${porcentajeLeidas.toStringAsFixed(0)}%',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
} 