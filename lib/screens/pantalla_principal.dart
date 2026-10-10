import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PantallaPrincipal extends StatelessWidget {
  final StatefulNavigationShell contenedor;

  const PantallaPrincipal({super.key, required this.contenedor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: contenedor,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: contenedor.currentIndex,
        onTap: (indice) => contenedor.goBranch(
          indice,
          // Si se toca la pestaña actual, vuelve a su pantalla inicial.
          initialLocation: indice == contenedor.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Proyectos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.label_outline),
            activeIcon: Icon(Icons.label),
            label: 'Etiquetas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
        ],
      ),
    );
  }
}