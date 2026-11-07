import 'dart:ui' show BlurStyle, ImageFilter, MaskFilter;

import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/activities/presentation/activity_icon_catalog.dart';
import 'package:tenk/features/timer/domain/controllers/daily_timer_controller.dart';

class ActiveTimerGeoWidget extends StatelessWidget {
  const ActiveTimerGeoWidget({
    super.key,
    required this.activities,
    required this.selectedIndex,
    required this.timerController,
    required this.onTap,
  });

  static const widgetKey = Key('active_timer_geo_widget');
  static const pinKey = Key('active_timer_geo_pin');

  final List<FirstActivity> activities;
  final int selectedIndex;
  final DailyTimerController timerController;
  final ValueChanged<FirstActivity> onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: timerController,
      builder: (context, _) {
        final activeId = timerController.activeActivityId;
        if (timerController.status != DailyTimerStatus.running ||
            activeId == null) {
          return const SizedBox.shrink();
        }

        final activityIndex = activities.indexWhere(
          (activity) => activity.id == activeId,
        );
        if (activityIndex < 0 || activityIndex == selectedIndex) {
          return const SizedBox.shrink();
        }

        final activity = activities[activityIndex];
        final isLeftSide = activityIndex < selectedIndex;
        final icon = activityIconFor(activity.iconId).icon;

        return LayoutBuilder(
          builder: (context, constraints) {
            final top = constraints.maxHeight * 0.32;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: top,
                  left: isLeftSide ? 16 : null,
                  right: isLeftSide ? null : 16,
                  child: _TimerGeoPin(
                    isLeftSide: isLeftSide,
                    icon: icon,
                    activityName: activity.name,
                    onTap: () => onTap(activity),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TimerGeoPin extends StatelessWidget {
  const _TimerGeoPin({
    required this.isLeftSide,
    required this.icon,
    required this.activityName,
    required this.onTap,
  });

  final bool isLeftSide;
  final IconData icon;
  final String activityName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alignment = isLeftSide
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: isLeftSide ? 10 : 0,
              right: isLeftSide ? 0 : 10,
            ),
            child: Text(
              'In progress',
              textAlign: isLeftSide ? TextAlign.left : TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Color(0x66000000),
                    blurRadius: 5,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Semantics(
            button: true,
            label: 'Switch to $activityName',
            child: Tooltip(
              message: 'Go to $activityName',
              child: GestureDetector(
                key: ActiveTimerGeoWidget.widgetKey,
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: _LiquidGlassPin(icon: icon, isLeftSide: isLeftSide),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiquidGlassPin extends StatelessWidget {
  const _LiquidGlassPin({required this.icon, required this.isLeftSide});

  final IconData icon;
  final bool isLeftSide;

  @override
  Widget build(BuildContext context) {
    final shape = _GeoPinClipper(isLeftSide: isLeftSide);
    return SizedBox(
      key: ActiveTimerGeoWidget.pinKey,
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: _GeoPinShadowPainter(shape),
        foregroundPainter: _GeoPinBorderPainter(shape),
        child: ClipPath(
          clipper: shape,
          child: Stack(
            fit: StackFit.expand,
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.30),
                        appMossColor.withValues(alpha: 0.16),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(isLeftSide ? 0.08 : -0.08, -0.08),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeoPinClipper extends CustomClipper<Path> {
  const _GeoPinClipper({required this.isLeftSide});

  final bool isLeftSide;

  @override
  Path getClip(Size size) {
    double x(double value) => (isLeftSide ? 1 - value : value) * size.width;
    double y(double value) => value * size.height;

    // Adapt the round Lucide message-circle silhouette into a short geopin.
    // Mirroring keeps the round body and points the tail toward the activity.
    final path = Path()
      ..moveTo(x(0.46), y(0.04))
      ..cubicTo(x(0.69), y(0.04), x(0.88), y(0.23), x(0.88), y(0.46))
      ..cubicTo(x(0.88), y(0.55), x(0.86), y(0.62), x(0.82), y(0.67))
      ..cubicTo(x(0.83), y(0.74), x(0.87), y(0.81), x(0.85), y(0.85))
      ..cubicTo(x(0.80), y(0.84), x(0.73), y(0.8), x(0.67), y(0.82))
      ..cubicTo(x(0.62), y(0.86), x(0.55), y(0.88), x(0.46), y(0.88))
      ..cubicTo(x(0.23), y(0.88), x(0.04), y(0.69), x(0.04), y(0.46))
      ..cubicTo(x(0.04), y(0.23), x(0.23), y(0.04), x(0.46), y(0.04))
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _GeoPinClipper oldClipper) =>
      oldClipper.isLeftSide != isLeftSide;
}

class _GeoPinBorderPainter extends CustomPainter {
  const _GeoPinBorderPainter(this.clipper);

  final _GeoPinClipper clipper;

  @override
  void paint(Canvas canvas, Size size) {
    final path = clipper.getClip(size);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(covariant _GeoPinBorderPainter oldDelegate) => false;
}

class _GeoPinShadowPainter extends CustomPainter {
  const _GeoPinShadowPainter(this.clipper);

  final _GeoPinClipper clipper;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..translate(0, 4)
      ..drawPath(
        clipper.getClip(size),
        Paint()
          ..color = appMossColor.withValues(alpha: 0.24)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _GeoPinShadowPainter oldDelegate) => false;
}
