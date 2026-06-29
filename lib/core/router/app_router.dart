import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/guest_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_controller.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/success_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/home/presentation/main_shell.dart';
import '../../features/tutorial/presentation/tutorial_screen.dart';
import '../../features/products/domain/product.dart';
import '../../features/products/presentation/product_form_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/shops/domain/shop.dart';
import '../../features/shops/presentation/my_shop_screen.dart';
import '../../features/shops/presentation/shop_form_screen.dart';
import '../config/env.dart';
import '../constants/app_constants.dart';
import '../providers/supabase_provider.dart';
import 'routes.dart';

/// Écoute la session Supabase + l'attente 2FA pour rafraîchir le router.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    if (Env.isConfigured) {
      _ref.listen(authStateProvider, (_, __) => notifyListeners());
    }
    _ref.listen(otpPendingProvider, (_, __) => notifyListeners());
    _ref.listen(guestModeProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(GoRouterState state) {
    // Sans backend configuré, on laisse passer (mode démo sans auth).
    if (!Env.isConfigured) return null;

    final session = _ref.read(supabaseProvider).auth.currentSession;
    final otpPending = _ref.read(otpPendingProvider);
    final guest = _ref.read(guestModeProvider);
    final loc = state.matchedLocation;
    final onAuthPage = loc == AppRoutes.login || loc == AppRoutes.register;
    final onOtpPage = loc == AppRoutes.otp;
    final onWelcome = loc == AppRoutes.welcome;

    // Non connecté :
    if (session == null) {
      // Mode visiteur : accès libre à l'app (les actions réservées sont
      // verrouillées dans les écrans eux-mêmes).
      if (guest) return null;
      // Sinon : seuls welcome / login / register sont accessibles.
      return (onWelcome || onAuthPage) ? null : AppRoutes.welcome;
    }
    // Connecté mais 2FA en attente : forcer l'écran OTP.
    if (otpPending) {
      return onOtpPage ? null : AppRoutes.otp;
    }
    // Connecté + vérifié : pas de raison de rester sur welcome/login/register/otp.
    if (onWelcome || onAuthPage || onOtpPage) return AppRoutes.home;
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
        pageBuilder: (context, state) => _fade(state, const MainShell()),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        pageBuilder: (context, state) => _fade(state, const WelcomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _fade(state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => _fade(state, const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        pageBuilder: (context, state) => _fade(state, const OtpScreen()),
      ),
      GoRoute(
        path: AppRoutes.success,
        name: 'success',
        pageBuilder: (context, state) => _fade(state, const SuccessScreen()),
      ),
      GoRoute(
        path: AppRoutes.tutorial,
        name: 'tutorial',
        // extra = UserRole optionnel (ex: depuis « Revoir le tuto »)
        pageBuilder: (context, state) =>
            _fade(state, TutorialScreen(role: state.extra as UserRole?)),
      ),

      // --- Espace boutique (propriétaire) ---
      GoRoute(
        path: AppRoutes.myShop,
        name: 'myShop',
        pageBuilder: (context, state) => _fade(state, const MyShopScreen()),
      ),
      GoRoute(
        path: AppRoutes.shopForm,
        name: 'shopForm',
        // extra = la boutique à éditer (null = création)
        pageBuilder: (context, state) =>
            _fade(state, ShopFormScreen(existing: state.extra as Shop?)),
      ),
      GoRoute(
        path: AppRoutes.shopProducts,
        name: 'shopProducts',
        pageBuilder: (context, state) => _fade(state, const ProductsScreen()),
      ),
      GoRoute(
        path: AppRoutes.productForm,
        name: 'productForm',
        // extra = (shopId, produit à éditer ?)
        pageBuilder: (context, state) {
          final args = state.extra as (String, Product?)?;
          if (args == null) {
            return _fade(
              state,
              const Scaffold(
                body: Center(child: Text('Aucun produit sélectionné')),
              ),
            );
          }
          return _fade(
            state,
            ProductFormScreen(shopId: args.$1, existing: args.$2),
          );
        },
      ),
    ],
  );
});

/// Page avec **transition fluide** (fondu + léger glissement vers le haut),
/// appliquée à toutes les routes de l'app.
CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
