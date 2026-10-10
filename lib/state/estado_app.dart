import 'package:flutter/foundation.dart';
import '../data/datos_prueba.dart';
import '../modelos/etiqueta.dart';
import '../modelos/nota.dart';
import '../modelos/proyecto.dart';
import '../utilidades/texto.dart';

class EstadoApp extends ChangeNotifier {
  // Al iniciar, las listas se llenan con los datos de prueba
  final List<Proyecto> _proyectos = crear_proyectos_prueba();
  final List<Nota> _notas = crear_notas_prueba();
  final List<Etiqueta> _etiquetas = crear_etiquetas_prueba();

  int _contador_id = 1000;

  // Las pantallas leen las listas, pero no pueden modificarlas directamente
  List<Proyecto> get proyectos => List.unmodifiable(_proyectos);
  List<Nota> get notas => List.unmodifiable(_notas);
  List<Etiqueta> get etiquetas => List.unmodifiable(_etiquetas);

  // Crea un id único 
  String _generar_id(String prefijo) {
    _contador_id++;
    return '$prefijo$_contador_id';
  }

  // ---------- Buscar por id ----------

  Proyecto? proyecto_por_id(String id) {
    for (final proyecto in _proyectos) {
      if (proyecto.id == id) return proyecto;
    }
    return null;
  }

  Nota? nota_por_id(String id) {
    for (final nota in _notas) {
      if (nota.id == id) return nota;
    }
    return null;
  }

  Etiqueta? etiqueta_por_id(String id) {
    for (final etiqueta in _etiquetas) {
      if (etiqueta.id == id) return etiqueta;
    }
    return null;
  }

  // ---------- Proyectos ----------

  void crear_proyecto(String nombre, String descripcion) {
    _proyectos.add(Proyecto(
      id: _generar_id('p'),
      nombre: nombre.trim(),
      descripcion: descripcion.trim(),
    ));
    notifyListeners();
  }

  void editar_proyecto(String id, String nombre, String descripcion) {
    final proyecto = proyecto_por_id(id);
    if (proyecto == null) return;
    proyecto.nombre = nombre.trim();
    proyecto.descripcion = descripcion.trim();
    proyecto.fecha_modificacion = DateTime.now();
    notifyListeners();
  }

  // Al eliminar un proyecto se eliminan sus notas. Las etiquetas no se tocan
  void eliminar_proyecto(String id) {
    _proyectos.removeWhere((proyecto) => proyecto.id == id);
    _notas.removeWhere((nota) => nota.id_proyecto == id);
    notifyListeners();
  }

  List<Nota> notas_de_proyecto(String id_proyecto) {
    return _notas.where((nota) => nota.id_proyecto == id_proyecto).toList();
  }

  int cantidad_notas_de_proyecto(String id_proyecto) {
    return notas_de_proyecto(id_proyecto).length;
  }

  // Solo las etiquetas que aparecen en las notas de ese proyecto
  // (es para el filtro de la pantalla Notas del proyecto)
  List<Etiqueta> etiquetas_de_proyecto(String id_proyecto) {
    final ids = <String>{};
    for (final nota in notas_de_proyecto(id_proyecto)) {
      ids.addAll(nota.ids_etiquetas);
    }
    return _etiquetas.where((etiqueta) => ids.contains(etiqueta.id)).toList();
  }

  void _marcar_proyecto_modificado(String id_proyecto) {
    final proyecto = proyecto_por_id(id_proyecto);
    if (proyecto != null) proyecto.fecha_modificacion = DateTime.now();
  }

  // ---------- Notas ----------

  Nota crear_nota({
    required String id_proyecto,
    required String titulo,
    required String descripcion,
    required List<String> ids_etiquetas,
  }) {
    final nota = Nota(
      id: _generar_id('n'),
      id_proyecto: id_proyecto,
      titulo: titulo.trim(),
      descripcion: descripcion, // sin recortar, para no perder contenido
      ids_etiquetas: List.of(ids_etiquetas),
    );
    _notas.add(nota);
    _marcar_proyecto_modificado(id_proyecto);
    notifyListeners();
    return nota;
  }

  void actualizar_nota(
      String id, {
        required String titulo,
        required String descripcion,
        required List<String> ids_etiquetas,
      }) {
    final nota = nota_por_id(id);
    if (nota == null) return;
    nota.titulo = titulo.trim();
    nota.descripcion = descripcion;
    nota.ids_etiquetas = List.of(ids_etiquetas);
    nota.fecha_modificacion = DateTime.now();
    _marcar_proyecto_modificado(nota.id_proyecto);
    notifyListeners();
  }

  void eliminar_nota(String id) {
    final nota = nota_por_id(id);
    if (nota == null) return;
    _notas.remove(nota);
    _marcar_proyecto_modificado(nota.id_proyecto);
    notifyListeners();
  }

  // ---------- Etiquetas ----------

  // Busca una etiqueta por nombre ignorando mayúsculas, acentos y espacios
  Etiqueta? etiqueta_por_nombre(String nombre) {
    final buscado = normalizar(nombre);
    for (final etiqueta in _etiquetas) {
      if (normalizar(etiqueta.nombre) == buscado) return etiqueta;
    }
    return null;
  }

  // Si ya existe una etiqueta con ese nombre la devuelve (no se duplica), si no existe la crea
  Etiqueta crear_etiqueta(String nombre) {
    final existente = etiqueta_por_nombre(nombre);
    if (existente != null) return existente;
    final etiqueta = Etiqueta(id: _generar_id('e'), nombre: nombre.trim());
    _etiquetas.add(etiqueta);
    notifyListeners();
    return etiqueta;
  }

  // Devuelve null si todo salió bien, o un mensaje de error si no se pudo
  String? renombrar_etiqueta(String id, String nuevo_nombre) {
    final etiqueta = etiqueta_por_id(id);
    if (etiqueta == null) return 'La etiqueta no existe';
    if (nuevo_nombre.trim().isEmpty) return 'El nombre no puede estar vacío';
    final otra = etiqueta_por_nombre(nuevo_nombre);
    if (otra != null && otra.id != id) {
      return 'Ya existe una etiqueta con ese nombre';
    }
    etiqueta.nombre = nuevo_nombre.trim();
    notifyListeners();
    return null;
  }

  // Se quita la etiqueta de todas las notas, pero las notas no se borran
  void eliminar_etiqueta(String id) {
    _etiquetas.removeWhere((etiqueta) => etiqueta.id == id);
    for (final nota in _notas) {
      nota.ids_etiquetas.remove(id);
    }
    notifyListeners();
  }

  List<Nota> notas_con_etiqueta(String id_etiqueta) {
    return _notas
        .where((nota) => nota.ids_etiquetas.contains(id_etiqueta))
        .toList();
  }

  int cantidad_notas_de_etiqueta(String id_etiqueta) {
    return notas_con_etiqueta(id_etiqueta).length;
  }

  // ---------- Búsqueda y filtros ----------

  // La usarán Notas del proyecto, Etiquetas y Buscar.
  // Todos los datos son opcionales: lo que no se indique, no filtra
  List<Nota> filtrar_notas({
    String texto = '',
    String? id_proyecto,
    Set<String> ids_etiquetas = const {},
    bool todas = false, // al menos una etiqueta
  }) {
    final consulta = normalizar(texto);

    final resultado = _notas.where((nota) {
      if (id_proyecto != null && nota.id_proyecto != id_proyecto) {
        return false;
      }
      if (consulta.isNotEmpty) {
        final en_titulo = normalizar(nota.titulo).contains(consulta);
        final en_descripcion = normalizar(nota.descripcion).contains(consulta);
        if (!en_titulo && !en_descripcion) return false;
      }
      if (ids_etiquetas.isNotEmpty) {
        final cumple = todas
            ? ids_etiquetas.every((id) => nota.ids_etiquetas.contains(id))
            : ids_etiquetas.any((id) => nota.ids_etiquetas.contains(id));
        if (!cumple) return false;
      }
      return true;
    }).toList();

    // Las más recientes primero
    resultado.sort(
          (a, b) => b.fecha_modificacion.compareTo(a.fecha_modificacion),
    );
    return resultado;
  }
}

// Una sola instancia para toda la app. Todas las pantallas usan esta
final estado = EstadoApp();