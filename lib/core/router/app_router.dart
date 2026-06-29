import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import 'routes.dart';

/// Configuration de navigation (go_router).
///
/// Pour l'étape 1, une seule route (accueil). On ajoutera les routes
/// d'auth, boutiques, demandes, etc. au fil des étapes, ainsi que la
/// redirection basée sur la session (`authStateProvider`).
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
