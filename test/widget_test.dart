// Smoke test : l'app se construit et affiche l'accueil.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dioula_market/app.dart';

void main() {
  testWidgets('L\'accueil affiche le nom de l\'app', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DioulaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Dioula Market'), findsWidgets);
  });
}
