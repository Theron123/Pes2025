import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/notification_entity.dart';

/// Widget para mostrar una notificación individual
/// 
/// Muestra los detalles de una notificación con acciones disponibles
class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getIconData(notification.tipo.icono),
                    color: _getTypeColor(notification.tipo),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notification.titulo,
                      style: AppTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (notification.estado != EstadoNotificacion.leida)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.mensaje,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(notification.fechaCreacion),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (notification.estado != EstadoNotificacion.leida && onMarkAsRead != null)
                        IconButton(
                          icon: const Icon(Icons.mark_email_read),
                          onPressed: onMarkAsRead,
                          tooltip: 'Marcar como leída',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: onDelete,
                          tooltip: 'Eliminar',
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'alarm':
        return Icons.alarm;
      case 'check_circle':
        return Icons.check_circle;
      case 'cancel':
        return Icons.cancel;
      case 'schedule':
        return Icons.schedule;
      case 'person':
        return Icons.person;
      case 'done_all':
        return Icons.done_all;
      case 'description':
        return Icons.description;
      case 'info':
        return Icons.info;
      case 'account_circle':
        return Icons.account_circle;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(TipoNotificacion tipo) {
    switch (tipo.prioridad) {
      case 1:
        return Colors.red; // Alta prioridad
      case 2:
        return Colors.orange; // Prioridad media
      case 3:
        return Colors.blue; // Prioridad baja
      default:
        return Colors.grey;
    }
  }
} 