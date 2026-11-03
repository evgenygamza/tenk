import 'package:flutter/material.dart';
import 'package:tenk/screens/home/widgets/uphill_path_illustration.dart';
import 'package:tenk/screens/practice/practice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.activityName,
    this.showTutorial = false,
  });

  static const screenKey = Key('home_screen');
  static const tutorialKey = Key('home_tutorial');
  static const dismissTutorialKey = Key('home_dismiss_tutorial');
  static const startPracticeKey = Key('home_start_practice');

  final String activityName;
  final bool showTutorial;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _showTutorial;

  @override
  void initState() {
    super.initState();
    _showTutorial = widget.showTutorial;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: HomeScreen.screenKey,
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
                    widget.activityName,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Мастерство растёт шаг за шагом.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge,
                  ),
                  if (_showTutorial) ...[
                    const SizedBox(height: 28),
                    Container(
                      key: HomeScreen.tutorialKey,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Первый шаг', style: textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(
                            'Запусти первое занятие, чтобы начать свой путь.',
                            style: textTheme.bodyLarge?.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            key: HomeScreen.dismissTutorialKey,
                            onPressed: () =>
                                setState(() => _showTutorial = false),
                            child: const Text('Понятно'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  FilledButton(
                    key: HomeScreen.startPracticeKey,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PracticeScreen(
                            activityName: widget.activityName,
                          ),
                        ),
                      );
                    },
                    child: const Text('Начать занятие'),
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
