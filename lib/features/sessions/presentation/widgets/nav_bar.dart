import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:tenk/ui/ui_tokens.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final borderColor =
    cs.outlineVariant.withValues(alpha: UiTokens.glassBorderOpacity);
    final surfaceColor =
    cs.surface.withValues(alpha: UiTokens.glassSurfaceOpacity);

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(UiTokens.navRadius),
      side: BorderSide(color: borderColor, width: UiTokens.glassBorderWidth),
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: UiTokens.navPadding,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: UiTokens.navMaxWidth),
            child: DecoratedBox(
              // Outer: pill-shaped shadow, not clipped
              decoration: ShapeDecoration(
                shape: shape,
                shadows: [
                  // down
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  // soft shade above
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 30,
                    spreadRadius: -58,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: ClipPath(
                // Clip exactly to the same pill shape
                clipper: ShapeBorderClipper(shape: shape),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: UiTokens.glassBlurSigma,
                    sigmaY: UiTokens.glassBlurSigma,
                  ),
                  child: DecoratedBox(
                    // Inner: glass fill (ONLY gradient, no color)
                    decoration: ShapeDecoration(
                      shape: shape,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          // base glass tint
                          surfaceColor.withValues(alpha: 0.28),
                          Colors.white.withValues(alpha: 0.10),
                          Colors.black.withValues(alpha: 0.03),
                        ],
                      ),
                    ),
                    child: NavigationBarTheme(
                      data: NavigationBarThemeData(
                        height: UiTokens.navHeight,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        indicatorColor: cs.primary.withValues(alpha: 0.16),
                        labelTextStyle: WidgetStatePropertyAll(
                          Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      child: NavigationBar(
                        selectedIndex: selectedIndex,
                        onDestinationSelected: onDestinationSelected,
                        destinations: destinations,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}