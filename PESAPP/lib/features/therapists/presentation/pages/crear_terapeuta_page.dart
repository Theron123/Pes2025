import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/domain/entities/therapist_entity.dart';
import '../../../../features/auth/presentation/widgets/loading_overlay.dart';
import '../bloc/terapeutas_bloc.dart';
import '../bloc/terapeutas_event.dart';
import '../bloc/terapeutas_state.dart';

class CrearTerapeutaPage extends StatefulWidget {
  const CrearTerapeutaPage({super.key});

  @override
  State<CrearTerapeutaPage> createState() => _CrearTerapeutaPageState();
}

class _CrearTerapeutaPageState extends State<CrearTerapeutaPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioIdController = TextEditingController();
  final _numeroLicenciaController = TextEditingController();
  
  List<EspecializacionMasaje> _especializacionesSeleccionadas = [];
  bool _disponible = true;

  @override
  void dispose() {
    _usuarioIdController.dispose();
    _numeroLicenciaController.dispose();
    super.dispose();
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
          'Crear Terapeuta',
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
      ),
      body: BlocConsumer<TerapeutasBloc, TerapeutasState>(
        listener: (context, state) {
          if (state is TerapeutaCreado) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.successGreen,
              ),
            );
            context.pop();
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
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInformacionBasica(),
                      const SizedBox(height: 24),
                      _buildEspecializaciones(),
                      const SizedBox(height: 24),
                      _buildDisponibilidad(),
                      const SizedBox(height: 32),
                      _buildBotones(),
                    ],
                  ),
                ),
              ),
              if (state is TerapeutasLoading || state is TerapeutasProcessing)
                const LoadingOverlay(
                  message: 'Creando terapeuta...',
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInformacionBasica() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Básica',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usuarioIdController,
              decoration: const InputDecoration(
                labelText: 'ID del Usuario',
                hintText: 'Ingrese el ID del usuario asociado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El ID del usuario es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numeroLicenciaController,
              decoration: const InputDecoration(
                labelText: 'Número de Licencia',
                hintText: 'Ej: LIC-2024-001',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El número de licencia es requerido';
                }
                if (value.length < 5) {
                  return 'El número de licencia debe tener al menos 5 caracteres';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEspecializaciones() {
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
            if (_especializacionesSeleccionadas.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _especializacionesSeleccionadas.map((esp) {
                  return Chip(
                    label: Text(esp.nombre),
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    onDeleted: () {
                      setState(() {
                        _especializacionesSeleccionadas.remove(esp);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _agregarEspecializacion,
              icon: const Icon(Icons.add),
              label: const Text('Agregar Especialización'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisponibilidad() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disponibilidad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Terapeuta disponible'),
              subtitle: Text(
                _disponible
                    ? 'El terapeuta podrá recibir citas'
                    : 'El terapeuta no recibirá citas nuevas',
              ),
              value: _disponible,
              onChanged: (value) {
                setState(() {
                  _disponible = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotones() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.backgroundLight,
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _crearTerapeuta,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Crear Terapeuta'),
          ),
        ),
      ],
    );
  }

  void _agregarEspecializacion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar Especialización'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: EspecializacionMasaje.values
                .where((esp) => !_especializacionesSeleccionadas.contains(esp))
                .map((esp) {
              return ListTile(
                title: Text(esp.nombre),
                subtitle: Text(esp.descripcion),
                onTap: () {
                  setState(() {
                    _especializacionesSeleccionadas.add(esp);
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _crearTerapeuta() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_especializacionesSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar al menos una especialización'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Crear horarios básicos (9 AM - 5 PM, lunes a viernes)
    final horarios = HorariosTrabajo.estandar();

    // Crear terapeuta
    context.read<TerapeutasBloc>().add(
      CrearTerapeutaEvent(
        usuarioId: _usuarioIdController.text.trim(),
        numeroLicencia: _numeroLicenciaController.text.trim(),
        especializaciones: _especializacionesSeleccionadas,
        horariosTrabajo: horarios,
        disponible: _disponible,
      ),
    );
  }
}
