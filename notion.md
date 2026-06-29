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
| 2 | Auth (email + mdp + 2FA SMS simulée) + profils/rôle | ✅ Fait |
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
- **Étape 2** — Authentification fonctionnelle :
  - `features/auth` : `AuthRepository` (Supabase), `AuthController` (Riverpod
    `AsyncNotifier`), écrans `login` / `register` (avec choix du rôle) / `otp`.
  - **2FA SMS simulée** : génération d'un code 6 chiffres affiché à l'écran +
    log (`OtpController`), vérifié localement.
  - `features/profile` : modèle `Profile` + `ProfileRepository` +
    `currentProfileProvider` (profil + rôle de l'utilisateur connecté).
  - Le rôle choisi à l'inscription est créé en base par le trigger SQL
    `handle_new_user` (via les métadonnées d'auth).
  - Router : redirection automatique selon session + état 2FA
    (non connecté → login ; connecté + 2FA en attente → otp ; sinon → home).
  - Accueil authentifié : nom, rôle, bouton de déconnexion.

---

## 7. Notes & décisions

- **Géoloc** : on commence simple (lat/lng + Haversine SQL). PostGIS reste
  possible plus tard (extension commentée dans `schema.sql`).
- **Paiement & SMS** : 100 % simulés pour la soutenance ; branchements réels
  (provider SMS, paiement mobile money) prévus après.
- **Git** : tous les commits/push sont faits manuellement (aucune commande git
  exécutée automatiquement).

---

## 8. 📖 Glossaire (termes techniques + exemples)

> Mis à jour à chaque nouveauté. Chaque terme est suivi d'un **exemple concret**
> tiré de Dioula Market.

### A. Flutter & Dart
- **Flutter** — Framework de Google pour créer des apps (Android, iOS, web) avec
  un seul code. *Ex. : toute l'app Dioula Market est écrite en Flutter.*
- **Dart** — Langage de programmation utilisé par Flutter.
  *Ex. : `final code = generate();` dans `OtpController` est du Dart.*
- **SDK** (*Software Development Kit*) — Ensemble d'outils pour développer.
  *Ex. : le « Flutter SDK 3.32 » contient le compilateur, les libs, l'émulateur.*
- **Widget** — Brique d'interface (bouton, texte, écran…). Tout est widget.
  *Ex. : `FilledButton(child: Text('Se connecter'))` est un widget bouton.*
- **StatelessWidget / StatefulWidget** — Widget sans état / avec état interne
  qui peut changer. *Ex. : `LoginScreen` est `StatefulWidget` car le champ
  mot de passe peut être masqué/affiché (`_obscure`).*
- **State (état)** — Données qui peuvent changer et redessinent l'écran.
  *Ex. : `_loading = true` affiche un spinner pendant la connexion.*
- **Hot reload** — Recharger le code instantanément sans tout relancer.
  *Ex. : on change une couleur du thème, l'app se met à jour en < 1 s.*
- **Package / dépendance** — Bibliothèque externe ajoutée au projet.
  *Ex. : `supabase_flutter` est un package listé dans `pubspec.yaml`.*
- **pubspec.yaml** — Fichier qui liste les dépendances et assets du projet.
  *Ex. : on y a déclaré `.env` comme asset et la dépendance `go_router`.*

### B. Architecture & gestion d'état
- **Architecture feature-first** — Organiser le code par fonctionnalité plutôt
  que par type. *Ex. : tout l'auth est dans `lib/features/auth/`.*
- **Riverpod** — Bibliothèque de gestion d'état (partager des données entre
  écrans). *Ex. : `currentProfileProvider` donne le profil partout dans l'app.*
- **Provider** — Objet Riverpod qui fournit une valeur.
  *Ex. : `authRepositoryProvider` fournit l'accès à l'auth Supabase.*
- **Notifier / AsyncNotifier** — Classe Riverpod qui contient une logique et un
  état modifiable (async = avec chargement/erreur).
  *Ex. : `AuthController extends AsyncNotifier` gère le login (loading→succès/erreur).*
- **ref.watch / ref.read** — Lire un provider en s'abonnant (watch) ou une seule
  fois (read). *Ex. : `ref.watch(currentProfileProvider)` redessine le home quand
  le profil change.*
- **ProviderScope** — Widget racine qui active Riverpod.
  *Ex. : `runApp(ProviderScope(child: DioulaApp()))` dans `main.dart`.*
- **go_router** — Bibliothèque de navigation par URL.
  *Ex. : `context.go('/otp')` envoie l'utilisateur vers l'écran 2FA.*
- **Route** — Une « page » identifiée par un chemin.
  *Ex. : `/login`, `/register`, `/otp`, `/` (home).*
- **Redirection (redirect)** — Renvoyer automatiquement vers une autre route
  selon une condition. *Ex. : non connecté → redirigé vers `/login`.*

### C. Backend & base de données
- **Backend / Frontend** — Le serveur (données, logique) / l'app visible par
  l'utilisateur. *Ex. : Frontend = Flutter ; Backend = Supabase.*
- **Supabase** — Plateforme backend clé en main (base de données + auth +
  stockage + temps réel). *Ex. : nos tables et l'auth vivent dans Supabase.*
- **PostgreSQL** — Le moteur de base de données relationnelle utilisé par Supabase.
  *Ex. : `supabase/schema.sql` est du code PostgreSQL.*
- **Table** — Tableau de données (lignes/colonnes). *Ex. : la table `products`.*
- **Colonne** — Un champ d'une table. *Ex. : `products.price` (le prix).*
- **Clé primaire (primary key)** — Identifiant unique d'une ligne.
  *Ex. : `products.id` (un UUID unique par produit).*
- **Clé étrangère (foreign key)** — Colonne qui pointe vers une autre table.
  *Ex. : `products.shop_id` → `shops.id` (le produit appartient à une boutique).*
- **UUID** — Identifiant unique universel (long code aléatoire).
  *Ex. : `gen_random_uuid()` → `a1b2c3d4-…` pour l'id d'une boutique.*
- **Index** — Structure qui accélère les recherches.
  *Ex. : `idx_products_shop` accélère « tous les produits d'une boutique ».*
- **Trigger** — Code SQL exécuté automatiquement lors d'un événement.
  *Ex. : `handle_new_user` crée un profil dès qu'un compte est créé.*
- **Fonction SQL / RPC** — Procédure stockée appelable depuis l'app.
  *Ex. : `nearby_shops(lat,lng,10)` renvoie les boutiques à moins de 10 km.*
- **API** (*Application Programming Interface*) — Porte d'entrée pour parler au
  backend. *Ex. : Flutter appelle l'API Supabase pour lire `products`.*
- **CRUD** — Create / Read / Update / Delete (créer, lire, modifier, supprimer).
  *Ex. : un commerçant fait le CRUD de ses produits (étape 3).*
- **Realtime (temps réel)** — Recevoir les changements de la base en direct.
  *Ex. : un commerçant verra une nouvelle demande apparaître sans rafraîchir
  (étape 5).*
- **Storage / bucket** — Stockage de fichiers (images).
  *Ex. : bucket `product-images` pour les photos de produits.*

### D. Sécurité & authentification
- **Authentification (Auth)** — Vérifier l'identité d'un utilisateur.
  *Ex. : email + mot de passe via Supabase Auth.*
- **Session** — État « connecté » d'un utilisateur, avec un jeton.
  *Ex. : après login, `currentSession` n'est pas `null`.*
- **Token / JWT** (*JSON Web Token*) — Jeton signé prouvant l'identité.
  *Ex. : la clé `anon` est un JWT ; la session en contient un aussi.*
- **Clé anon (anon key)** — Clé publique côté app, protégée par les RLS.
  *Ex. : `SUPABASE_ANON_KEY` dans `.env`, sans danger côté client.*
- **Clé service_role** — Clé secrète qui contourne toutes les sécurités.
  *Ex. : interdite dans l'app ; usage serveur uniquement.*
- **RLS (Row Level Security)** — Règles qui filtrent les lignes accessibles par
  utilisateur. *Ex. : un acheteur ne voit que SES réservations.*
- **Policy (politique RLS)** — Une règle RLS précise.
  *Ex. : `reviews_insert_author` : on ne peut créer un avis qu'en son nom.*
- **2FA (authentification à deux facteurs) / OTP (code à usage unique)** —
  2ᵉ preuve d'identité via un code temporaire.
  *Ex. : code à 6 chiffres « envoyé par SMS » (ici **simulé**, affiché à l'écran).*
- **Variable d'environnement / .env** — Réglage secret hors du code.
  *Ex. : `SUPABASE_URL` et `SUPABASE_ANON_KEY` dans `.env` (non commité).*

### E. Géolocalisation
- **Latitude / Longitude** — Coordonnées GPS d'un point.
  *Ex. : `shops.latitude` / `shops.longitude` situent une boutique.*
- **Haversine** — Formule de distance entre 2 points GPS.
  *Ex. : `distance_km(lat1,lng1,lat2,lng2)` calcule la distance en km.*
- **Rayon (radius)** — Distance maximale de recherche.
  *Ex. : une demande « oignons, rayon 10 km » cherche les boutiques ≤ 10 km.*

### F. Spécifique au projet
- **Demande instantanée** — Un consommateur publie un besoin, les commerçants
  répondent. *Ex. : « 20 kg d'oignons, rayon 10 km » → table `requests`.*
- **Offre** — Réponse d'un commerçant à une demande (prix/quantité/délai).
  *Ex. : « 18 kg dispo à 8 000 FCFA, livré demain » → table `offers`.*
- **Acompte (simulé)** — Avance payée pour réserver un produit.
  *Ex. : 30 % du total réservé via un faux écran de paiement (étape 6).*
- **Stock** — Quantité disponible d'un produit.
  *Ex. : `products.stock = 50` (50 kg d'oignons en stock).*
- **Enum (énumération)** — Liste figée de valeurs possibles.
  *Ex. : `UserRole` = producteur / commercant / consommateur / livreur / admin.*
