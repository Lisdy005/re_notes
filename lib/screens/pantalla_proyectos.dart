import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/proyecto.dart';
import '../state/estado_app.dart';
import '../utilidades/fechas.dart';
import '../widgets/dialogo_confirmacion.dart';
import '../widgets/dialogo_proyecto.dart';

class PantallaProyectos extends StatelessWidget {
  const PantallaProyectos({super.key});

  Future<void> _eliminar(BuildContext context, Proyecto proyecto) async {
    final cantidad = estado.cantidad_notas_de_proyecto(proyecto.id);
    String mensaje = '¿Eliminar el proyecto "${proyecto.nombre}"?';
    if (cantidad > 0) {
      final notas = cantidad == 1 ? 'su nota' : 'sus $cantidad notas';
      mensaje += ' También se eliminarán $notas. Las etiquetas no se eliminan.';
    }
    final confirmado = await confirmar(
      context,
      titulo: 'Eliminar proyecto',
      mensaje: mensaje,
    );
    if (confirmado) {
      estado.eliminar_proyecto(proyecto.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proyectos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const DialogoProyecto(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo proyecto'),
      ),
      // Se reconstruye cada vez que el estado avisa de un cambio
      body: ListenableBuilder(
        listenable: estado,
        builder: (context, _) {
          final proyectos = estado.proyectos;

          if (proyectos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Todavía no hay proyectos.\nToca "Nuevo proyecto" para crear el primero.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
            itemCount: proyectos.length,
            itemBuilder: (context, indice) {
              final proyecto = proyectos[indice];
              final cantidad = estado.cantidad_notas_de_proyecto(proyecto.id);
              final texto_notas = cantidad == 1 ? '1 nota' : '$cantidad notas';

              return Card(
                child: ListTile(
                  title: Text(
                    proyecto.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (proyecto.descripcion.isNotEmpty)
                        Text(
                          proyecto.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '$texto_notas · Modificado: ${formatear_fecha(proyecto.fecha_modificacion)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (opcion) {
                      if (opcion == 'editar') {
                        showDialog(
                          context: context,
                          builder: (_) => DialogoProyecto(proyecto: proyecto),
                        );
                      } else {
                        _eliminar(context, proyecto);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'editar', child: Text('Editar')),
                      PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                    ],
                  ),
                  onTap: () =>
                      context.push('/proyectos/proyecto/${proyecto.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}