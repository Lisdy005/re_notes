import 'package:flutter/material.dart';
import 'ruta.dart';
import 'tema/tema_app.dart';

void main() {
  runApp(const AppReNotes());
}

class AppReNotes extends StatelessWidget {
  const AppReNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ReNotes',
      theme: tema_claro,
      darkTheme: tema_oscuro,
      themeMode: ThemeMode.system,
      routerConfig: ruta,
      debugShowCheckedModeBanner: false,
    );
  }
}