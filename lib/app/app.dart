import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/activities/data/repositories/activities_repository_impl.dart';
import 'package:tenk/features/activities/data/sources/activities_local_data_source.dart';
import 'package:tenk/features/activities/presentation/state/activities_controller.dart';

import 'package:tenk/features/sessions/data/repositories/sessions_repository_impl.dart';
import 'package:tenk/features/sessions/data/sources/sessions_local_data_source.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';

import 'package:tenk/features/sessions/presentation/screens/dashboard_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionsRepo = SessionsRepositoryImpl(SessionsLocalDataSource());
    final activitiesRepo = ActivitiesRepositoryImpl(
      ActivitiesLocalDataSource(),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionsController(sessionsRepo)),
        ChangeNotifierProvider(
          create: (_) => ActivitiesController(activitiesRepo),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TenK',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF4F46E5),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
