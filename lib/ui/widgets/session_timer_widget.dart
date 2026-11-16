import 'dart:math' as math;
import 'dart:ui' show FontFeature, ImageFilter;

import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';

/// Timer artwork drawn in logical pixels; persistence belongs to its caller.
class SessionTimerWidget extends StatelessWidget {
  const SessionTimerWidget({
    super.key,
    required this.running,
    required this.dailyElapsed,
    required this.weeklyProgress,
    required this.actionLabel,
    required this.onPressed,
    required this.buttonKey,
    this.diameter = appTimerRunningDiameter,
    this.reduceTransparency = false,
  });

  static const ringKey = Key('session_timer_weekly_ring');
  static const elapsedKey = Key('session_timer_elapsed');
  static const circleKey = Key('session_timer_circle');

  final bool running;
  final Duration dailyElapsed;
  final double weeklyProgress;
  final String actionLabel;
  final VoidCallback? onPressed;
  final Key buttonKey;
  final double diameter;
  final bool reduceTransparency;

  static String formatElapsed(Duration elapsed) {
    final seconds = math.max(0, elapsed.inSeconds);
    final minutes = (seconds ~/ 60 % 60).toString().padLeft(2, '0');
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return seconds >= 3600
        ? '${seconds ~/ 3600}:$minutes:$remainder'
        : '$minutes:$remainder';
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final reducedMotion = media.disableAnimations;
    final opaque = reduceTransparency || media.highContrast;
    final progress = weeklyProgress.clamp(0.0, 1.0).toDouble();
    final largeText = media.textScaler.scale(16) > 22;
    final elapsedLabel = formatElapsed(dailyElapsed);
    return SizedBox(
      width: diameter,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: running ? diameter : diameter / 2),
          duration: reducedMotion ? Duration.zero : appTimerSizeDuration,
          curve: Curves.easeInOutCubic,
          builder: (context, size, _) {
            final showRunning = running && size >= diameter * 0.85;
            final centerSize = size * 0.88;
            return SizedBox.square(
              key: circleKey,
              dimension: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IgnorePointer(
                    child: Container(
                      width: centerSize,
                      height: centerSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: appTimerShadowColor,
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox.square(
                    dimension: centerSize,
                    child: ClipOval(
                      child: BackdropFilter(
                        enabled: !opaque,
                        filter: ImageFilter.blur(
                          sigmaX: appTimerBlurSigma,
                          sigmaY: appTimerBlurSigma,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: opaque
                                ? appMossColor
                                : appMossColor.withValues(
                                    alpha: appTimerTintOpacity,
                                  ),
                            border: Border.all(color: appTimerRimColor),
                            gradient: opaque
                                ? null
                                : const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0x2EFFFFFF),
                                      Color(0x0AFFFFFF),
                                    ],
                                  ),
                          ),
                          child: Tooltip(
                            message: actionLabel,
                            excludeFromSemantics: true,
                            child: Semantics(
                              label: actionLabel,
                              child: FilledButton(
                                key: buttonKey,
                                onPressed: onPressed,
                                style: FilledButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white70,
                                  shape: const CircleBorder(),
                                  elevation: 0,
                                ),
                                child: AnimatedSwitcher(
                                  duration: reducedMotion
                                      ? Duration.zero
                                      : appTimerContentDuration,
                                  child: showRunning
                                      ? _RunningContent(
                                          key: const ValueKey('running'),
                                          elapsedLabel: elapsedLabel,
                                          diameter: diameter,
                                          largeText: largeText,
                                        )
                                      : const ExcludeSemantics(
                                          key: ValueKey('stopped'),
                                          child: Icon(
                                            Icons.play_arrow_rounded,
                                            size: 40,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Semantics(
                        key: ringKey,
                        container: true,
                        label: 'Weekly practice progress',
                        value: '${(progress * 100).round()}%',
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: progress),
                          duration: reducedMotion
                              ? Duration.zero
                              : appTimerProgressDuration,
                          builder: (context, value, _) => CustomPaint(
                            painter: _WeeklyRingPainter(
                              value,
                              media.highContrast,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RunningContent extends StatelessWidget {
  const _RunningContent({
    super.key,
    required this.elapsedLabel,
    required this.diameter,
    required this.largeText,
  });
  final String elapsedLabel;
  final double diameter;
  final bool largeText;

  @override
  Widget build(BuildContext context) {
    final compact = diameter < 260;
    // Keep accessibility text outside the circle when it needs more room.
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 14,
          right: 14,
          top: diameter * (largeText ? 0.19 : 0.17),
          height: diameter * (largeText ? 0.34 : 0.24),
          child: Semantics(
            container: true,
            label: 'Today’s practice',
            value: elapsedLabel,
            liveRegion: false,
            child: ExcludeSemantics(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  elapsedLabel,
                  key: SessionTimerWidget.elapsedKey,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 38 : 44,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    shadows: const [
                      Shadow(
                        color: appTimerTextShadowColor,
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!largeText)
          Positioned(
            left: 8,
            right: 8,
            top: diameter * 0.43 - (compact ? 8 : 9),
            child: ExcludeSemantics(
              child: Text(
                'Today',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          top: diameter * 0.63 - 20,
          child: const ExcludeSemantics(
            child: Icon(Icons.pause_rounded, size: 40),
          ),
        ),
      ],
    );
  }
}

class _WeeklyRingPainter extends CustomPainter {
  const _WeeklyRingPainter(this.progress, this.highContrast);
  final double progress;
  final bool highContrast;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.47;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;
    canvas.drawCircle(
      center,
      radius,
      paint..color = highContrast ? Colors.white : appTimerTrackColor,
    );
    if (progress <= 0) return;
    final rect = Rect.fromCircle(center: center, radius: radius);
    paint
      ..color = appTimerRimColor
      ..strokeWidth = size.width * 0.05 + 1
      ..strokeCap = StrokeCap.round;
    if (progress >= 1) {
      canvas.drawCircle(center, radius, paint);
      canvas.drawCircle(
        center,
        radius,
        paint
          ..color = appTimerProgressColor
          ..strokeWidth = size.width * 0.05,
      );
    } else {
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, paint);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        paint
          ..color = appTimerProgressColor
          ..strokeWidth = size.width * 0.05,
      );
    }
  }

  @override
  bool shouldRepaint(_WeeklyRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.highContrast != highContrast;
}
