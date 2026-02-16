import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/sessions/presentation/screens/home_screen.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionsController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TenK',
        theme: ThemeData(useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}