import 'package:flutter/material.dart';

/// Palette de Dioula Market — reprend EXACTEMENT les couleurs des deux
/// templates de référence (Abu Anwar / The Flutter Way) :
///  - Foodly UI : vert + orange + neutres
///  - Rive Animated App : fonds navy clair/sombre + ombres
///
/// (Vert + orange = aussi les couleurs du drapeau ivoirien 🇨🇮)
class AppColors {
  AppColors._();

  // --- Foodly UI ---
  static const green = Color(0xFF22A45D); // primaryColor (marque)
  static const orange = Color(0xFFEF9920); // accentColor
  static const title = Color(0xFF010F07); // titleColor
  static const body = Color(0xFF868686); // bodyTextColor
  static const inputLight = Color(0xFFFBFBFB); // inputColor
  static const borderLight = Color(0xFFF3F2F2); // bordure champ

  // --- Rive Animated App ---
  static const bgLight = Color(0xFFF2F6FF); // backgroundColorLight
  static const bgDark = Color(0xFF17203A); // backgroundColor2 (navy profond)
  static const cardDark = Color(0xFF25254B); // backgroundColorDark
  static const shadowLight = Color(0xFF4A5367);
  static const shadowDark = Colors.black;

  // --- Neutres dérivés pour le thème sombre ---
  static const surfaceDark = Color(0xFF1E2746); // surface sombre (entre bg/card)
  static const inputDark = Color(0xFF222B49);
  static const borderDark = Color(0xFF2E3A5E);
  static const bodyDark = Color(0xFF9AA3BC); // texte secondaire sombre

  // --- Statuts (réutilisés dans toute l'app) ---
  static const success = green;
  static const warning = orange;
  static const danger = Color(0xFFE53935);

  // Dégradé d'accent (boutons CTA façon Rive/Foodly).
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2BB76A), green],
  );

  // Dégradé de fond pour l'onboarding/auth (façon Rive — navy profond).
  static const authGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF233056), bgDark],
  );
}
