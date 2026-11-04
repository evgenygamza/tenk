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
  late Future<
    ({List<FirstActivity> activities, int selectedIndex, bool failed})
  >
  _activities;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.firstActivityRepository ??
        SharedPreferencesFirstActivityRepository();
    _activities = _loadActivities();
  }

  Future<({List<FirstActivity> activities, int selectedIndex, bool failed})>
  _loadActivities() async {
    try {
      return (
        activities: await _repository.loadActivities(),
        selectedIndex: await _repository.loadSelectedActivityIndex(),
        failed: false,
      );
    } catch (_) {
      return (
        activities: const <FirstActivity>[],
        selectedIndex: 0,
        failed: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TenK',
      theme: buildAppTheme(),
      home:
          FutureBuilder<
            ({List<FirstActivity> activities, int selectedIndex, bool failed})
          >(
            future: _activities,
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
                                _activities = _loadActivities();
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
              final activities = snapshot.data!.activities;
              return activities.isEmpty || activities.first.name.trim().isEmpty
                  ? WelcomeScreen(repository: _repository)
                  : ActivitiesScreen(
                      activities: activities,
                      selectedIndex: snapshot.data!.selectedIndex,
                      repository: _repository,
                    );
            },
          ),
    );
  }
}
