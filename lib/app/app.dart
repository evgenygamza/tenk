import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/activities/data/repositories/shared_preferences_first_activity_repository.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/features/activities/presentation/screens/create_activity_screen.dart';
import 'package:tenk/features/activities/presentation/screens/home_screen.dart';
import 'package:tenk/features/onboarding/presentation/screens/welcome_screen.dart';

class App extends StatefulWidget {
  const App({super.key, this.firstActivityRepository});

  final FirstActivityRepository? firstActivityRepository;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final FirstActivityRepository _repository;
  late Future<({String? name, bool failed})> _activity;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.firstActivityRepository ??
        SharedPreferencesFirstActivityRepository();
    _activity = _loadActivity();
  }

  Future<({String? name, bool failed})> _loadActivity() async {
    try {
      return (name: await _repository.loadName(), failed: false);
    } catch (_) {
      return (name: null, failed: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TenK',
      theme: buildAppTheme(),
      home: FutureBuilder<({String? name, bool failed})>(
        future: _activity,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data!.failed) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Не удалось загрузить занятие',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => setState(() {
                            _activity = _loadActivity();
                          }),
                          child: const Text('Попробовать снова'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          final name = snapshot.data!.name;
          return name == null || name.trim().isEmpty
              ? const WelcomeScreen()
              : HomeScreen(activityName: name);
        },
      ),
      routes: {
        CreateActivityScreen.routeName: (context) => CreateActivityScreen(
          repository: _repository,
          onSaved: (activityName) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (_) => HomeScreen(
                  activityName: activityName,
                  showTutorial: true,
                ),
              ),
              (_) => false,
            );
          },
        ),
      },
    );
  }
}
