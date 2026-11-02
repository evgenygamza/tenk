import 'package:flutter/material.dart';
import 'package:tenk/features/activities/presentation/screens/create_activity_screen.dart';
import 'package:tenk/features/onboarding/presentation/widgets/uphill_path_illustration.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const routeName = '/';
  static const startButtonKey = Key('welcome_start_button');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 650;
            final horizontalPadding = constraints.maxWidth < 360 ? 20.0 : 28.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                compact ? 16 : 24,
                horizontalPadding,
                20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (compact ? 36 : 44),
                ),
                child: IntrinsicHeight(
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
                      SizedBox(height: compact ? 12 : 24),
                      UphillPathIllustration(compact: compact),
                      SizedBox(height: compact ? 18 : 30),
                      Text(
                        'Время становится\nмастерством',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: compact ? 31 : 36,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Выбери занятие, уделяй ему время и наблюдай, '
                        'как растёт твой результат.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: compact ? 16 : 18,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      FilledButton(
                        key: startButtonKey,
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(CreateActivityScreen.routeName);
                        },
                        child: const Text('Начать'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
