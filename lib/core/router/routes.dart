/// Chemins (paths) et noms de routes de l'application.
/// On remplit au fur et à mesure des étapes (auth, boutiques, demandes, etc.).
class AppRoutes {
  AppRoutes._();

  static const home = '/';

  // Auth
  static const welcome = '/welcome'; // onboarding (non connecté)
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp'; // 2FA SMS simulée
  static const success = '/success'; // succès + confettis (après 2FA)
  static const tutorial = '/tutorial'; // mini-tuto par rôle (après inscription)

  // Profil
  static const profile = '/profile';

  // Boutiques & produits (espace propriétaire)
  static const myShop = '/shop';
  static const shopForm = '/shop/form';
  static const shopProducts = '/shop/products';
  static const productForm = '/shop/products/form';

  // Demandes instantanées
  static const requests = '/requests';

  // Réservations
  static const reservations = '/reservations';

  // Carte
  static const map = '/map';

  // Dashboard commerçant
  static const dashboard = '/dashboard';
}
