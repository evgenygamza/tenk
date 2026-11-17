import 'package:flutter/material.dart';

/// Selects the dedicated illustrated landmark for a supported milestone.
class ActivityLandmark extends StatelessWidget {
  const ActivityLandmark({super.key, required this.hours});

  static const landmarkKey = Key('activity_landmark');
  static const hundredHoursAsset =
      'lib/ui/graphics/landmark_100_hours_angled.png';
  static const tenThousandHoursAsset =
      'lib/ui/graphics/landmark_10000_hours_angled.png';
  static const assetByHours = <int, String>{
    10: 'lib/ui/graphics/landmark_10_hours_angled.png',
    50: 'lib/ui/graphics/landmark_50_hours_angled.png',
    100: hundredHoursAsset,
    250: 'lib/ui/graphics/landmark_250_hours_angled.png',
    500: 'lib/ui/graphics/landmark_500_hours_angled.png',
    1000: 'lib/ui/graphics/landmark_1000_hours_angled.png',
    2000: 'lib/ui/graphics/landmark_2000_hours_angled.png',
    3000: 'lib/ui/graphics/landmark_3000_hours_angled.png',
    4000: 'lib/ui/graphics/landmark_4000_hours_angled.png',
    5000: 'lib/ui/graphics/landmark_5000_hours_angled.png',
    6000: 'lib/ui/graphics/landmark_6000_hours_angled.png',
    7000: 'lib/ui/graphics/landmark_7000_hours_angled.png',
    8000: 'lib/ui/graphics/landmark_8000_hours_angled.png',
    9000: 'lib/ui/graphics/landmark_9000_hours_angled.png',
    10000: tenThousandHoursAsset,
  };

  final int hours;

  @override
  Widget build(BuildContext context) {
    final asset = assetByHours[hours];
    if (asset == null) {
      throw UnsupportedError(
        'Add a dedicated landmark design for $hours hours.',
      );
    }
    return _LandmarkImage(hours: hours, asset: asset);
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
      child: ExcludeSemantics(child: Image.asset(asset, fit: BoxFit.contain)),
    );
  }
}
