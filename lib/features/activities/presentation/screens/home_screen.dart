import 'package:flutter/material.dart';
import 'package:tenk/features/onboarding/presentation/widgets/uphill_path_illustration.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.activityName});

  static const screenKey = Key('home_screen');

  final String activityName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: screenKey,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'TENK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const UphillPathIllustration(compact: false),
                  const SizedBox(height: 28),
                  Text(
                    'Твой путь',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activityName,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Мастерство растёт шаг за шагом.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
