import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/etiqueta.dart';
import '../modelos/nota.dart';
import '../state/estado_app.dart';
import '../utilidades/texto.dart';
import '../widgets/dialogo_confirmacion.dart';

// Una sugerencia del autocompletado
class _OpcionEtiqueta {
  final Etiqueta? existente; // null cuando la opción es "crear"
  final String nombre;

  _OpcionEtiqueta({this.existente, required this.nombre});

  bool get es_nueva => existente == null;
}

class PantallaEditorNota extends StatefulWidget {
  final String? id_proyecto; // viene si se está creando una nota
  final String? id_nota; // viene si se está editando una nota

  const PantallaEditorNota({super.key, this.id_proyecto, this.id_nota});

  @override
  State<PantallaEditorNota> createState() => _EstadoPantallaEditorNota();
}

class _EstadoPantallaEditorNota extends State<PantallaEditorNota> {
  final _clave_formulario = GlobalKey<FormState>();
  final _clave_seccion_etiquetas = GlobalKey();

  late final TextEditingController _titulo;
  late final TextEditingController _descripcion;
  final TextEditingController _campo_etiqueta = TextEditingController();
  final FocusNode _foco_etiqueta = FocusNode();

  Nota? _nota; // null cuando se está creando una nota nueva

  // El borrador: lo que se está escribiendo. La nota real no cambia hasta pulsar Guardar
  final List<String> _nombres_etiquetas = [];

  // Valores iniciales para saber si hay cambios sin guardar
  late final String _titulo_original;
  late final String _descripcion_original;
  late final List<String> _nombres_originales;

  bool _permitir_salir = false;

  @override
  void initState() {
    super.initState();
    final id = widget.id_nota;
    _nota = id == null ? null : estado.nota_por_id(id);

    _titulo_original = _nota?.titulo ?? '';
    _descripcion_original = _nota?.descripcion ?? '';
    _titulo = TextEditingController(text: _titulo_original);
    _descripcion = TextEditingController(text: _descripcion_original);

    if (_nota != null) {
      for (final id_etiqueta in _nota!.ids_etiquetas) {
        final etiqueta = estado.etiqueta_por_id(id_etiqueta);
        if (etiqueta != null) _nombres_etiquetas.add(etiqueta.nombre);
      }
    }
    _nombres_originales = List.of(_nombres_etiquetas);

    // Cada cambio en los textos reconstruye la pantalla, para que el aviso de "cambios sin guardar" siempre esté actualizado
    _titulo.addListener(_al_cambiar);
    _descripcion.addListener(_al_cambiar);

    _foco_etiqueta.addListener(() {
      if (!_foco_etiqueta.hasFocus) return;
      Future.delayed(const Duration(milliseconds: 350), () {
        final contexto = _clave_seccion_etiquetas.currentContext;
        if (mounted && contexto != null) {
          Scrollable.ensureVisible(
            contexto,
            alignment: 0.0,
            duration: const Duration(milliseconds: 250),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _campo_etiqueta.dispose();
    _foco_etiqueta.dispose();
    super.dispose();
  }

  void _al_cambiar() => setState(() {});

  bool get _hay_cambios {
    if (_titulo.text != _titulo_original) return true;
    if (_descripcion.text != _descripcion_original) return true;
    final actuales = _nombres_etiquetas.map(normalizar).toSet();
    final originales = _nombres_originales.map(normalizar).toSet();
    return actuales.length != originales.length ||
        !actuales.containsAll(originales);
  }

  // ---------- Etiquetas del borrador ----------

  // Agrega una etiqueta al borrador sin duplicados. Si ya existe una etiqueta con ese nombre esta se reutiliza
  void _agregar_nombre(String texto) {
    final nombre = texto.trim();
    if (nombre.isEmpty) return;
    final clave = normalizar(nombre);
    final ya_asignada = _nombres_etiquetas.any((n) => normalizar(n) == clave);
    if (ya_asignada) return;
    final existente = estado.etiqueta_por_nombre(nombre);
    setState(() {
      _nombres_etiquetas.add(existente?.nombre ?? nombre);
    });
  }

  void _quitar_nombre(String nombre) {
    setState(() => _nombres_etiquetas.remove(nombre));
  }

  // Al escribir una coma, lo anterior se confirma como etiqueta
  void _al_cambiar_texto_etiqueta(String texto) {
    if (!texto.contains(',')) return;
    final partes = texto.split(',');
    final resto = partes.removeLast();
    for (final parte in partes) {
      _agregar_nombre(parte);
    }
    _campo_etiqueta.value = TextEditingValue(
      text: resto,
      selection: TextSelection.collapsed(offset: resto.length),
    );
  }

  // Las sugerencias del autocompletado.
  Iterable<_OpcionEtiqueta> _opciones(TextEditingValue valor) {
    final consulta = normalizar(valor.text);
    if (consulta.isEmpty) return const <_OpcionEtiqueta>[];

    final asignadas = _nombres_etiquetas.map(normalizar).toSet();
    final opciones = <_OpcionEtiqueta>[];
    var coincide_exacta = false;

    // Se revisan las etiquetas de todas las notas de todos los proyectos.
    for (final etiqueta in estado.etiquetas) {
      final nombre_normal = normalizar(etiqueta.nombre);
      if (nombre_normal == consulta) coincide_exacta = true;
      if (asignadas.contains(nombre_normal)) continue; // ya la tiene la nota
      if (nombre_normal.contains(consulta)) {
        opciones.add(_OpcionEtiqueta(existente: etiqueta, nombre: etiqueta.nombre));
      }
    }

    // Si no existe una etiqueta con ese nombre exacto, se ofrece crearla.
    if (!coincide_exacta) {
      opciones.add(_OpcionEtiqueta(nombre: valor.text.trim()));
    }
    return opciones;
  }

  // ---------- Guardar y salir ----------

  void _salir() {
    setState(() => _permitir_salir = true);
    // Se espera a que la pantalla se reconstruya con la salida permitida.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  Future<void> _cancelar() async {
    if (_hay_cambios) {
      final salir = await confirmar(
        context,
        titulo: 'Cambios sin guardar',
        mensaje: 'Tienes cambios sin guardar. ¿Quieres salir sin guardarlos?',
        texto_confirmar: 'Salir',
        texto_cancelar: 'Seguir editando',
      );
      if (!salir || !mounted) return;
    }
    _salir();
  }

  void _guardar() {
    if (!_clave_formulario.currentState!.validate()) return;

    // Aquí se crean las etiquetas nuevas; si ya existen, se reutilizan.
    final ids = <String>[];
    for (final nombre in _nombres_etiquetas) {
      ids.add(estado.crear_etiqueta(nombre).id);
    }

    final nota = _nota;
    if (nota == null) {
      estado.crear_nota(
        id_proyecto: widget.id_proyecto!,
        titulo: _titulo.text,
        descripcion: _descripcion.text,
        ids_etiquetas: ids,
      );
    } else {
      estado.actualizar_nota(
        nota.id,
        titulo: _titulo.text,
        descripcion: _descripcion.text,
        ids_etiquetas: ids,
      );
    }
    _salir();
  }

  // ---------- Pantalla ----------

  @override
  Widget build(BuildContext context) {
    // Por si se intenta editar una nota que ya no existe.
    if (widget.id_nota != null && _nota == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editor de nota')),
        body: const Center(child: Text('La nota ya no existe')),
      );
    }

    final textos = Theme.of(context).textTheme;

    return PopScope(
      // Si hay cambios sin guardar, la flecha atrás pide confirmación.
      canPop: !_hay_cambios || _permitir_salir,
      onPopInvokedWithResult: (ya_salio, resultado) {
        if (ya_salio) return;
        _cancelar();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_nota == null ? 'Nueva nota' : 'Editar nota'),
        ),
        // Todo va dentro de un scroll: con el teclado abierto o en
        // pantallas pequeñas se desplaza en vez de dar overflow.
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _clave_formulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                TextFormField(
                  controller: _titulo,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'El título es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Etiquetas
                Column(
                  key: _clave_seccion_etiquetas,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Etiquetas', style: textos.titleSmall),
                    const SizedBox(height: 8),
                    if (_nombres_etiquetas.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _nombres_etiquetas.map((nombre) {
                          final color = estado.etiqueta_por_nombre(nombre)?.color ??
                              Theme.of(context).colorScheme.outline;
                          return Chip(
                            avatar: CircleAvatar(radius: 5, backgroundColor: color),
                            label: Text(nombre),
                            deleteButtonTooltipMessage: 'Quitar etiqueta',
                            onDeleted: () => _quitar_nombre(nombre),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    LayoutBuilder(
                      builder: (context, restricciones) {
                        return RawAutocomplete<_OpcionEtiqueta>(
                          textEditingController: _campo_etiqueta,
                          focusNode: _foco_etiqueta,
                          optionsBuilder: _opciones,
                          displayStringForOption: (opcion) => opcion.nombre,
                          onSelected: (opcion) {
                            _agregar_nombre(opcion.nombre);
                            _campo_etiqueta.clear();
                            _foco_etiqueta.requestFocus();
                          },
                          fieldViewBuilder: (context, controlador, foco, _) {
                            return TextField(
                              controller: controlador,
                              focusNode: foco,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Agregar etiqueta',
                                hintText: 'Escribe y confirma con Enter o una coma',
                                prefixIcon: Icon(Icons.label_outline),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: _al_cambiar_texto_etiqueta,
                              // Esta función vacía evita que el teclado se
                              // cierre al pulsar Enter.
                              onEditingComplete: () {},
                              onSubmitted: (texto) {
                                _agregar_nombre(texto);
                                controlador.clear();
                                foco.requestFocus();
                              },
                            );
                          },
                          optionsViewBuilder: (context, al_elegir, opciones) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(8),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: 200,
                                    maxWidth: restricciones.maxWidth,
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: opciones.length,
                                    itemBuilder: (context, indice) {
                                      final opcion = opciones.elementAt(indice);
                                      return ListTile(
                                        dense: true,
                                        leading: Icon(
                                          opcion.es_nueva
                                              ? Icons.add_circle_outline
                                              : Icons.label_outline,
                                        ),
                                        title: Text(
                                          opcion.es_nueva
                                              ? 'Crear etiqueta "${opcion.nombre}"'
                                              : opcion.nombre,
                                        ),
                                        onTap: () => al_elegir(opcion),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Descripción: texto largo, con scroll interno
                TextFormField(
                  controller: _descripcion,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 8,
                  maxLines: 14,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Botones fijos abajo, siempre visibles.
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelar,
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _guardar,
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}