import 'package:go_router/go_router.dart';
import 'screens/pantalla_buscar.dart';
import 'screens/pantalla_detalle_nota.dart';
import 'screens/pantalla_editor_nota.dart';
import 'screens/pantalla_etiquetas.dart';
import 'screens/pantalla_notas_proyecto.dart';
import 'screens/pantalla_principal.dart';
import 'screens/pantalla_proyectos.dart';

final GoRouter ruta = GoRouter(
  initialLocation: '/proyectos',
  routes: [
    // Las tres pestañas de la barra inferior
    StatefulShellRoute.indexedStack(
      builder: (context, state, contenedor) => PantallaPrincipal(contenedor: contenedor),
      branches: [
        // Pestaña 1: Proyectos
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/proyectos',
              builder: (context, state) => const PantallaProyectos(),
              routes: [
                GoRoute(
                  path: 'proyecto/:id_proyecto',
                  builder: (context, state) => PantallaNotasProyecto(
                    id_proyecto: state.pathParameters['id_proyecto']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Pestaña 2: Etiquetas
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/etiquetas',
              builder: (context, state) => const PantallaEtiquetas(),
              routes: [
                GoRoute(
                  path: 'etiqueta/:id_etiqueta',
                  builder: (context, state) => PantallaEtiquetas(
                    id_etiqueta: state.pathParameters['id_etiqueta'],
                  ),
                ),
              ],
            ),
          ],
        ),
        // Pestaña 3: Buscar
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/buscar',
              builder: (context, state) => const PantallaBuscar(),
            ),
          ],
        ),
      ],
    ),

    // Pantallas a las que se llega desde cualquier pestaña
    GoRoute(
      path: '/nota/:id_nota',
      builder: (context, state) => PantallaDetalleNota(
        id_nota: state.pathParameters['id_nota']!,
      ),
    ),
    GoRoute(
      path: '/nueva_nota/:id_proyecto',
      builder: (context, state) => PantallaEditorNota(
        id_proyecto: state.pathParameters['id_proyecto'],
      ),
    ),
    GoRoute(
      path: '/editar_nota/:id_nota',
      builder: (context, state) => PantallaEditorNota(
        id_nota: state.pathParameters['id_nota'],
      ),
    ),
  ],
);