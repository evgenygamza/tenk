import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:tenk/ui/ui_tokens.dart';

class NavBar extends StatelessWidget {
  /// 0 = no selection
  /// 1..N = selected tab (1-based)
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

    final borderColor = cs.outlineVariant.withValues(
      alpha: UiTokens.glassBorderOpacity,
    );
    final surfaceColor = cs.surface.withValues(
      alpha: UiTokens.glassSurfaceOpacity,
    );

    final radius = BorderRadius.circular(UiTokens.navRadius);

    final hasSelection = selectedIndex > 0;
    final materialSelected = hasSelection
        ? (selectedIndex - 1).clamp(0, destinations.length - 1)
        : 0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: UiTokens.navPadding,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: UiTokens.navMaxWidth),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 30,
                    spreadRadius: -18,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: UiTokens.glassBlurSigma,
                    sigmaY: UiTokens.glassBlurSigma,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(
                        color: borderColor,
                        width: UiTokens.glassBorderWidth,
                      ),
                      color: surfaceColor.withValues(alpha: 0.28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
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
                        indicatorColor: hasSelection
                            ? cs.primary.withValues(alpha: 0.16)
                            : Colors.transparent,
                        labelTextStyle: WidgetStatePropertyAll(
                          Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      child: NavigationBar(
                        selectedIndex: materialSelected,
                        onDestinationSelected: (i) {
                          // Convert back to 1-based for the app layer.
                          onDestinationSelected(i + 1);
                        },
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
