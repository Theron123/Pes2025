import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/domain/entities/therapist_entity.dart';
import '../../../../features/auth/presentation/widgets/loading_overlay.dart';
import '../bloc/terapeutas_bloc.dart';
import '../bloc/terapeutas_event.dart';
import '../bloc/terapeutas_state.dart';

class TerapeutaDetallesPage extends StatefulWidget {
  final String terapeutaId;
  final TerapeutaEntity? terapeuta;

  const TerapeutaDetallesPage({
    super.key,
    required this.terapeutaId,
    this.terapeuta,
  });

  @override
  State<TerapeutaDetallesPage> createState() => _TerapeutaDetallesPageState();
}

class _TerapeutaDetallesPageState extends State<TerapeutaDetallesPage> {
  TerapeutaEntity? _terapeuta;

  @override
  void initState() {
    super.initState();
    _terapeuta = widget.terapeuta;
    if (_terapeuta == null) {
      _cargarTerapeuta();
    }
  }

  void _cargarTerapeuta() {
    context.read<TerapeutasBloc>().add(
      ObtenerTerapeutaPorIdEvent(terapeutaId: widget.terapeutaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Detalles del Terapeuta',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          if (_terapeuta != null) ...[
            IconButton(
              onPressed: () => _editarTerapeuta(),
              icon: const Icon(Icons.edit),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _accionTerapeuta(value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _terapeuta!.disponible ? 'deshabilitar' : 'habilitar',
                  child: Row(
                    children: [
                      Icon(_terapeuta!.disponible 
                          ? Icons.block 
                          : Icons.check_circle),
                      const SizedBox(width: 8),
                      Text(_terapeuta!.disponible 
                          ? 'Deshabilitar' 
                          : 'Habilitar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: BlocConsumer<TerapeutasBloc, TerapeutasState>(
        listener: (context, state) {
          if (state is TerapeutaIndividualLoaded) {
            setState(() {
              _terapeuta = state.terapeuta;
            });
          } else if (state is TerapeutaActualizado) {
            setState(() {
              _terapeuta = state.terapeuta;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.successGreen,
              ),
            );
          } else if (state is TerapeutasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              if (_terapeuta != null)
                _buildDetallesTerapeuta(_terapeuta!)
              else
                _buildEstadoCarga(),
              if (state is TerapeutasLoading || state is TerapeutasProcessing)
                const LoadingOverlay(
                  message: 'Procesando...',
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetallesTerapeuta(TerapeutaEntity terapeuta) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTarjetaPrincipal(terapeuta),
          const SizedBox(height: 16),
          _buildEspecializaciones(terapeuta),
          const SizedBox(height: 16),
          _buildHorariosTrabajo(terapeuta),
          const SizedBox(height: 16),
          _buildEstadisticas(terapeuta),
          const SizedBox(height: 16),
          _buildAcciones(terapeuta),
        ],
      ),
    );
  }

  Widget _buildTarjetaPrincipal(TerapeutaEntity terapeuta) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryBlue,
              child: Text(
                terapeuta.numeroLicencia.substring(0, 2).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Lic. ${terapeuta.numeroLicencia}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: terapeuta.disponible 
                    ? AppColors.successGreen.withOpacity(0.1)
                    : AppColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    terapeuta.disponible 
                        ? Icons.check_circle 
                        : Icons.cancel,
                    size: 16,
                    color: terapeuta.disponible 
                        ? AppColors.successGreen 
                        : AppColors.errorRed,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    terapeuta.disponible 
                        ? 'Disponible' 
                        : 'No disponible',
                    style: TextStyle(
                      color: terapeuta.disponible 
                          ? AppColors.successGreen 
                          : AppColors.errorRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEspecializaciones(TerapeutaEntity terapeuta) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Especializaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            if (terapeuta.especializaciones.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: terapeuta.especializaciones.map((esp) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          esp.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          esp.descripcion,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              const Text(
                'No hay especializaciones registradas',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHorariosTrabajo(TerapeutaEntity terapeuta) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Horarios de Trabajo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: terapeuta.horariosTrabajo.horariosSemana.map((horario) {
                return _buildHorarioDia(horario.dia.nombre, horario);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorarioDia(String dia, HorarioDia horario) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              dia,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: !horario.esDiaLibre && horario.horaInicio != null && horario.horaFin != null
                ? Text(
                    '${horario.horaInicio!.formato12h} - ${horario.horaFin!.formato12h}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                    ),
                  )
                : const Text(
                    'Día libre',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticas(TerapeutaEntity terapeuta) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEstadistica('Citas Total', '0', Icons.event),
                ),
                Expanded(
                  child: _buildEstadistica('Este Mes', '0', Icons.calendar_today),
                ),
                Expanded(
                  child: _buildEstadistica('Rating', '5.0', Icons.star),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadistica(String titulo, String valor, IconData icono) {
    return Column(
      children: [
        Icon(icono, size: 32, color: AppColors.primaryBlue),
        const SizedBox(height: 8),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAcciones(TerapeutaEntity terapeuta) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editarTerapeuta(),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _cambiarDisponibilidad(),
                    icon: Icon(terapeuta.disponible 
                        ? Icons.block 
                        : Icons.check_circle),
                    label: Text(terapeuta.disponible 
                        ? 'Deshabilitar' 
                        : 'Habilitar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: terapeuta.disponible 
                          ? AppColors.errorRed 
                          : AppColors.successGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoCarga() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando información del terapeuta...'),
        ],
      ),
    );
  }

  void _editarTerapeuta() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de editar pendiente'),
      ),
    );
  }

  void _cambiarDisponibilidad() {
    if (_terapeuta != null) {
      context.read<TerapeutasBloc>().add(
        CambiarDisponibilidadTerapeutaEvent(
          terapeutaId: _terapeuta!.id,
          disponible: !_terapeuta!.disponible,
        ),
      );
    }
  }

  void _accionTerapeuta(String accion) {
    switch (accion) {
      case 'habilitar':
      case 'deshabilitar':
        _cambiarDisponibilidad();
        break;
    }
  }
}
