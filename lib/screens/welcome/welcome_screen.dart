import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/features/timer/domain/controllers/daily_timer_controller.dart';
import 'package:tenk/screens/activities/activities_screen.dart';
import 'package:tenk/screens/activities/widgets/activity_island.dart';
import 'package:tenk/screens/activities/widgets/activity_landmark.dart';
import 'package:tenk/ui/widgets/liquid_glass_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.repository,
    required this.timerController,
  });

  final FirstActivityRepository repository;
  final DailyTimerController timerController;

  static const routeName = '/';
  static const startButtonKey = Key('welcome_start_button');
  static const backgroundAsset = ActivityIsland.backgroundAsset;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ActivityIsland(
            summitContent: ActivityLandmark(hours: 10000),
            summitSizeFactor: Size(0.24, 0.11),
            summitAnchor: ActivityIsland.roadEndpointAnchor,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x260B271B)],
                stops: [0.45, 1],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 650;
                final horizontalPadding = constraints.maxWidth < 360
                    ? 24.0
                    : 32.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    compact ? 16 : 24,
                    horizontalPadding,
                    compact ? 16 : 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (compact ? 32 : 48),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'TENK',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: appInkColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 8,
                            ),
                          ),
                          const Spacer(flex: 5),
                          Text(
                            'Time Becomes\nMastery',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontSize: compact ? 31 : 36,
                              height: 1.08,
                              letterSpacing: -0.8,
                              shadows: const [
                                Shadow(
                                  color: Color(0x66000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: compact ? 12 : 18),
                          Text(
                            'Choose an activity, dedicate time to it, and '
                            'watch your progress grow.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontSize: compact ? 16 : 18,
                              height: 1.4,
                              shadows: const [
                                Shadow(
                                  color: Color(0x66000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: compact ? 12 : 18),
                          LiquidGlassButton(
                            key: startButtonKey,
                            label: 'Get Started',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ActivitiesScreen(
                                    repository: repository,
                                    timerController: timerController,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
