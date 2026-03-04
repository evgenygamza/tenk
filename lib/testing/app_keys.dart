import 'package:flutter/widgets.dart';

/// Keys used by widget smoke tests to find stable UI anchors.
/// Keep them constant and avoid changing names unless you update tests too.
abstract class AppKeys {
  // Bottom navigation
  static const Key tabDashboard = Key('tab_dashboard');
  static const Key tabHistory = Key('tab_history');
  static const Key tabSettings = Key('tab_settings');

  // Root widgets of main screens
  static const Key screenDashboard = Key('screen_dashboard');
  static const Key screenHistory = Key('screen_history');
  static const Key screenSettings = Key('screen_settings');

  // Dashboard
  static const Key addActivityCard = Key('add_activity_card');

  // Generic controls
  static const Key startButton = Key('start_button');
}
