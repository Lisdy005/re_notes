import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/nota.dart';
import '../state/estado_app.dart';
import '../widgets/dialogo_confirmacion.dart';
import '../widgets/tarjeta_nota.dart';

class PantallaNotasProyecto extends StatefulWidget {
  final String id_proyecto;

  const PantallaNotasProyecto({super.key, required this.id_proyecto});

  @override
  State<PantallaNotasProyecto> createState() => _EstadoPantallaNotasProyecto();
}

class _EstadoPantallaNotasProyecto extends State<PantallaNotasProyecto> {
  final TextEditingController _buscador = TextEditingController();
  String _texto = '';
  final Set<String> _ids_filtro = {}; // etiquetas elegidas en el filtro

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _eliminar(Nota nota) async {
    final confirmado = await confirmar(
      context,
      titulo: 'Eliminar nota',
      mensaje: '¿Eliminar la nota "${nota.titulo}"?',
    );
    if (confirmado) {
      estado.eliminar_nota(nota.id);
    }
  }

  void _quitar_filtros() {
    setState(() {
      _buscador.clear();
      _texto = '';
      _ids_filtro.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final proyecto = estado.proyecto_por_id(widget.id_proyecto);
        if (proyecto == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('El proyecto ya no existe')),
          );
        }

        final total = estado.cantidad_notas_de_proyecto(proyecto.id);

        // Solo las etiquetas que aparecen en las notas de este proyecto
        final disponibles = estado.etiquetas_de_proyecto(proyecto.id);
        final ids_disponibles = disponibles.map((e) => e.id).toSet();
        // Por si una etiqueta elegida ya no está en ninguna nota.
        final ids_activos = _ids_filtro.where(ids_disponibles.contains).toSet();

        final notas = estado.filtrar_notas(
          texto: _texto,
          id_proyecto: proyecto.id,
          ids_etiquetas: ids_activos,
        );
        final hay_filtros = _texto.trim().isNotEmpty || ids_activos.isNotEmpty;

        Widget contenido;
        if (total == 0) {
          contenido = const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Este proyecto todavía no tiene notas.\nToca "Nueva nota" para crear la primera.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (notas.isEmpty) {
          contenido = Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ninguna nota coincide con la búsqueda o el filtro.',
                    textAlign: TextAlign.center,
                  ),
                  if (hay_filtros)
                    TextButton(
                      onPressed: _quitar_filtros,
                      child: const Text('Quitar búsqueda y filtros'),
                    ),
                ],
              ),
            ),
          );
        } else {
          contenido = ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: notas.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, indice) {
              final nota = notas[indice];
              return TarjetaNota(
                nota: nota,
                accion: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar nota',
                  onPressed: () => _eliminar(nota),
                ),
              );
            },
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proyecto.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  total == 1 ? '1 nota' : '$total notas',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/nueva_nota/${proyecto.id}'),
            icon: const Icon(Icons.add),
            label: const Text('Nueva nota'),
          ),
          body: Column(
            children: [
              // Búsqueda por título o contenido
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: TextField(
                  controller: _buscador,
                  onChanged: (valor) => setState(() => _texto = valor),
                  decoration: InputDecoration(
                    hintText: 'Buscar por título o contenido',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _texto.isEmpty
                        ? null
                        : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _buscador.clear();
                        _texto = '';
                      }),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              // Filtro por etiquetas
              if (disponibles.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: disponibles.length,
                    itemBuilder: (context, indice) {
                      final etiqueta = disponibles[indice];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(etiqueta.nombre),
                          selected: ids_activos.contains(etiqueta.id),
                          onSelected: (elegida) => setState(() {
                            if (elegida) {
                              _ids_filtro.add(etiqueta.id);
                            } else {
                              _ids_filtro.remove(etiqueta.id);
                            }
                          }),
                        ),
                      );
                    },
                  ),
                ),
              Expanded(child: contenido),
            ],
          ),
        );
      },
    );
  }
}