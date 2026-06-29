import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Charge les variables d'environnement (.env). Ne bloque pas la démo
  //    si le fichier est absent — on affiche juste un avertissement.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('⚠️  .env introuvable — copie .env.example vers .env.');
  }

  // 2) Initialise Supabase uniquement si les clés sont présentes.
  //    Permet de lancer l'app pour la démo avant d'avoir configuré le backend.
  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      // La clé "anon public" du dashboard Supabase. (Param déprécié en faveur
      // de publishableKey mais toujours fonctionnel et plus simple pour la démo.)
      // ignore: deprecated_member_use
      anonKey: Env.supabaseAnonKey,
    );
  } else {
    debugPrint(
      '⚠️  Supabase non configuré (SUPABASE_URL / SUPABASE_ANON_KEY manquants).',
    );
  }

  runApp(const ProviderScope(child: DioulaApp()));
}
