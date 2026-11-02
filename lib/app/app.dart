import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/activities/presentation/screens/create_activity_placeholder_screen.dart';
import 'package:tenk/features/onboarding/presentation/screens/welcome_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TenK',
      theme: buildAppTheme(),
      initialRoute: WelcomeScreen.routeName,
      routes: {
        WelcomeScreen.routeName: (_) => const WelcomeScreen(),
        CreateActivityPlaceholderScreen.routeName: (_) =>
            const CreateActivityPlaceholderScreen(),
      },
    );
  }
}
