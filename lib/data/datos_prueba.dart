import 'package:flutter/material.dart';
import '../modelos/etiqueta.dart';
import '../modelos/nota.dart';
import '../modelos/proyecto.dart';

List<Etiqueta> crear_etiquetas_prueba() {
  return [
    Etiqueta(id: 'e1', nombre: 'Metodología', color: Colors.blue),
    Etiqueta(id: 'e2', nombre: 'Bibliografía', color: Colors.brown),
    Etiqueta(id: 'e3', nombre: 'Hipótesis', color: Colors.purple),
    Etiqueta(id: 'e4', nombre: 'Resultados', color: Colors.green),
    Etiqueta(id: 'e5', nombre: 'Entrevistas', color: Colors.orange),
    Etiqueta(id: 'e6', nombre: 'Pendiente', color: Colors.red),
    Etiqueta(id: 'e7', nombre: 'Ideas', color: Colors.teal),
    Etiqueta(id: 'e8', nombre: 'Revisión', color: Colors.grey), // sin notas
  ];
}

List<Proyecto> crear_proyectos_prueba() {
  return [
    Proyecto(
      id: 'p1',
      nombre: 'Redes sociales y rendimiento académico',
      descripcion:
      'Cómo influye el uso de redes sociales en el estudio de los universitarios.',
      fecha_creacion: DateTime(2026, 9, 1),
      fecha_modificacion: DateTime(2026, 10, 5),
    ),
    Proyecto(
      id: 'p2',
      nombre: 'Energía solar en viviendas',
      descripcion:
      'Posibilidad de usar paneles solares para el consumo de una casa.',
      fecha_creacion: DateTime(2026, 9, 3),
      fecha_modificacion: DateTime(2026, 10, 6),
    ),
    Proyecto(
      id: 'p3',
      nombre: 'Hábitos de lectura en jóvenes',
      descripcion: 'Qué leen los jóvenes, con qué frecuencia y en qué formatos.',
      fecha_creacion: DateTime(2026, 9, 8),
      fecha_modificacion: DateTime(2026, 10, 7),
    ),
  ];
}

List<Nota> crear_notas_prueba() {
  return [
    // ---------- Proyecto 1 ----------
    Nota(
      id: 'n1',
      id_proyecto: 'p1',
      titulo: 'Metodología general',
      descripcion:
      'Para esta investigación se propone un enfoque mixto. '
          'Primero se aplicará una encuesta a una muestra de estudiantes de distintas carreras '
          'para conocer cuántas horas al día dedican a las redes sociales y en qué momentos lo hacen. '
          'Después se realizarán entrevistas breves a un grupo reducido para entender mejor las razones detrás de esos hábitos. '
          'La encuesta tendrá preguntas cerradas sobre tiempo de uso, plataformas favoritas y percepción del rendimiento académico. '
          'Las entrevistas serán semiestructuradas y se grabarán con el permiso de cada participante. '
          'Los datos se organizarán en una tabla para compararlos entre grupos. '
          'Falta definir el tamaño exacto de la muestra y el calendario de aplicación, '
          'que dependerá de la disponibilidad de los grupos y de los horarios de clases.',
      fecha_creacion: DateTime(2026, 9, 2),
      fecha_modificacion: DateTime(2026, 10, 1),
      ids_etiquetas: ['e1', 'e6'],
    ),
    Nota(
      id: 'n2',
      id_proyecto: 'p1',
      titulo: 'Hipótesis principal',
      descripcion:
      'Los estudiantes que dedican más tiempo a las redes sociales tienen un rendimiento académico algo menor, aunque otros factores también influyen.',
      fecha_creacion: DateTime(2026, 9, 4),
      fecha_modificacion: DateTime(2026, 9, 20),
      ids_etiquetas: ['e3'],
    ),
    Nota(
      id: 'n3',
      id_proyecto: 'p1',
      titulo: 'Revisión de artículos',
      descripcion:
      'Resumen de los tres artículos revisados esta semana. '
          'El primero compara el rendimiento de estudiantes que usan redes sociales más de cuatro horas diarias '
          'con los que las usan menos de una hora, y encuentra una diferencia pequeña pero consistente. '
          'El segundo advierte que la relación podría ser inversa: quienes ya tienen dificultades académicas '
          'tal vez buscan más distracción en línea. '
          'El tercero se centra en la concentración y concluye que las notificaciones constantes interrumpen el estudio, '
          'aunque el efecto desaparece cuando el teléfono se deja en otra habitación. '
          'Conviene citar los tres con cuidado y no afirmar que las redes causan un peor rendimiento, '
          'porque ninguno de los estudios lo demuestra. '
          'Queda pendiente buscar un artículo con una muestra más cercana a nuestro contexto.',
      fecha_creacion: DateTime(2026, 9, 10),
      fecha_modificacion: DateTime(2026, 10, 3),
      ids_etiquetas: ['e2', 'e3'],
    ),
    Nota(
      id: 'n4',
      id_proyecto: 'p1',
      titulo: 'Ideas para el cuestionario',
      descripcion:
      'Preguntar por horas de uso, plataformas, momentos del día y si se usan durante el estudio. Evitar preguntas que den a entender una respuesta.',
      fecha_creacion: DateTime(2026, 9, 15),
      fecha_modificacion: DateTime(2026, 10, 4),
      ids_etiquetas: ['e7', 'e1'],
    ),
    Nota(
      id: 'n5',
      id_proyecto: 'p1',
      titulo: 'Contactos para entrevistas',
      descripcion:
      'Pedir a los delegados de grupo una lista de estudiantes dispuestos a ser entrevistados.',
      fecha_creacion: DateTime(2026, 9, 18),
      fecha_modificacion: DateTime(2026, 10, 5),
      ids_etiquetas: [], // nota sin etiquetas
    ),

    // ---------- Proyecto 2 ----------
    Nota(
      id: 'n6',
      id_proyecto: 'p2',
      titulo: 'Consumo de una vivienda',
      descripcion:
      'Cálculo preliminar del consumo de una vivienda promedio. '
          'Se tomó como referencia una familia de cuatro personas con nevera, televisor, ventilador, iluminación '
          'y un par de cargadores de teléfono funcionando varias horas al día. '
          'Sumando la potencia de cada equipo y las horas de uso estimadas se obtuvo un consumo diario aproximado '
          'que servirá para dimensionar un sistema de paneles solares. '
          'Hay que tener en cuenta que la nevera trabaja de forma intermitente, '
          'por lo que no se debe multiplicar su potencia por las veinticuatro horas completas. '
          'También conviene dejar un margen de seguridad para días nublados. '
          'El siguiente paso es comparar este resultado con las facturas reales de varias viviendas '
          'para comprobar si la estimación se acerca a la realidad.',
      fecha_creacion: DateTime(2026, 9, 5),
      fecha_modificacion: DateTime(2026, 9, 28),
      ids_etiquetas: ['e1'],
    ),
    Nota(
      id: 'n7',
      id_proyecto: 'p2',
      titulo: 'Fuentes sobre paneles solares',
      descripcion:
      'Buscar manuales y artículos sobre dimensionamiento de sistemas fotovoltaicos pequeños y su costo aproximado.',
      fecha_creacion: DateTime(2026, 9, 7),
      fecha_modificacion: DateTime(2026, 9, 30),
      ids_etiquetas: ['e2'],
    ),
    Nota(
      id: 'n8',
      id_proyecto: 'p2',
      titulo: 'Entrevista a un técnico',
      descripcion:
      'Conversación con un técnico eléctrico sobre los problemas más comunes al instalar paneles en viviendas.',
      fecha_creacion: DateTime(2026, 9, 12),
      fecha_modificacion: DateTime(2026, 10, 2),
      ids_etiquetas: ['e5'],
    ),
    Nota(
      id: 'n9',
      id_proyecto: 'p2',
      titulo: 'Resultados de la encuesta piloto',
      descripcion:
      'La encuesta piloto se aplicó a veinte personas para probar si las preguntas se entendían bien. '
          'La mayoría respondió sin dificultad, pero dos preguntas sobre potencia instalada resultaron confusas '
          'y habrá que reformularlas con ejemplos más sencillos. '
          'Se observó que casi todas las personas conocen los paneles solares, aunque pocas saben cuánto cuesta instalarlos. '
          'Un grupo más pequeño mostró interés en probar un calentador solar de agua si el costo fuera accesible. '
          'También apareció una duda frecuente sobre el mantenimiento: muchos creen que los paneles requieren cuidados complejos. '
          'Estos resultados son solo orientativos por el tamaño de la muestra, '
          'pero sirven para mejorar el cuestionario definitivo antes de aplicarlo a más personas.',
      fecha_creacion: DateTime(2026, 9, 20),
      fecha_modificacion: DateTime(2026, 10, 6),
      ids_etiquetas: ['e4'],
    ),
    Nota(
      id: 'n10',
      id_proyecto: 'p2',
      titulo: 'Lista de materiales',
      descripcion:
      'Panel, regulador, batería, inversor y cableado. Falta consultar precios actuales.',
      fecha_creacion: DateTime(2026, 9, 25),
      fecha_modificacion: DateTime(2026, 10, 1),
      ids_etiquetas: ['e6'],
    ),

    // ---------- Proyecto 3 ----------
    Nota(
      id: 'n11',
      id_proyecto: 'p3',
      titulo: 'Objetivo de la investigación',
      descripcion:
      'Conocer qué leen los jóvenes, con qué frecuencia y en qué formatos.',
      fecha_creacion: DateTime(2026, 9, 9),
      fecha_modificacion: DateTime(2026, 9, 22),
      ids_etiquetas: ['e3'],
    ),
    Nota(
      id: 'n12',
      id_proyecto: 'p3',
      titulo: 'Marco teórico',
      descripcion:
      'Idea central del marco teórico: la lectura por placer y la lectura académica no son lo mismo, '
          'y conviene tratarlas por separado en la investigación. '
          'La primera se elige libremente y suele relacionarse con el descanso, '
          'mientras que la segunda responde a una obligación y exige mayor concentración. '
          'Varios autores señalan que los jóvenes leen más de lo que ellos mismos creen, '
          'porque cuentan como lectura solo los libros y dejan fuera los mensajes, los artículos en línea y los cómics. '
          'Por eso el cuestionario debe preguntar por distintos formatos y no únicamente por libros. '
          'También será importante definir desde el inicio qué se considera una persona lectora, '
          'para que los resultados sean comparables entre los distintos grupos encuestados.',
      fecha_creacion: DateTime(2026, 9, 14),
      fecha_modificacion: DateTime(2026, 10, 2),
      ids_etiquetas: ['e2', 'e7'],
    ),
    Nota(
      id: 'n13',
      id_proyecto: 'p3',
      titulo: 'Diseño de la encuesta',
      descripcion:
      'Incluir preguntas sobre libros, artículos, mensajes y cómics. Aplicar la encuesta en dos facultades distintas.',
      fecha_creacion: DateTime(2026, 9, 21),
      fecha_modificacion: DateTime(2026, 10, 4),
      ids_etiquetas: ['e1'],
    ),
    Nota(
      id: 'n14',
      id_proyecto: 'p3',
      titulo: 'Observaciones en la biblioteca',
      descripcion:
      'Anotar cuántas personas entran a la biblioteca y qué hacen. Repetir la observación en semana de exámenes.',
      fecha_creacion: DateTime(2026, 9, 27),
      fecha_modificacion: DateTime(2026, 10, 6),
      ids_etiquetas: ['e6', 'e4'],
    ),
    Nota(
      id: 'n15',
      id_proyecto: 'p3',
      titulo: 'Resultados preliminares',
      descripcion:
      'Primeras respuestas: la mayoría lee a diario, pero pocos lo hacen en formato de libro.',
      fecha_creacion: DateTime(2026, 10, 1),
      fecha_modificacion: DateTime(2026, 10, 7),
      ids_etiquetas: ['e4'],
    ),
  ];
}