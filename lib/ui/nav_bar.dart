import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex; // 1-based: 1=Home, 2=History, 3=Settings
  final ValueChanged<int> onDestinationSelected; // receives 1-based
  final List<NavigationDestination> destinations;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    // Flutter NavigationBar uses 0-based indices.
    final materialSelected = (selectedIndex - 1).clamp(
      0,
      destinations.length - 1,
    );

    return NavigationBar(
      selectedIndex: materialSelected,
      onDestinationSelected: (i) => onDestinationSelected(i + 1),
      destinations: destinations,
    );
  }
}
