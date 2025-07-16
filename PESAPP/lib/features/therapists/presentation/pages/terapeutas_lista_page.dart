import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/domain/entities/therapist_entity.dart';
import '../../../../features/auth/presentation/widgets/loading_overlay.dart';
import '../bloc/terapeutas_bloc.dart';
import '../bloc/terapeutas_event.dart';
import '../bloc/terapeutas_state.dart';

/// Página principal para mostrar la lista de terapeutas con funcionalidad completa
class TerapeutasListaPage extends StatefulWidget {
  const TerapeutasListaPage({super.key});

  @override
  State<TerapeutasListaPage> createState() => _TerapeutasListaPageState();
}

class _TerapeutasListaPageState extends State<TerapeutasListaPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _soloDisponibles = false;
  EspecializacionMasaje? _filtroEspecializacion;

  @override
  void initState() {
    super.initState();
    _cargarTerapeutas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _cargarTerapeutas() {
    context.read<TerapeutasBloc>().add(CargarTerapeutasEvent(
      disponibleSolo: _soloDisponibles,
      especializacion: _filtroEspecializacion,
    ));
  }

  void _buscarTerapeutas(String query) {
    if (query.isEmpty) {
      _cargarTerapeutas();
    } else {
      context.read<TerapeutasBloc>().add(BuscarTerapeutasEvent(
        textoBusqueda: query,
        disponibleSolo: _soloDisponibles,
      ));
    }
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
          'Gestión de Terapeutas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _mostrarFiltros,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _crearTerapeuta,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBarraBusqueda(),
          _buildFiltrosActivos(),
          Expanded(
            child: BlocConsumer<TerapeutasBloc, TerapeutasState>(
              listener: (context, state) {
                if (state is TerapeutaCreado) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.mensaje),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                  _cargarTerapeutas(); // Recargar lista
                }
              },
              builder: (context, state) {
                if (state is TerapeutasLoading) {
                  return const LoadingOverlay(
                    message: 'Cargando terapeutas...',
                  );
                }
                
                if (state is TerapeutasError) {
                  return _buildErrorWidget(state);
                }
                
                if (state is TerapeutasLoaded) {
                  return _buildListaTerapeutas(state.terapeutas);
                }
                
                return _buildEstadoInicial();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearTerapeuta,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBarraBusqueda() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o número de licencia...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _cargarTerapeutas();
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue),
          ),
        ),
        onChanged: (value) {
          setState(() {});
          _buscarTerapeutas(value);
        },
      ),
    );
  }

  Widget _buildFiltrosActivos() {
    final filtrosActivos = <Widget>[];

    if (_soloDisponibles) {
      filtrosActivos.add(
        Chip(
          label: const Text('Solo disponibles'),
          backgroundColor: AppColors.successGreen.withValues(alpha: 0.1),
          onDeleted: () {
            setState(() {
              _soloDisponibles = false;
            });
            _cargarTerapeutas();
          },
        ),
      );
    }

    if (_filtroEspecializacion != null) {
      filtrosActivos.add(
        Chip(
          label: Text(_filtroEspecializacion!.nombre),
          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
          onDeleted: () {
            setState(() {
              _filtroEspecializacion = null;
            });
            _cargarTerapeutas();
          },
        ),
      );
    }

    if (filtrosActivos.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Wrap(
        spacing: 8,
        children: filtrosActivos,
      ),
    );
  }

  Widget _buildListaTerapeutas(List<TerapeutaEntity> terapeutas) {
    if (terapeutas.isEmpty) {
      return _buildEstadoVacio();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: terapeutas.length,
      itemBuilder: (context, index) {
        final terapeuta = terapeutas[index];
        return _buildTerapeutaCard(terapeuta);
      },
    );
  }

  Widget _buildTerapeutaCard(TerapeutaEntity terapeuta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _verDetallesTerapeuta(terapeuta),
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
                      terapeuta.numeroLicencia.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lic. ${terapeuta.numeroLicencia}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
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
                            const SizedBox(width: 4),
                            Text(
                              terapeuta.disponible 
                                  ? 'Disponible' 
                                  : 'No disponible',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: terapeuta.disponible 
                                    ? AppColors.successGreen 
                                    : AppColors.errorRed,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _accionTerapeuta(value, terapeuta),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'ver',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('Ver detalles'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: terapeuta.disponible ? 'deshabilitar' : 'habilitar',
                        child: Row(
                          children: [
                            Icon(terapeuta.disponible 
                                ? Icons.block 
                                : Icons.check_circle),
                            const SizedBox(width: 8),
                            Text(terapeuta.disponible 
                                ? 'Deshabilitar' 
                                : 'Habilitar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (terapeuta.especializaciones.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: terapeuta.especializaciones.take(3).map((esp) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        esp.nombre,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay terapeutas disponibles',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega el primer terapeuta al sistema',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _crearTerapeuta,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Terapeuta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(TerapeutasError state) {
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
            'Error al cargar terapeutas',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.errorRed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.mensaje,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (state.detalles != null) ...[
            const SizedBox(height: 4),
            Text(
              'Código: ${state.codigo}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _cargarTerapeutas,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoInicial() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Inicializando sistema de terapeutas...'),
        ],
      ),
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Solo terapeutas disponibles'),
                  value: _soloDisponibles,
                  onChanged: (value) {
                    setModalState(() {
                      _soloDisponibles = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Especialización',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<EspecializacionMasaje>(
                  value: _filtroEspecializacion,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Seleccionar especialización',
                  ),
                  items: [
                    const DropdownMenuItem<EspecializacionMasaje>(
                      value: null,
                      child: Text('Todas las especializaciones'),
                    ),
                    ...EspecializacionMasaje.values.map((esp) {
                      return DropdownMenuItem(
                        value: esp,
                        child: Text(esp.nombre),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setModalState(() {
                      _filtroEspecializacion = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _soloDisponibles = false;
                            _filtroEspecializacion = null;
                          });
                          Navigator.pop(context);
                          _cargarTerapeutas();
                        },
                        child: const Text('Limpiar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                          _cargarTerapeutas();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _crearTerapeuta() {
    context.go(RouteNames.createTherapist);
  }

  void _verDetallesTerapeuta(TerapeutaEntity terapeuta) {
    context.go(
      RouteNames.therapistDetailsPath(terapeuta.id),
      extra: terapeuta,
    );
  }

  void _accionTerapeuta(String accion, TerapeutaEntity terapeuta) {
    switch (accion) {
      case 'ver':
        _verDetallesTerapeuta(terapeuta);
        break;
      case 'editar':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Funcionalidad de editar pendiente'),
          ),
        );
        break;
      case 'habilitar':
      case 'deshabilitar':
        final disponible = accion == 'habilitar';
        context.read<TerapeutasBloc>().add(
          CambiarDisponibilidadTerapeutaEvent(
            terapeutaId: terapeuta.id,
            disponible: disponible,
          ),
        );
        break;
    }
  }
}
