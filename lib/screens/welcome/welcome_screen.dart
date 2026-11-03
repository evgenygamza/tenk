import 'package:flutter/material.dart';
import 'package:tenk/screens/create_activity/create_activity_screen.dart';
import 'package:tenk/ui/widgets/liquid_glass_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const routeName = '/';
  static const startButtonKey = Key('welcome_start_button');
  static const backgroundAsset = 'assets/images/welcome_background.png';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            child: Image.asset(backgroundAsset, fit: BoxFit.cover),
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
                              color: Color(0xFF064A35),
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
                              Navigator.of(
                                context,
                              ).pushNamed(CreateActivityScreen.routeName);
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
