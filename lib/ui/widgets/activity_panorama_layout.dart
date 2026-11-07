import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Maps artwork coordinates to the camera shared by the panorama and milestones.
class ActivityPanoramaLayout {
  const ActivityPanoramaLayout({required this.viewport, required this.page});

  static const artworkSize = Size(8400, 2600);
  static const frameSize = Size(1200, 2600);
  static const cameraCenters = <double>[900, 2570, 4200, 5910, 7665];

  /// Ground contact points in original PNG pixels, measured from its top left.
  static const trailEndpoints = <Offset>[
    Offset(900, 900),
    Offset(2570, 920),
    Offset(4200, 800),
    Offset(5910, 920),
    Offset(7665, 920),
  ];

  final Size viewport;
  final double page;

  double get scale => math.max(
    viewport.width / frameSize.width,
    viewport.height / frameSize.height,
  );

  double get cameraCenter {
    final position = page.clamp(0.0, cameraCenters.length - 1.0);
    final first = position.floor();
    final next = math.min(first + 1, cameraCenters.length - 1);
    return cameraCenters[first] +
        (cameraCenters[next] - cameraCenters[first]) * (position - first);
  }

  Offset get artworkOffset => Offset(
    viewport.width / 2 - cameraCenter * scale,
    (viewport.height - artworkSize.height * scale) / 2,
  );

  Size get renderedArtworkSize => artworkSize * scale;

  Rect get visibleSourceRect => Rect.fromLTWH(
    -artworkOffset.dx / scale,
    -artworkOffset.dy / scale,
    viewport.width / scale,
    viewport.height / scale,
  );

  Offset sourceToViewport(Offset point) => artworkOffset + point * scale;

  Rect finishRect(int index) {
    final anchor = sourceToViewport(trailEndpoints[index]);
    final size = Size(frameSize.width * 0.2, frameSize.height * 0.105) * scale;
    return Rect.fromLTWH(
      anchor.dx - size.width / 2,
      anchor.dy - size.height,
      size.width,
      size.height,
    );
  }
}
