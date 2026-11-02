import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/activities/data/repositories/shared_preferences_first_activity_repository.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/features/activities/presentation/screens/create_activity_screen.dart';
import 'package:tenk/features/activities/presentation/screens/home_placeholder_screen.dart';
import 'package:tenk/features/onboarding/presentation/screens/welcome_screen.dart';

class App extends StatelessWidget {
  const App({super.key, this.firstActivityRepository});

  final FirstActivityRepository? firstActivityRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TenK',
      theme: buildAppTheme(),
      initialRoute: WelcomeScreen.routeName,
      routes: {
        WelcomeScreen.routeName: (_) => const WelcomeScreen(),
        CreateActivityScreen.routeName: (context) => CreateActivityScreen(
          repository:
              firstActivityRepository ??
              SharedPreferencesFirstActivityRepository(),
          onSaved: (activityName) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) =>
                    HomePlaceholderScreen(activityName: activityName),
              ),
            );
          },
        ),
      },
    );
  }
}
