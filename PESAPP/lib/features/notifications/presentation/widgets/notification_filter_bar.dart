import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/notification_entity.dart';

/// Widget para filtrar notificaciones
/// 
/// Permite aplicar filtros por tipo, estado, fechas y búsqueda de texto
class NotificationFilterBar extends StatefulWidget {
  final Function(
    List<TipoNotificacion>? tipos,
    List<EstadoNotificacion>? estados,
    DateTime? desde,
    DateTime? hasta,
    String? busqueda,
  ) onFilterApplied;

  const NotificationFilterBar({
    Key? key,
    required this.onFilterApplied,
  }) : super(key: key);

  @override
  State<NotificationFilterBar> createState() => _NotificationFilterBarState();
}

class _NotificationFilterBarState extends State<NotificationFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  List<TipoNotificacion> _selectedTipos = [];
  List<EstadoNotificacion> _selectedEstados = [];
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildFilterChips()),
              _buildActionButtons(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar notificaciones...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (value) => _applyFilters(),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('Estados'),
            selected: _selectedEstados.isNotEmpty,
            onSelected: (_) => _showEstadosDialog(),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Tipos'),
            selected: _selectedTipos.isNotEmpty,
            onSelected: (_) => _showTiposDialog(),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(_fechaDesde != null ? 'Fechas' : 'Fechas'),
            selected: _fechaDesde != null || _fechaHasta != null,
            onSelected: (_) => _showDatePicker(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearFilters,
          tooltip: 'Limpiar filtros',
        ),
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: _applyFilters,
          tooltip: 'Aplicar filtros',
        ),
      ],
    );
  }

  void _showEstadosDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por estados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: EstadoNotificacion.values.map((estado) {
            return CheckboxListTile(
              title: Text(estado.nombre),
              value: _selectedEstados.contains(estado),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedEstados.add(estado);
                  } else {
                    _selectedEstados.remove(estado);
                  }
                });
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showTiposDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por tipos'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: TipoNotificacion.values.map((tipo) {
              return CheckboxListTile(
                title: Text(tipo.nombre),
                value: _selectedTipos.contains(tipo),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedTipos.add(tipo);
                    } else {
                      _selectedTipos.remove(tipo);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: _fechaDesde != null && _fechaHasta != null
          ? DateTimeRange(start: _fechaDesde!, end: _fechaHasta!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _fechaDesde = picked.start;
        _fechaHasta = picked.end;
      });
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedTipos.clear();
      _selectedEstados.clear();
      _fechaDesde = null;
      _fechaHasta = null;
    });
    _applyFilters();
  }

  void _applyFilters() {
    widget.onFilterApplied(
      _selectedTipos.isEmpty ? null : _selectedTipos,
      _selectedEstados.isEmpty ? null : _selectedEstados,
      _fechaDesde,
      _fechaHasta,
      _searchController.text.isEmpty ? null : _searchController.text,
    );
  }
} 