/// Chemins (paths) et noms de routes de l'application.
/// On remplit au fur et à mesure des étapes (auth, boutiques, demandes, etc.).
class AppRoutes {
  AppRoutes._();

  static const home = '/';

  // Auth (étape 1 fonctionnelle — à venir)
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp'; // 2FA SMS simulée

  // Profil
  static const profile = '/profile';

  // Boutiques & produits
  static const shops = '/shops';
  static const products = '/products';

  // Demandes instantanées
  static const requests = '/requests';

  // Réservations
  static const reservations = '/reservations';

  // Carte
  static const map = '/map';

  // Dashboard commerçant
  static const dashboard = '/dashboard';
}
