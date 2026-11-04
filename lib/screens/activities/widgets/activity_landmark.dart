import 'package:flutter/material.dart';

/// Selects the dedicated illustrated landmark for a supported milestone.
class ActivityLandmark extends StatelessWidget {
  const ActivityLandmark({super.key, required this.hours});

  static const landmarkKey = Key('activity_landmark');
  static const hundredHoursAsset =
      'assets/images/landmark_100_hours_angled.png';
  static const tenThousandHoursAsset =
      'assets/images/landmark_10000_hours_angled.png';

  final int hours;

  @override
  Widget build(BuildContext context) {
    return switch (hours) {
      100 => const _HundredHourLandmark(),
      10000 => const _TenThousandHourLandmark(),
      _ => throw UnsupportedError(
        'Add a dedicated landmark design for $hours hours.',
      ),
    };
  }
}

class _HundredHourLandmark extends StatelessWidget {
  const _HundredHourLandmark();

  @override
  Widget build(BuildContext context) {
    return _LandmarkImage(
      hours: 100,
      asset: ActivityLandmark.hundredHoursAsset,
    );
  }
}

class _TenThousandHourLandmark extends StatelessWidget {
  const _TenThousandHourLandmark();

  @override
  Widget build(BuildContext context) {
    return _LandmarkImage(
      hours: 10000,
      asset: ActivityLandmark.tenThousandHoursAsset,
    );
  }
}

class _LandmarkImage extends StatelessWidget {
  const _LandmarkImage({required this.hours, required this.asset});

  final int hours;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: ActivityLandmark.landmarkKey,
      label: '$hours hours',
      image: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 0.72,
              heightFactor: 0.035,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0x1F0B271B),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3D0B271B),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ExcludeSemantics(child: Image.asset(asset, fit: BoxFit.contain)),
        ],
      ),
    );
  }
}
