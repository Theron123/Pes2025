import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/domain/entities/appointment_entity.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/citas_bloc.dart';
import '../widgets/cita_card.dart';

/// Pantalla principal que muestra todas las citas registradas en el sistema
/// 
/// Características:
/// - Diseño blanco y limpio
/// - Muestra todas las citas independientemente del estado
/// - Botón flotante para crear nuevas citas
/// - Accesible para todos los roles de usuario
/// - Filtros básicos por estado
/// - Paginación automática
class TodasCitasPage extends StatefulWidget {
  const TodasCitasPage({super.key});

  @override
  State<TodasCitasPage> createState() => _TodasCitasPageState();
}

class _TodasCitasPageState extends State<TodasCitasPage> {
  EstadoCita? _filtroEstado;
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  final DateFormat _timeFormatter = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _cargarTodasLasCitas();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _cargarTodasLasCitas() {
    context.read<CitasBloc>().add(
      const CargarTodasLasCitasEvent(
        limite: 100,
        pagina: 1,
      ),
    );
  }

  void _cambiarFiltroEstado(EstadoCita? nuevoEstado) {
    if (_filtroEstado != nuevoEstado) {
      setState(() {
        _filtroEstado = nuevoEstado;
      });
      context.read<CitasBloc>().add(
        CargarTodasLasCitasEvent(
          estado: nuevoEstado,
          limite: 100,
          pagina: 1,
        ),
      );
    }
  }

  void _navegarACrearCita() {
    context.push('/appointments/create');
  }

  void _navegarADetallesCita(CitaEntity cita) {
    context.push('/appointments/details', extra: cita);
  }

  void _volverAlDashboard() {
    context.go('/'); // Navegar al dashboard principal
  }

  Color _getEstadoColor(EstadoCita estado) {
    switch (estado) {
      case EstadoCita.pendiente:
        return AppColors.warningOrange;
      case EstadoCita.confirmada:
        return AppColors.primaryBlue;
      case EstadoCita.completada:
        return AppColors.successGreen;
      case EstadoCita.cancelada:
        return AppColors.errorRed;
      case EstadoCita.noShow:
        return AppColors.errorRed.withOpacity(0.7);
      case EstadoCita.enProgreso:
        return AppColors.infoBlue;
    }
  }

  String _getEstadoTexto(EstadoCita estado) {
    switch (estado) {
      case EstadoCita.pendiente:
        return 'Pendiente';
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.completada:
        return 'Completada';
      case EstadoCita.cancelada:
        return 'Cancelada';
      case EstadoCita.noShow:
        return 'No se presentó';
      case EstadoCita.enProgreso:
        return 'En progreso';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Todas las Citas',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: _volverAlDashboard,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver al dashboard principal',
          splashRadius: 24,
        ),
        actions: [
          IconButton(
            onPressed: _cargarTodasLasCitas,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista de citas',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros por estado
          _buildFiltrosSection(),
          
          // Lista de citas
          Expanded(
            child: BlocConsumer<CitasBloc, CitasState>(
              listener: (context, state) {
                if (state is CitasError) {
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
                return _buildContenidoPrincipal(state);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarACrearCita,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nueva Cita',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        tooltip: 'Crear nueva cita',
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFiltrosSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por estado:',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFiltroChip('Todas', null),
                const SizedBox(width: 8),
                _buildFiltroChip('Pendientes', EstadoCita.pendiente),
                const SizedBox(width: 8),
                _buildFiltroChip('Confirmadas', EstadoCita.confirmada),
                const SizedBox(width: 8),
                _buildFiltroChip('Realizadas', EstadoCita.completada),
                const SizedBox(width: 8),
                _buildFiltroChip('Canceladas', EstadoCita.cancelada),
                const SizedBox(width: 8),
                _buildFiltroChip('No asistió', EstadoCita.noShow),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroChip(String texto, EstadoCita? estado) {
    final isSelected = _filtroEstado == estado;
    final color = estado != null ? _getEstadoColor(estado) : AppColors.primaryBlue;
    
    return FilterChip(
      label: Text(
        texto,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        _cambiarFiltroEstado(selected ? estado : null);
      },
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: color,
        width: 1.5,
      ),
      elevation: isSelected ? 2 : 0,
    );
  }

  Widget _buildContenidoPrincipal(CitasState state) {
    if (state is CitasLoading) {
      return _buildEstadoCarga();
    }
    
    if (state is CitasLoaded) {
      if (state.citas.isEmpty) {
        return _buildEstadoVacio();
      }
      return _buildListaCitas(state.citas);
    }
    
    if (state is CitasError) {
      return _buildEstadoError(state.mensaje);
    }
    
    return _buildEstadoInicial();
  }

  Widget _buildEstadoCarga() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Cargando citas...',
            style: TextStyle(
              color: AppColors.mediumBlue,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: AppColors.lightBlue.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            _filtroEstado != null 
                ? 'No hay citas ${_getEstadoTexto(_filtroEstado!).toLowerCase()}'
                : 'No hay citas registradas',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón "Nueva Cita" para crear la primera cita',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mediumBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoError(String mensaje) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.errorRed.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Error al cargar las citas',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.errorRed,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mediumBlue,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _cargarTodasLasCitas,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoInicial() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.healing,
            size: 80,
            color: AppColors.lightBlue.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Sistema de Citas Médicas',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón de actualizar para cargar las citas',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mediumBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaCitas(List<CitaEntity> citas) {
    return RefreshIndicator(
      onRefresh: () async => _cargarTodasLasCitas(),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: citas.length + 1, // +1 para el espacio del FAB
        itemBuilder: (context, index) {
          if (index == citas.length) {
            // Espacio extra para el FAB
            return const SizedBox(height: 80);
          }
          
          final cita = citas[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CitaCard(
              cita: cita,
              onTap: () => _navegarADetallesCita(cita),
            ),
          );
        },
      ),
    );
  }
} 