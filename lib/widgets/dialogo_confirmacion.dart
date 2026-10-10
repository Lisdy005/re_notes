import 'package:flutter/material.dart';

// Muestra una pregunta con dos botones y devuelve true si se confirma
Future<bool> confirmar(
    BuildContext context, {
      required String titulo,
      required String mensaje,
      String texto_confirmar = 'Eliminar',
      String texto_cancelar = 'Cancelar',
    }) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(contexto).pop(false),
          child: Text(texto_cancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.of(contexto).pop(true),
          child: Text(texto_confirmar),
        ),
      ],
    ),
  );
  return resultado ?? false;
}