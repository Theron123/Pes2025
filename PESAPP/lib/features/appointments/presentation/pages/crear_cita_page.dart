import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/domain/entities/appointment_entity.dart';
import '../bloc/citas_bloc.dart';

/// Página para crear una nueva cita médica
/// 
/// Características:
/// - Formulario completo con validaciones
/// - Date/Time pickers profesionales
/// - Integración con CitasBloc
/// - Diseño hospitalario azul/blanco
/// - Validaciones en tiempo real
class CrearCitaPage extends StatefulWidget {
  const CrearCitaPage({super.key});

  @override
  State<CrearCitaPage> createState() => _CrearCitaPageState();
}

class _CrearCitaPageState extends State<CrearCitaPage> {
  final _formKey = GlobalKey<FormState>();
  final _tipoMasajeController = TextEditingController();
  final _notasController = TextEditingController();
  
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  int _duracionMinutos = 60;
  
  final List<String> _tiposMasaje = [
    'Masaje Relajante',
    'Masaje Terapéutico',
    'Masaje Deportivo',
    'Masaje Sueco',
    'Masaje de Piedras Calientes',
    'Masaje Aromático',
  ];

  @override
  void dispose() {
    _tipoMasajeController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Nueva Cita',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<CitasBloc, CitasState>(
        listener: (context, state) {
          if (state is CitaCreada) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.successGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop();
          } else if (state is CitasError) {
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildEncabezado(),
                  const SizedBox(height: 24),
                  _buildFormulario(),
                  const SizedBox(height: 32),
                  _buildBotonCrear(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEncabezado() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 12),
            Text(
              'Programar Nueva Cita',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete la información para programar su cita médica',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulario() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de Masaje
            _buildTipoMasajeField(),
            const SizedBox(height: 20),
            
            // Fecha
            _buildFechaField(),
            const SizedBox(height: 20),
            
            // Hora
            _buildHoraField(),
            const SizedBox(height: 20),
            
            // Duración
            _buildDuracionField(),
            const SizedBox(height: 20),
            
            // Notas
            _buildNotasField(),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoMasajeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Masaje *',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _tipoMasajeController.text.isEmpty ? null : _tipoMasajeController.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            hintText: 'Seleccione el tipo de masaje',
            prefixIcon: const Icon(Icons.spa, color: AppColors.primaryBlue),
          ),
          items: _tiposMasaje.map((tipo) {
            return DropdownMenuItem<String>(
              value: tipo,
              child: Text(tipo),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _tipoMasajeController.text = value;
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor seleccione un tipo de masaje';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFechaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de la Cita *',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _seleccionarFecha,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Text(
                  _fechaSeleccionada == null
                      ? 'Seleccionar fecha'
                      : DateFormat('dd/MM/yyyy', 'es_ES').format(_fechaSeleccionada!),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _fechaSeleccionada == null ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoraField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hora de la Cita *',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _seleccionarHora,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Text(
                  _horaSeleccionada == null
                      ? 'Seleccionar hora'
                      : _horaSeleccionada!.format(context),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _horaSeleccionada == null ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDuracionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duración (minutos)',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<int>(
                title: const Text('30 min'),
                value: 30,
                groupValue: _duracionMinutos,
                onChanged: (value) {
                  setState(() {
                    _duracionMinutos = value!;
                  });
                },
                activeColor: AppColors.primaryBlue,
              ),
            ),
            Expanded(
              child: RadioListTile<int>(
                title: const Text('60 min'),
                value: 60,
                groupValue: _duracionMinutos,
                onChanged: (value) {
                  setState(() {
                    _duracionMinutos = value!;
                  });
                },
                activeColor: AppColors.primaryBlue,
              ),
            ),
            Expanded(
              child: RadioListTile<int>(
                title: const Text('90 min'),
                value: 90,
                groupValue: _duracionMinutos,
                onChanged: (value) {
                  setState(() {
                    _duracionMinutos = value!;
                  });
                },
                activeColor: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotasField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notas Adicionales',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notasController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            hintText: 'Información adicional sobre la cita (opcional)',
            prefixIcon: const Icon(Icons.note, color: AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }

  Widget _buildBotonCrear(CitasState state) {
    final esLoading = state is CitasLoading;
    
    return ElevatedButton.icon(
      onPressed: esLoading ? null : _crearCita,
      icon: esLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.add),
      label: Text(
        esLoading ? 'Creando Cita...' : 'Crear Cita',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final fechaInicial = DateTime.now().add(const Duration(days: 1));
    final fechaFinal = DateTime.now().add(const Duration(days: 90));
    
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: fechaInicial,
      lastDate: fechaFinal,
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
      });
    }
  }

  void _crearCita() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione una fecha'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    
    if (_horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione una hora'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    
    // Combinar fecha y hora
    final fechaCompleta = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaSeleccionada!.hour,
      _horaSeleccionada!.minute,
    );
    
    context.read<CitasBloc>().add(
      CrearCitaEvent(
        pacienteId: 'current-user-id', // TODO: Obtener del contexto
        terapeutaId: 'default-therapist-id', // TODO: Selección de terapeuta
        fechaCita: _fechaSeleccionada!,
        horaCita: fechaCompleta,
        tipoMasaje: _tipoMasajeController.text,
        duracionMinutos: _duracionMinutos,
        notas: _notasController.text.isEmpty ? null : _notasController.text,
      ),
    );
  }
}
