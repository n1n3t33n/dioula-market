import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_controller.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/products/domain/product.dart';
import '../../features/products/presentation/product_form_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/shops/domain/shop.dart';
import '../../features/shops/presentation/my_shop_screen.dart';
import '../../features/shops/presentation/shop_form_screen.dart';
import '../config/env.dart';
import '../providers/supabase_provider.dart';
import 'routes.dart';

/// Écoute la session Supabase + l'attente 2FA pour rafraîchir le router.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    if (Env.isConfigured) {
      _ref.listen(authStateProvider, (_, __) => notifyListeners());
    }
    _ref.listen(otpPendingProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(GoRouterState state) {
    // Sans backend configuré, on laisse passer (mode démo sans auth).
    if (!Env.isConfigured) return null;

    final session = _ref.read(supabaseProvider).auth.currentSession;
    final otpPending = _ref.read(otpPendingProvider);
    final loc = state.matchedLocation;
    final onAuthPage = loc == AppRoutes.login || loc == AppRoutes.register;
    final onOtpPage = loc == AppRoutes.otp;

    // Non connecté : seules les pages login/register sont accessibles.
    if (session == null) {
      return onAuthPage ? null : AppRoutes.login;
    }
    // Connecté mais 2FA en attente : forcer l'écran OTP.
    if (otpPending) {
      return onOtpPage ? null : AppRoutes.otp;
    }
    // Connecté + vérifié : pas de raison de rester sur login/register/otp.
    if (onAuthPage || onOtpPage) return AppRoutes.home;
    return null;
  }
}

/// Configuration de navigation (go_router).
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    redirect: (context, state) => notifier.redirect(state),
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        builder: (context, state) => const OtpScreen(),
      ),

      // --- Espace boutique (propriétaire) ---
      GoRoute(
        path: AppRoutes.myShop,
        name: 'myShop',
        builder: (context, state) => const MyShopScreen(),
      ),
      GoRoute(
        path: AppRoutes.shopForm,
        name: 'shopForm',
        // extra = la boutique à éditer (null = création)
        builder: (context, state) =>
            ShopFormScreen(existing: state.extra as Shop?),
      ),
      GoRoute(
        path: AppRoutes.shopProducts,
        name: 'shopProducts',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: AppRoutes.productForm,
        name: 'productForm',
        // extra = (shopId, produit à éditer ?)
        builder: (context, state) {
          final args = state.extra as (String, Product?)?;
          if (args == null) {
            return const Scaffold(
              body: Center(child: Text('Aucun produit sélectionné')),
            );
          }
          return ProductFormScreen(shopId: args.$1, existing: args.$2);
        },
      ),
    ],
  );
});
