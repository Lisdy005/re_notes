# ReNotes

Aplicación Android hecha con Flutter para organizar el trabajo de investigación

## Qué hace la app

ReNotes permite organizar la investigación en **proyectos**. Dentro de cada proyecto se escriben **notas**, que pueden ser largas, y se clasifican con **etiquetas** que el propio usuario crea y reutiliza en notas de cualquier proyecto

Con la app se puede:

- Crear, editar y eliminar proyectos, notas y etiquetas.
- Buscar notas por título o contenido, y filtrarlas por proyecto o por etiquetas.
- Escribir etiquetas con autocompletado: sugiere las que ya existen y ofrece crear una nueva si no existe
- Ver juntas las notas de todos los proyectos que comparten una o varias etiquetas

Los datos se guardan solo en memoria: al abrir la app se cargan datos de prueba y no se conservan al cerrarla

## Requisitos

- Flutter SDK instalado
- Android Studio con el SDK de Android
- Un emulador o un teléfono Android con depuración USB

Puedes comprobar que todo está listo con `flutter doctor`.

## Cómo inicializar y ejecutar el proyecto

1. Descarga el proyecto:

```
git clone https://github.com/Lisdy005/re_notes.git
cd renotes
```

2. Instala las dependencias:

```
flutter pub get
```

3. Abre un emulador o conecta el teléfono, y ejecuta la app:

```
flutter run
```

## Capturas

Las capturas de pantalla están en la carpeta `capturas/`.