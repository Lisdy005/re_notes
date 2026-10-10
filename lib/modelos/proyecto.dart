class Proyecto {
  final String id;
  String nombre;
  String descripcion;
  final DateTime fecha_creacion;
  DateTime fecha_modificacion;

  Proyecto({
    required this.id,
    required this.nombre,
    this.descripcion = '',
    DateTime? fecha_creacion,
    DateTime? fecha_modificacion,
  })  : fecha_creacion = fecha_creacion ?? DateTime.now(),
        fecha_modificacion = fecha_modificacion ?? DateTime.now();
}