import 'package:flutter/material.dart';
import '../state/estado_app.dart';
import '../widgets/tarjeta_nota.dart';

class PantallaBuscar extends StatefulWidget {
  const PantallaBuscar({super.key});

  @override
  State<PantallaBuscar> createState() => _EstadoPantallaBuscar();
}

class _EstadoPantallaBuscar extends State<PantallaBuscar> {
  final TextEditingController _buscador = TextEditingController();
  String _texto = '';
  String? _id_proyecto; // null = todos los proyectos
  final Set<String> _ids_etiquetas = {};

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  void _quitar_filtros() {
    setState(() {
      _buscador.clear();
      _texto = '';
      _id_proyecto = null;
      _ids_etiquetas.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se reconstruye cada vez que cambian notas, proyectos o etiquetas
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final proyectos = estado.proyectos;
        final etiquetas = estado.etiquetas;

        // Por si el proyecto o una etiqueta elegida se eliminaron
        final id_proyecto_valido =
        (_id_proyecto != null && estado.proyecto_por_id(_id_proyecto!) != null)
            ? _id_proyecto
            : null;
        final ids_validos = _ids_etiquetas
            .where((id) => estado.etiqueta_por_id(id) != null)
            .toSet();

        final resultados = estado.filtrar_notas(
          texto: _texto,
          id_proyecto: id_proyecto_valido,
          ids_etiquetas: ids_validos,
        );

        final hay_filtros = _texto.trim().isNotEmpty ||
            id_proyecto_valido != null ||
            ids_validos.isNotEmpty;

        Widget contenido;
        if (resultados.isEmpty) {
          contenido = Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    estado.notas.isEmpty
                        ? 'Todavía no hay notas para buscar.'
                        : 'No se encontraron notas con esa búsqueda o filtros.',
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
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: resultados.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, indice) {
              return TarjetaNota(
                nota: resultados[indice],
                mostrar_proyecto: true,
              );
            },
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Buscar')),
          body: Column(
            children: [
              // Campo de búsqueda
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: TextField(
                  controller: _buscador,
                  textInputAction: TextInputAction.search,
                  onChanged: (valor) => setState(() => _texto = valor),
                  decoration: InputDecoration(
                    hintText: 'Buscar en todas las notas',
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
              // Filtro por proyecto
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Proyecto',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      value: id_proyecto_valido,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todos los proyectos'),
                        ),
                        ...proyectos.map(
                              (proyecto) => DropdownMenuItem<String?>(
                            value: proyecto.id,
                            child: Text(
                              proyecto.nombre,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (valor) => setState(() => _id_proyecto = valor),
                    ),
                  ),
                ),
              ),
              // Filtro por etiquetas (lista horizontal)
              if (etiquetas.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: etiquetas.length,
                    itemBuilder: (context, indice) {
                      final etiqueta = etiquetas[indice];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(etiqueta.nombre),
                          selected: ids_validos.contains(etiqueta.id),
                          onSelected: (elegida) => setState(() {
                            if (elegida) {
                              _ids_etiquetas.add(etiqueta.id);
                            } else {
                              _ids_etiquetas.remove(etiqueta.id);
                            }
                          }),
                        ),
                      );
                    },
                  ),
                ),
              // Cantidad de resultados
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    resultados.length == 1
                        ? '1 resultado'
                        : '${resultados.length} resultados',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
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