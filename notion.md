# 📒 Dioula Market — Documentation projet

> Application mobile **Flutter** : marketplace de commerce local (Côte d'Ivoire)
> reliant **producteurs, commerçants, consommateurs et livreurs**.
> Projet de soutenance — priorité à une **démo fonctionnelle**, livrée vite.

Ce document est la **source de vérité vivante** du projet. Il est mis à jour à
**chaque étape**.

---

## 1. Stack technique

| Couche        | Choix                                              |
|---------------|----------------------------------------------------|
| UI            | Flutter (Dart 3.8) — Material 3                     |
| État          | Riverpod (`flutter_riverpod` ^3.x)                 |
| Navigation    | `go_router` ^17                                    |
| Backend       | **Supabase** (Postgres, Auth, Storage, Realtime)   |
| Auth          | Email + mot de passe + **2FA SMS simulée**         |
| Paiement      | **Simulé** (acompte de réservation)                |
| Carte / Géo   | Haversine SQL + (à venir) `flutter_map` (OSM)      |
| Env / secrets | `flutter_dotenv` (`.env` non commité)              |

### Rôles utilisateurs
`producteur` · `commercant` · `consommateur` · `livreur` · `admin`
(stockés dans `profiles.role`).

---

## 2. Architecture des dossiers (feature-first)

```
lib/
├─ main.dart                  # bootstrap : dotenv + Supabase.initialize + runApp
├─ app.dart                   # MaterialApp.router + thème
├─ core/
│  ├─ config/env.dart         # lecture des variables .env
│  ├─ constants/app_constants.dart   # enums (rôles, statuts) + constantes
│  ├─ providers/supabase_provider.dart  # client + état d'auth
│  ├─ router/                 # routes.dart (chemins) + app_router.dart (go_router)
│  └─ theme/app_theme.dart    # thème (orange/vert ivoirien)
└─ features/                  # 1 dossier par fonctionnalité
   ├─ auth/         (data / domain / presentation)
   ├─ profile/
   ├─ shops/        (boutiques)
   ├─ products/
   ├─ requests/     (demandes instantanées)
   ├─ offers/       (offres des commerçants)
   ├─ reservations/ (réservation + acompte)
   ├─ orders/       (commandes + livraison)
   ├─ map/          (géolocalisation)
   ├─ reviews/      (notation croisée)
   ├─ dashboard/    (tableau de bord commerçant)
   └─ home/         (accueil temporaire)
```
Chaque feature suit `data` (accès Supabase) / `domain` (modèles) /
`presentation` (écrans + widgets + providers UI).

---

## 3. Base de données Supabase

Fichiers SQL à exécuter dans **SQL Editor** (dans l'ordre) :
1. [`supabase/schema.sql`](supabase/schema.sql) — tables, fonctions, triggers
2. [`supabase/rls.sql`](supabase/rls.sql) — Row Level Security

### Tables
| Table          | Rôle |
|----------------|------|
| `profiles`     | Profil utilisateur (lié à `auth.users`), rôle, géoloc, note |
| `shops`        | Boutiques virtuelles (1 propriétaire) |
| `products`     | Produits d'une boutique + stock |
| `requests`     | Demandes instantanées (besoin d'un consommateur) |
| `offers`       | Offres des commerçants en réponse à une demande |
| `reservations` | Réservation d'un produit + acompte (simulé) |
| `orders` / `order_items` | Commandes et leurs lignes |
| `reviews`      | Avis 5 étoiles (notation croisée) |
| `payments`     | Trace des paiements **simulés** |

### Fonctions / triggers clés
- `handle_new_user()` → crée automatiquement un `profiles` à l'inscription.
- `set_updated_at()` → met à jour `updated_at` sur modification.
- `distance_km(...)` + `nearby_shops(lat,lng,radius)` → boutiques proches (Haversine),
  appelable via `supabase.rpc('nearby_shops', {...})`.

---

## 4. Configuration Supabase (à faire côté dashboard)

> ⚠️ La clé **`service_role` ne doit JAMAIS** être mise dans l'app ni commitée.

1. **Créer le projet** sur [supabase.com](https://supabase.com) → noter la région.
2. **Récupérer les clés** : *Project Settings → API*
   - `Project URL`  → `SUPABASE_URL`
   - clé `anon public` → `SUPABASE_ANON_KEY`
3. **Configurer `.env`** à la racine du projet Flutter :
   ```
   cp .env.example .env       # puis remplir les 2 valeurs
   ```
4. **Exécuter le SQL** : SQL Editor → coller `schema.sql`, exécuter →
   puis `rls.sql`.
5. **Auth** : *Authentication → Providers → Email* activé.
   (Pour la démo on peut désactiver "Confirm email" pour aller plus vite.)
6. **Storage** (plus tard) : créer les buckets `avatars`, `shop-logos`,
   `product-images` (public en lecture).

---

## 5. Lancer l'application

```bash
flutter pub get
flutter run            # choisir un device (Chrome / émulateur Android)
```
Tant que `.env` n'est pas rempli, l'app se lance quand même (mode démo) et
affiche « Supabase non configuré » sur l'écran d'accueil.

---

## 6. Avancement par étapes

| # | Étape | Statut |
|---|-------|--------|
| 1 | Setup projet + structure + schéma SQL | ✅ Fait |
| 2 | Auth (email + mdp + 2FA SMS simulée) + profils/rôle | ⏳ À venir |
| 3 | Boutiques + CRUD produits (stock) | ⏳ |
| 4 | Catalogue, recherche, fiche produit | ⏳ |
| 5 | Demande instantanée (Realtime) + offres | ⏳ |
| 6 | Réservation avec acompte (simulé) | ⏳ |
| 7 | Géolocalisation (carte, tri proximité) | ⏳ |
| 8 | Notation croisée 5 étoiles | ⏳ |
| 9 | Dashboard commerçant | ⏳ |

### Journal
- **Étape 1** — Projet `dioula_market` initialisé (Flutter 3.32 / Dart 3.8).
  Dépendances : riverpod, go_router, supabase_flutter, flutter_dotenv, intl,
  cached_network_image. Structure feature-first créée. Schéma SQL complet
  (10 tables + RLS + fonctions géo) fourni. `.env` ignoré par git.

---

## 7. Notes & décisions

- **Géoloc** : on commence simple (lat/lng + Haversine SQL). PostGIS reste
  possible plus tard (extension commentée dans `schema.sql`).
- **Paiement & SMS** : 100 % simulés pour la soutenance ; branchements réels
  (provider SMS, paiement mobile money) prévus après.
- **Git** : tous les commits/push sont faits manuellement (aucune commande git
  exécutée automatiquement).
