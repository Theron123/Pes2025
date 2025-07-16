import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notifications_bloc.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_filter_bar.dart';
import '../widgets/notification_stats_card.dart';

/// Página principal de notificaciones del sistema hospitalario
/// 
/// Permite visualizar, filtrar y gestionar todas las notificaciones
/// del usuario con un diseño profesional y accesible
class NotificationsPage extends StatefulWidget {
  final String usuarioId;

  const NotificationsPage({
    Key? key,
    required this.usuarioId,
  }) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Cargar notificaciones al iniciar
    context.read<NotificationsBloc>().add(
      LoadNotifications(usuarioId: widget.usuarioId),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatsSection(),
          _buildFilterSection(),
          _buildTabBar(),
          Expanded(
            child: _buildNotificationsContent(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Construye la barra de aplicación
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Notificaciones',
        style: AppTextStyles.headlineMedium,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
          tooltip: 'Filtros',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<NotificationsBloc>().add(
              RefreshNotifications(usuarioId: widget.usuarioId),
            );
          },
          tooltip: 'Actualizar',
        ),
        PopupMenuButton<String>(
          onSelected: _onMenuItemSelected,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'mark_all_read',
              child: ListTile(
                leading: Icon(Icons.mark_email_read),
                title: Text('Marcar todas como leídas'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'clear_all',
              child: ListTile(
                leading: Icon(Icons.clear_all),
                title: Text('Limpiar notificaciones'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye la sección de estadísticas
  Widget _buildStatsSection() {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        if (state is NotificationsLoaded) {
          return NotificationStatsCard(
            total: state.totalNotificaciones,
            noLeidas: state.conteoNoLeidas,
            porcentajeLeidas: state.conteoNoLeidas > 0
                ? (state.totalNotificaciones - state.conteoNoLeidas) / state.totalNotificaciones * 100
                : 100.0,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Construye la sección de filtros
  Widget _buildFilterSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showFilters ? 120 : 0,
      child: _showFilters
          ? NotificationFilterBar(
              onFilterApplied: (tipos, estados, desde, hasta, busqueda) {
                context.read<NotificationsBloc>().add(
                  FilterNotifications(
                    usuarioId: widget.usuarioId,
                    tipos: tipos,
                    estados: estados,
                    desde: desde,
                    hasta: hasta,
                    busqueda: busqueda,
                  ),
                );
              },
            )
          : const SizedBox.shrink(),
    );
  }

  /// Construye la barra de pestañas
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryBlue,
        tabs: const [
          Tab(
            icon: Icon(Icons.all_inbox),
            text: 'Todas',
          ),
          Tab(
            icon: Icon(Icons.mark_email_unread),
            text: 'No leídas',
          ),
          Tab(
            icon: Icon(Icons.mark_email_read),
            text: 'Leídas',
          ),
        ],
      ),
    );
  }

  /// Construye el contenido principal de notificaciones
  Widget _buildNotificationsContent() {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        if (state is NotificationsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          );
        }

        if (state is NotificationsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.errorRed,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar notificaciones',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<NotificationsBloc>().add(
                      LoadNotifications(usuarioId: widget.usuarioId),
                    );
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state is NotificationsLoaded) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationsList(state.notifications),
              _buildNotificationsList(state.notificacionesNoLeidas),
              _buildNotificationsList(state.notificacionesLeidas),
            ],
          );
        }

        return const Center(
          child: Text('No hay notificaciones disponibles'),
        );
      },
    );
  }

  /// Construye una lista de notificaciones
  Widget _buildNotificationsList(List<NotificationEntity> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay notificaciones',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationsBloc>().add(
          RefreshNotifications(usuarioId: widget.usuarioId),
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NotificationCard(
              notification: notification,
              onTap: () => _onNotificationTap(notification),
              onMarkAsRead: () => _onMarkAsRead(notification.id),
              onDelete: () => _onDeleteNotification(notification.id),
            ),
          );
        },
      ),
    );
  }

  /// Construye el botón flotante
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _onCreateNotification,
      backgroundColor: AppColors.primaryBlue,
      child: const Icon(Icons.add, color: Colors.white),
      tooltip: 'Crear notificación',
    );
  }

  // ==================== MÉTODOS DE INTERACCIÓN ====================

  /// Maneja la selección de elementos del menú
  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'mark_all_read':
        _markAllAsRead();
        break;
      case 'clear_all':
        _clearAllNotifications();
        break;
    }
  }

  /// Maneja el tap en una notificación
  void _onNotificationTap(NotificationEntity notification) {
    // Marcar como leída si no está leída
    if (notification.estado != EstadoNotificacion.leida) {
      _onMarkAsRead(notification.id);
    }

    // Navegar a detalles o ejecutar acción
    _navigateToNotificationDetail(notification);
  }

  /// Marca una notificación como leída
  void _onMarkAsRead(String notificationId) {
    context.read<NotificationsBloc>().add(
      MarkAsRead(notificacionId: notificationId),
    );
  }

  /// Elimina una notificación
  void _onDeleteNotification(String notificationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar notificación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta notificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar eliminación
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificación eliminada')),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Marca todas las notificaciones como leídas
  void _markAllAsRead() {
    final state = context.read<NotificationsBloc>().state;
    if (state is NotificationsLoaded) {
      final unreadIds = state.notificacionesNoLeidas.map((n) => n.id).toList();
      if (unreadIds.isNotEmpty) {
        // TODO: Implementar marcado múltiple
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todas las notificaciones marcadas como leídas')),
        );
      }
    }
  }

  /// Limpia todas las notificaciones
  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar notificaciones'),
        content: const Text('¿Estás seguro de que quieres limpiar todas las notificaciones?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationsBloc>().add(
                const ClearNotifications(),
              );
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  /// Crea una nueva notificación
  void _onCreateNotification() {
    // TODO: Implementar creación de notificación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de creación pendiente')),
    );
  }

  /// Navega a los detalles de una notificación
  void _navigateToNotificationDetail(NotificationEntity notification) {
    // TODO: Implementar navegación a detalles
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detalles de: ${notification.titulo}')),
    );
  }
} 