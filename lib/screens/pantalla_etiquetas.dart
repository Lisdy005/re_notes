import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/etiqueta.dart';
import '../state/estado_app.dart';
import '../utilidades/texto.dart';
import '../widgets/dialogo_confirmacion.dart';
import '../widgets/dialogo_etiqueta.dart';
import '../widgets/etiquetas_nota.dart';
import '../widgets/tarjeta_nota.dart';

class PantallaEtiquetas extends StatelessWidget {
  // Sin valor: lista de etiquetas.
  // Con valor: notas de esa etiqueta, o de varias etiquetas unidas con "_"
  final String? id_etiqueta;

  const PantallaEtiquetas({super.key, this.id_etiqueta});

  @override
  Widget build(BuildContext context) {
    final id = id_etiqueta;
    if (id == null) return const _ListaEtiquetas();
    return _NotasDeEtiquetas(ids: id.split('_'));
  }
}

// Vista 1: lista de etiquetas

class _ListaEtiquetas extends StatefulWidget {
  const _ListaEtiquetas();

  @override
  State<_ListaEtiquetas> createState() => _EstadoListaEtiquetas();
}

class _EstadoListaEtiquetas extends State<_ListaEtiquetas> {
  final TextEditingController _buscador = TextEditingController();
  String _texto = '';
  final Set<String> _seleccion = {}; // etiquetas marcadas para agrupar notas

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _eliminar(Etiqueta etiqueta) async {
    final cantidad = estado.cantidad_notas_de_etiqueta(etiqueta.id);
    var mensaje = '¿Eliminar la etiqueta "${etiqueta.nombre}"?';
    if (cantidad == 0) {
      mensaje += ' No está en ninguna nota.';
    } else {
      final notas = cantidad == 1 ? '1 nota' : '$cantidad notas';
      mensaje += ' Se quitará de $notas. Las notas no se eliminan.';
    }
    final confirmado = await confirmar(
      context,
      titulo: 'Eliminar etiqueta',
      mensaje: mensaje,
    );
    if (!confirmado || !mounted) return;
    estado.eliminar_etiqueta(etiqueta.id);
    setState(() => _seleccion.remove(etiqueta.id));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final consulta = normalizar(_texto);
        final visibles = estado.etiquetas
            .where((e) =>
        consulta.isEmpty || normalizar(e.nombre).contains(consulta))
            .toList();
        visibles.sort(
              (a, b) => normalizar(a.nombre).compareTo(normalizar(b.nombre)),
        );

        // Por si una etiqueta marcada se eliminó.
        final seleccion_valida = _seleccion
            .where((id) => estado.etiqueta_por_id(id) != null)
            .toList();

        Widget contenido;
        if (estado.etiquetas.isEmpty) {
          contenido = const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Todavía no hay etiquetas.\nToca "Nueva etiqueta" para crear la primera.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (visibles.isEmpty) {
          contenido = const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Ninguna etiqueta coincide con la búsqueda.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          contenido = ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: visibles.length,
            itemBuilder: (context, indice) {
              final etiqueta = visibles[indice];
              final cantidad = estado.cantidad_notas_de_etiqueta(etiqueta.id);
              final texto_notas = cantidad == 1 ? '1 nota' : '$cantidad notas';
              final color =
                  etiqueta.color ?? Theme.of(context).colorScheme.outline;

              return ListTile(
                leading: Checkbox(
                  value: _seleccion.contains(etiqueta.id),
                  onChanged: (valor) => setState(() {
                    if (valor == true) {
                      _seleccion.add(etiqueta.id);
                    } else {
                      _seleccion.remove(etiqueta.id);
                    }
                  }),
                ),
                title: Row(
                  children: [
                    CircleAvatar(radius: 6, backgroundColor: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        etiqueta.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(texto_notas),
                trailing: PopupMenuButton<String>(
                  onSelected: (opcion) {
                    if (opcion == 'renombrar') {
                      showDialog(
                        context: context,
                        builder: (_) => DialogoEtiqueta(etiqueta: etiqueta),
                      );
                    } else {
                      _eliminar(etiqueta);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'renombrar', child: Text('Renombrar')),
                    PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                  ],
                ),
                // Al tocar la etiqueta se ven sus notas, de todos los proyectos.
                onTap: () => context.push('/etiquetas/etiqueta/${etiqueta.id}'),
              );
            },
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Etiquetas')),
          floatingActionButton: seleccion_valida.isEmpty
              ? FloatingActionButton.extended(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const DialogoEtiqueta(),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Nueva etiqueta'),
          )
              : null,
          // Aparece solo cuando hay etiquetas marcadas.
          bottomNavigationBar: seleccion_valida.isEmpty
              ? null
              : Material(
            elevation: 8,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        seleccion_valida.length == 1
                            ? '1 etiqueta elegida'
                            : '${seleccion_valida.length} etiquetas elegidas',
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _seleccion.clear()),
                      child: const Text('Limpiar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => context.push(
                        '/etiquetas/etiqueta/${seleccion_valida.join('_')}',
                      ),
                      child: const Text('Ver notas'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: TextField(
                  controller: _buscador,
                  onChanged: (valor) => setState(() => _texto = valor),
                  decoration: InputDecoration(
                    hintText: 'Buscar etiqueta',
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
              if (estado.etiquetas.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Marca varias etiquetas para ver sus notas juntas.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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

// Vista 2: notas de una o varias etiquetas (de todos los proyectos)

class _NotasDeEtiquetas extends StatefulWidget {
  final List<String> ids;

  const _NotasDeEtiquetas({required this.ids});

  @override
  State<_NotasDeEtiquetas> createState() => _EstadoNotasDeEtiquetas();
}

class _EstadoNotasDeEtiquetas extends State<_NotasDeEtiquetas> {
  bool _todas = false; // false: al menos una; true: todas

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final etiquetas = <Etiqueta>[];
        for (final id in widget.ids) {
          final etiqueta = estado.etiqueta_por_id(id);
          if (etiqueta != null) etiquetas.add(etiqueta);
        }

        if (etiquetas.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('La etiqueta ya no existe')),
          );
        }

        final notas = estado.filtrar_notas(
          ids_etiquetas: etiquetas.map((e) => e.id).toSet(),
          todas: _todas,
        );

        final String mensaje_vacio;
        if (etiquetas.length == 1) {
          mensaje_vacio = 'Esta etiqueta todavía no está en ninguna nota.';
        } else if (_todas) {
          mensaje_vacio = 'Ninguna nota tiene todas las etiquetas elegidas.';
        } else {
          mensaje_vacio = 'Ninguna nota tiene estas etiquetas.';
        }

        Widget contenido;
        if (notas.isEmpty) {
          contenido = Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(mensaje_vacio, textAlign: TextAlign.center),
            ),
          );
        } else {
          contenido = ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: notas.length,
            itemBuilder: (context, indice) {
              return Column(
                children: [
                  TarjetaNota(nota: notas[indice], mostrar_proyecto: true),
                  const Divider(height: 1),
                ],
              );
            },
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              etiquetas.length == 1
                  ? 'Etiqueta: ${etiquetas.first.nombre}'
                  : 'Notas por etiquetas',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: EtiquetasNota(
                  ids_etiquetas: etiquetas.map((e) => e.id).toList(),
                ),
              ),
              // Con varias etiquetas, se elige cómo agrupar las notas
              if (etiquetas.length > 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Al menos una')),
                      ButtonSegment(value: true, label: Text('Todas')),
                    ],
                    selected: {_todas},
                    onSelectionChanged: (valor) =>
                        setState(() => _todas = valor.first),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  notas.length == 1 ? '1 nota' : '${notas.length} notas',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const Divider(height: 1),
              Expanded(child: contenido),
            ],
          ),
        );
      },
    );
  }
}