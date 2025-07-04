import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/domain/entities/appointment_entity.dart';
import '../bloc/citas_bloc.dart';
import '../widgets/cita_card.dart';

/// Página principal para mostrar la lista de citas
/// 
/// Características:
/// - Lista de citas con filtros por estado
/// - Diseño hospitalario profesional azul/blanco
/// - Integración completa con CitasBloc
/// - Navegación a crear/editar/detalles de citas
/// - Paginación y refresh automático
/// - Accesibilidad completa
class CitasListaPage extends StatefulWidget {
  const CitasListaPage({super.key});

  @override
  State<CitasListaPage> createState() => _CitasListaPageState();
}

class _CitasListaPageState extends State<CitasListaPage> {
  EstadoCita? _filtroEstado;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Cargar citas al inicializar la página
    _cargarCitas();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _cargarCitas() {
    context.read<CitasBloc>().add(
      CargarCitasPorPacienteEvent(
        pacienteId: 'current-user-id', // TODO: Obtener del contexto de usuario
        fechaDesde: DateTime.now().subtract(const Duration(days: 30)),
        fechaHasta: DateTime.now().add(const Duration(days: 90)),
        estado: _filtroEstado,
        limite: 20,
        pagina: 1,
      ),
    );
  }

  void _cambiarFiltro(EstadoCita? nuevoEstado) {
    if (_filtroEstado != nuevoEstado) {
      setState(() {
        _filtroEstado = nuevoEstado;
      });
      _cargarCitas();
    }
  }

  void _navegarACrearCita() {
    context.push('/appointments/create');
  }

  void _navegarADetallesCita(CitaEntity cita) {
    context.push('/appointments/details', extra: cita);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue.withOpacity(0.05),
      appBar: AppBar(
        title: Text(
          'Mis Citas',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _cargarCitas,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista de citas',
            splashRadius: 24,
          ),
        ],
      ),
      body: BlocConsumer<CitasBloc, CitasState>(
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
          return Column(
            children: [
              // Sección de filtros
              _buildFiltrosSection(),
              
              // Lista de citas
              Expanded(
                child: _buildContenidoPrincipal(state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarACrearCita,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nueva Cita',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        tooltip: 'Crear nueva cita médica',
      ),
    );
  }

  Widget _buildFiltrosSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por estado:',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
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
                _buildFiltroChip('En Progreso', EstadoCita.enProgreso),
                const SizedBox(width: 8),
                _buildFiltroChip('Completadas', EstadoCita.completada),
                const SizedBox(width: 8),
                _buildFiltroChip('Canceladas', EstadoCita.cancelada),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroChip(String texto, EstadoCita? estado) {
    final esSeleccionado = _filtroEstado == estado;
    
    return FilterChip(
      label: Text(
        texto,
        style: TextStyle(
          color: esSeleccionado ? Colors.white : AppColors.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: esSeleccionado,
      onSelected: (_) => _cambiarFiltro(estado),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryBlue,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: esSeleccionado ? AppColors.primaryBlue : AppColors.lightBlue,
        width: 1.5,
      ),
      elevation: esSeleccionado ? 4 : 1,
      shadowColor: AppColors.primaryBlue.withOpacity(0.3),
      tooltip: 'Filtrar citas por estado: $texto',
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
            'Cargando citas médicas...',
            style: TextStyle(
              color: AppColors.darkBlue,
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
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'No hay citas registradas',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _filtroEstado == null
                  ? 'Aún no tienes citas programadas.\nPresiona el botón + para crear tu primera cita.'
                  : 'No hay citas con el estado seleccionado.\nIntenta cambiar el filtro o crear una nueva cita.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mediumBlue,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navegarACrearCita,
              icon: const Icon(Icons.add),
              label: const Text('Crear Primera Cita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoError(String mensaje) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.errorRed.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar citas',
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
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargarCitas,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
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
            'Toca el botón de actualizar para cargar tus citas',
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
      onRefresh: () async => _cargarCitas(),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: citas.length,
        itemBuilder: (context, index) {
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