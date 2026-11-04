import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

class ActivityAddButton extends StatelessWidget {
  const ActivityAddButton({
    super.key,
    required this.compact,
    required this.onPressed,
  });

  final bool compact;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 68.0 : 76.0;
    return Semantics(
      label: 'Add activity',
      button: true,
      enabled: onPressed != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.24),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.88),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44202A22),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 44),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
