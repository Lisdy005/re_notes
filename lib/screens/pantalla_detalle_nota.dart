import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/nota.dart';
import '../state/estado_app.dart';
import '../utilidades/fechas.dart';
import '../widgets/dialogo_confirmacion.dart';
import '../widgets/etiquetas_nota.dart';

class PantallaDetalleNota extends StatelessWidget {
  final String id_nota;

  const PantallaDetalleNota({super.key, required this.id_nota});

  // Vuelve a la pantalla anterior
  void _volver(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/proyectos');
    }
  }

  Future<void> _eliminar(BuildContext context, Nota nota) async {
    final confirmado = await confirmar(
      context,
      titulo: 'Eliminar nota',
      mensaje: '¿Eliminar la nota "${nota.titulo}"?',
    );
    if (!confirmado || !context.mounted) return;
    estado.eliminar_nota(nota.id);
    _volver(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final nota = estado.nota_por_id(id_nota);

        // Por si la nota se eliminó mientras esta pantalla estaba abierta
        if (nota == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Volver',
                onPressed: () => _volver(context),
              ),
            ),
            body: const Center(child: Text('La nota ya no existe')),
          );
        }

        final proyecto = estado.proyecto_por_id(nota.id_proyecto);
        final textos = Theme.of(context).textTheme;
        final colores = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Volver',
              onPressed: () => _volver(context),
            ),
            title: const Text('Detalle de nota'),
          ),
          // Toda la información cabe en una columna con scroll, así no hay overflow aunque el texto sea largo o la pantalla pequeña
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nota.titulo, style: textos.headlineSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.folder_outlined, size: 18, color: colores.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        proyecto?.nombre ?? 'Proyecto eliminado',
                        style: textos.bodyMedium?.copyWith(color: colores.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Creada: ${formatear_fecha_hora(nota.fecha_creacion)}',
                  style: textos.bodySmall,
                ),
                Text(
                  'Modificada: ${formatear_fecha_hora(nota.fecha_modificacion)}',
                  style: textos.bodySmall,
                ),
                const Divider(height: 32),
                Text('Etiquetas', style: textos.titleSmall),
                const SizedBox(height: 8),
                if (nota.ids_etiquetas.isEmpty)
                  const Text('Esta nota no tiene etiquetas.')
                else ...[
                  EtiquetasNota(
                    ids_etiquetas: nota.ids_etiquetas,
                    // Abre la pestaña Etiquetas filtrada por la etiqueta tocada
                    al_tocar: (etiqueta) =>
                        context.go('/etiquetas/etiqueta/${etiqueta.id}'),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Toca una etiqueta para ver las notas que la comparten.',
                    style: textos.bodySmall,
                  ),
                ],
                const Divider(height: 32),
                Text('Descripción', style: textos.titleSmall),
                const SizedBox(height: 8),
                if (nota.descripcion.trim().isEmpty)
                  Text(
                    'Esta nota no tiene descripción.',
                    style: textos.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Text(nota.descripcion, style: textos.bodyLarge),
              ],
            ),
          ),
          // Los botones quedan fijos abajo, siempre visibles
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _eliminar(context, nota),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/editar_nota/${nota.id}'),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}