import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/sessions/data/repositories/sessions_repository_impl.dart';
import 'package:tenk/features/sessions/data/sources/sessions_local_data_source.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/screens/dashboard_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = SessionsRepositoryImpl(SessionsLocalDataSource());

    return ChangeNotifierProvider(
      create: (_) => SessionsController(repo),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TenK',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF4F46E5), // индиго как в мокапе
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
