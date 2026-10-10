import 'package:flutter/material.dart';
import '../modelos/etiqueta.dart';
import '../state/estado_app.dart';

class DialogoEtiqueta extends StatefulWidget {
  final Etiqueta? etiqueta; // si es null se crea, si trae una etiqueta se renombra

  const DialogoEtiqueta({super.key, this.etiqueta});

  @override
  State<DialogoEtiqueta> createState() => _EstadoDialogoEtiqueta();
}

class _EstadoDialogoEtiqueta extends State<DialogoEtiqueta> {
  late final TextEditingController _nombre;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.etiqueta?.nombre ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _guardar() {
    final texto = _nombre.text.trim();
    if (texto.isEmpty) {
      setState(() => _error = 'El nombre es obligatorio');
      return;
    }

    final etiqueta = widget.etiqueta;
    if (etiqueta == null) {
      // Crear: se rechaza si ya existe una con ese nombre
      if (estado.etiqueta_por_nombre(texto) != null) {
        setState(() => _error = 'Ya existe una etiqueta con ese nombre');
        return;
      }
      estado.crear_etiqueta(texto);
    } else {
      // Renombrar: el estado devuelve un mensaje si no se puede
      final error = estado.renombrar_etiqueta(etiqueta.id, texto);
      if (error != null) {
        setState(() => _error = error);
        return;
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.etiqueta == null ? 'Nueva etiqueta' : 'Renombrar etiqueta',
      ),
      content: TextField(
        controller: _nombre,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Nombre',
          errorText: _error,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        onSubmitted: (_) => _guardar(),
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