class Nota {
  final String id;
  final String id_proyecto; // a qué proyecto pertenece (solo a uno)
  String titulo;
  String descripcion;
  final DateTime fecha_creacion;
  DateTime fecha_modificacion;
  List<String> ids_etiquetas; // guarda los id de las etiquetas, no las etiquetas

  Nota({
    required this.id,
    required this.id_proyecto,
    required this.titulo,
    this.descripcion = '',
    DateTime? fecha_creacion,
    DateTime? fecha_modificacion,
    List<String>? ids_etiquetas,
  })  : fecha_creacion = fecha_creacion ?? DateTime.now(),
        fecha_modificacion = fecha_modificacion ?? DateTime.now(),
        ids_etiquetas = ids_etiquetas ?? [];
}