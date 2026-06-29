import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import 'auth_controller.dart';
import 'otp_controller.dart';

/// Écran de vérification 2FA (SMS **simulé**).
/// Le code est affiché à l'écran (zone jaune) pour la démo.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _code = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    // S'assure qu'un code existe (ex: arrivée directe sur l'écran).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(otpControllerProvider) == null) {
        ref.read(otpControllerProvider.notifier).generate();
      }
    });
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _verify() {
    final ok = ref.read(otpControllerProvider.notifier).verify(_code.text);
    if (ok) {
      ref.read(otpPendingProvider.notifier).set(false);
      ref.read(otpControllerProvider.notifier).clear();
      context.go(AppRoutes.home);
    } else {
      setState(() => _error = 'Code incorrect. Réessaie.');
    }
  }

  Future<void> _cancel() async {
    // Annuler la 2FA = se déconnecter et revenir au login.
    await ref.read(authControllerProvider.notifier).signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final code = ref.watch(otpControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification'),
        leading: IconButton(
            icon: const Icon(Icons.close), onPressed: _cancel),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.sms_outlined, size: 64, color: Color(0xFF1B9E4B)),
              const SizedBox(height: 16),
              Text('Code de vérification',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'Un code à 6 chiffres a été « envoyé » par SMS.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Démo : on affiche le code simulé.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Démo (SMS simulé) — code : ${code ?? "…"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  errorText: _error,
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _verify, child: const Text('Vérifier')),
              TextButton(
                onPressed: () =>
                    ref.read(otpControllerProvider.notifier).generate(),
                child: const Text('Renvoyer le code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
