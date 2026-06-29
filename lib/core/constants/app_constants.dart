// Constantes et énumérations partagées de Dioula Market.
//
// Les valeurs `value` correspondent EXACTEMENT aux chaînes stockées en base
// (colonnes `text` avec CHECK). Garder ces deux côtés synchronisés.

class AppInfo {
  AppInfo._();
  static const appName = 'Dioula Market';
  static const tagline = 'Le marché local, en temps réel.';
}

/// Rôles utilisateur (stockés sur la table `profiles`).
enum UserRole {
  producteur('producteur', 'Producteur'),
  commercant('commercant', 'Commerçant'),
  consommateur('consommateur', 'Consommateur'),
  livreur('livreur', 'Livreur'),
  admin('admin', 'Admin');

  const UserRole(this.value, this.label);
  final String value;
  final String label;

  static UserRole fromValue(String? v) =>
      UserRole.values.firstWhere((r) => r.value == v,
          orElse: () => UserRole.consommateur);
}

/// Statut d'une demande instantanée (`requests`).
enum RequestStatus {
  ouverte('ouverte', 'Ouverte'),
  pourvue('pourvue', 'Pourvue'),
  expiree('expiree', 'Expirée'),
  annulee('annulee', 'Annulée');

  const RequestStatus(this.value, this.label);
  final String value;
  final String label;
}

/// Statut d'une offre faite par un commerçant (`offers`).
enum OfferStatus {
  proposee('proposee', 'Proposée'),
  acceptee('acceptee', 'Acceptée'),
  refusee('refusee', 'Refusée');

  const OfferStatus(this.value, this.label);
  final String value;
  final String label;
}

/// Statut d'une réservation avec acompte (`reservations`).
enum ReservationStatus {
  enAttente('en_attente', 'En attente'),
  payee('payee', 'Acompte payé'),
  confirmee('confirmee', 'Confirmée'),
  terminee('terminee', 'Terminée'),
  annulee('annulee', 'Annulée'),
  expiree('expiree', 'Expirée');

  const ReservationStatus(this.value, this.label);
  final String value;
  final String label;
}

/// Statut d'une commande (`orders`).
enum OrderStatus {
  enCours('en_cours', 'En cours'),
  preparee('preparee', 'Préparée'),
  enLivraison('en_livraison', 'En livraison'),
  livree('livree', 'Livrée'),
  annulee('annulee', 'Annulée');

  const OrderStatus(this.value, this.label);
  final String value;
  final String label;
}

/// Pourcentage d'acompte par défaut pour une réservation (simulé).
const double kDefaultDepositRate = 0.30;

/// Part de l'acompte remboursée si la réservation expire (simulé).
const double kRefundRateOnExpiry = 0.50;
