// Deja el texto en minúsculas, sin acentos y sin espacios
String normalizar(String texto) {
  var resultado = texto.trim().toLowerCase();

  const reemplazos = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
  };

  reemplazos.forEach((con_acento, sin_acento) {
    resultado = resultado.replaceAll(con_acento, sin_acento);
  });

  return resultado;
}

// Devuelve un resumen corto del texto en una sola línea
String extracto(String texto, {int maximo = 140}) {
  final limpio = texto.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (limpio.length <= maximo) return limpio;
  return '${limpio.substring(0, maximo).trimRight()}…';
}