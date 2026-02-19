import 'package:flutter/material.dart';

import 'package:tenk/features/sessions/presentation/screens/dashboard_screen.dart';
import 'package:tenk/features/sessions/presentation/screens/history_screen.dart';
import 'package:tenk/features/sessions/presentation/screens/settings_screen.dart';

class TabsShell extends StatefulWidget {
  const TabsShell({super.key});

  @override
  State<TabsShell> createState() => _TabsShellState();
}

class _TabsShellState extends State<TabsShell> {
  int _tab = 0; // 0=Home, 1=History, 2=Settings

  void _setTab(int i) {
    if (i == _tab) return;
    setState(() => _tab = i);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back behavior:
      // - If not on Home tab: go back to Home (do not exit).
      // - If on Home tab: let the system handle back (exit/app close).
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_tab != 0) setState(() => _tab = 0);
      },
      child: Scaffold(
        extendBody: true, // <-- IMPORTANT: lets body paint behind the nav bar
        body: IndexedStack(
          index: _tab,
          children: const [
            DashboardScreen(),
            HistoryScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: const NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          child: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: _setTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.grid_view_rounded),
                label: 'Dashbord',
              ),
              NavigationDestination(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
