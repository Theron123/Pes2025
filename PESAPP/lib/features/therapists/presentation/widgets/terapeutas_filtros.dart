import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/domain/entities/therapist_entity.dart';

/// Widget de filtros para la lista de terapeutas
class TerapeutasFiltros extends StatelessWidget {
  final bool disponibleSolo;
  final EspecializacionMasaje? especializacionSeleccionada;
  final Function({bool? disponibleSolo, EspecializacionMasaje? especializacion}) onFiltrosAplicados;
  final VoidCallback onFiltrosLimpiados;

  const TerapeutasFiltros({
    super.key,
    required this.disponibleSolo,
    required this.especializacionSeleccionada,
    required this.onFiltrosAplicados,
    required this.onFiltrosLimpiados,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Solo disponibles'),
            value: disponibleSolo,
            onChanged: (value) {
              onFiltrosAplicados(disponibleSolo: value ?? false);
            },
            activeColor: AppColors.primaryBlue,
          ),
          const SizedBox(height: 8),
          const Text(
            'Especialización',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<EspecializacionMasaje>(
            value: especializacionSeleccionada,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'Todas las especializaciones',
            ),
            items: EspecializacionMasaje.values.map((esp) {
              return DropdownMenuItem(
                value: esp,
                child: Text(esp.descripcion),
              );
            }).toList(),
            onChanged: (value) {
              onFiltrosAplicados(especializacion: value);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onFiltrosLimpiados,
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    onFiltrosAplicados();
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
  }
}
