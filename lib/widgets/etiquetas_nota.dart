import 'package:flutter/material.dart';
import '../modelos/etiqueta.dart';
import '../state/estado_app.dart';

class EtiquetasNota extends StatelessWidget {
  final List<String> ids_etiquetas;
  // Si se indica, cada etiqueta se puede tocar. Si no, solo se muestran
  final void Function(Etiqueta etiqueta)? al_tocar;

  const EtiquetasNota({
    super.key,
    required this.ids_etiquetas,
    this.al_tocar,
  });

  @override
  Widget build(BuildContext context) {
    final etiquetas = <Etiqueta>[];
    for (final id in ids_etiquetas) {
      final etiqueta = estado.etiqueta_por_id(id);
      if (etiqueta != null) etiquetas.add(etiqueta);
    }
    if (etiquetas.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: etiquetas.map((etiqueta) {
        final color = etiqueta.color ?? Theme.of(context).colorScheme.outline;
        final punto = CircleAvatar(radius: 5, backgroundColor: color);

        if (al_tocar == null) {
          return Chip(
            avatar: punto,
            label: Text(etiqueta.nombre),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        }
        return ActionChip(
          avatar: punto,
          label: Text(etiqueta.nombre),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () => al_tocar!(etiqueta),
        );
      }).toList(),
    );
  }
}