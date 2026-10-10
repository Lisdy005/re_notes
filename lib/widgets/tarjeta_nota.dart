import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/nota.dart';
import '../state/estado_app.dart';
import '../utilidades/fechas.dart';
import '../utilidades/texto.dart';
import 'etiquetas_nota.dart';

class TarjetaNota extends StatelessWidget {
  final Nota nota;
  final bool mostrar_proyecto; // true en Etiquetas y Buscar
  final Widget? accion; // por ejemplo, el botón de eliminar

  const TarjetaNota({
    super.key,
    required this.nota,
    this.mostrar_proyecto = false,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;
    final proyecto = estado.proyecto_por_id(nota.id_proyecto);

    return InkWell(
      onTap: () => context.push('/nota/${nota.id}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nota.titulo,
                    style: textos.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (mostrar_proyecto && proyecto != null)
                    Text(
                      'Proyecto: ${proyecto.nombre}',
                      style: textos.bodySmall?.copyWith(color: colores.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (nota.descripcion.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      extracto(nota.descripcion),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (nota.ids_etiquetas.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    EtiquetasNota(ids_etiquetas: nota.ids_etiquetas),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'Modificada: ${formatear_fecha(nota.fecha_modificacion)}',
                    style: textos.bodySmall,
                  ),
                ],
              ),
            ),
            if (accion != null) accion!,
          ],
        ),
      ),
    );
  }
}