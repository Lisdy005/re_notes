import 'package:flutter/material.dart';

class Etiqueta {
  final String id;
  String nombre;
  Color? color; // opcional, por eso lleva el signo ?

  Etiqueta({
    required this.id,
    required this.nombre,
    this.color,
  });
}