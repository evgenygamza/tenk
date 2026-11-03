import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/activities/data/repositories/shared_preferences_first_activity_repository.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/screens/activities/activities_screen.dart';
import 'package:tenk/screens/welcome/welcome_screen.dart';

class App extends StatefulWidget {
  const App({super.key, this.firstActivityRepository});

  final FirstActivityRepository? firstActivityRepository;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final FirstActivityRepository _repository;
  late Future<({FirstActivity? activity, bool failed})> _activity;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.firstActivityRepository ??
        SharedPreferencesFirstActivityRepository();
    _activity = _loadActivity();
  }

  Future<({FirstActivity? activity, bool failed})> _loadActivity() async {
    try {
      return (activity: await _repository.loadActivity(), failed: false);
    } catch (_) {
      return (activity: null, failed: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TenK',
      theme: buildAppTheme(),
      home: FutureBuilder<({FirstActivity? activity, bool failed})>(
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
                          'Could not load your activity',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => setState(() {
                            _activity = _loadActivity();
                          }),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          final activity = snapshot.data!.activity;
          return activity == null || activity.name.trim().isEmpty
              ? WelcomeScreen(repository: _repository)
              : ActivitiesScreen(
                  activityName: activity.name,
                  activityIconId: activity.iconId,
                  repository: _repository,
                );
        },
      ),
    );
  }
}
