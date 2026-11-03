import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';

class TranslucentPanel extends StatelessWidget {
  const TranslucentPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = appPanelRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33202A22),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: appPanelBlurSigma,
            sigmaY: appPanelBlurSigma,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: appTranslucentPanelColor,
              borderRadius: borderRadius,
              border: Border.all(color: appPanelBorderColor, width: 1.2),
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
