import 'package:flutter/material.dart';
import '../modelos/proyecto.dart';
import '../state/estado_app.dart';

class DialogoProyecto extends StatefulWidget {
  final Proyecto? proyecto; // si es null se crea y si trae un proyecto se edita

  const DialogoProyecto({super.key, this.proyecto});

  @override
  State<DialogoProyecto> createState() => _EstadoDialogoProyecto();
}

class _EstadoDialogoProyecto extends State<DialogoProyecto> {
  final _clave_formulario = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.proyecto?.nombre ?? '');
    _descripcion =
        TextEditingController(text: widget.proyecto?.descripcion ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_clave_formulario.currentState!.validate()) return;
    final proyecto = widget.proyecto;
    if (proyecto == null) {
      estado.crear_proyecto(_nombre.text, _descripcion.text);
    } else {
      estado.editar_proyecto(proyecto.id, _nombre.text, _descripcion.text);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.proyecto == null ? 'Nuevo proyecto' : 'Editar proyecto',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _clave_formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombre,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcion,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción corta',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}