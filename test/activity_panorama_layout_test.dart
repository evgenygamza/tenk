import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/ui/widgets/activity_panorama_layout.dart';

void main() {
  test(
    'each resting frame centers its peninsula without exposing a neighbor',
    () {
      const centers = <double>[900, 2570, 4200, 5910, 7665];
      const endpointHeights = <double>[900, 920, 800, 920, 920];

      for (var index = 0; index < centers.length; index++) {
        final layout = ActivityPanoramaLayout(
          viewport: const Size(1200, 2600),
          page: index.toDouble(),
        );
        final frame = layout.visibleSourceRect;
        expect(frame, Rect.fromLTWH(centers[index] - 600, 0, 1200, 2600));
        expect(frame.left, greaterThanOrEqualTo(0));
        expect(frame.right, lessThanOrEqualTo(8400));
        expect(
          layout.finishRect(index).bottomCenter,
          Offset(600, endpointHeights[index]),
        );
        if (index > 0) {
          expect(frame.contains(Offset(centers[index - 1], 1300)), isFalse);
        }
        if (index + 1 < centers.length) {
          expect(frame.contains(Offset(centers[index + 1], 1300)), isFalse);
        }
      }
    },
  );

  test('halfway camera positions cross sea outside both resting frames', () {
    const seaCenters = <double>[1735, 3385, 5055, 6787.5];

    for (var index = 0; index < seaCenters.length; index++) {
      final before = ActivityPanoramaLayout(
        viewport: const Size(1200, 2600),
        page: index.toDouble(),
      );
      final during = ActivityPanoramaLayout(
        viewport: const Size(1200, 2600),
        page: index + 0.5,
      );
      final after = ActivityPanoramaLayout(
        viewport: const Size(1200, 2600),
        page: index + 1.0,
      );
      expect(during.cameraCenter, seaCenters[index]);
      expect(during.cameraCenter, greaterThan(before.visibleSourceRect.right));
      expect(during.cameraCenter, lessThan(after.visibleSourceRect.left));
      expect(during.artworkOffset.dy, before.artworkOffset.dy);
      expect(during.renderedArtworkSize, before.renderedArtworkSize);
      expect(after.artworkOffset.dy, before.artworkOffset.dy);
    }
  });

  test(
    'milestone ground contacts follow the artwork on tall and compact screens',
    () {
      const tall = ActivityPanoramaLayout(viewport: Size(393, 852), page: 2);
      expect(tall.finishRect(2).bottomCenter.dx, closeTo(196.5, 0.001));
      expect(tall.finishRect(2).bottom, closeTo(262.153846, 0.001));
      expect(tall.visibleSourceRect.top, closeTo(0, 0.001));

      const compact = ActivityPanoramaLayout(viewport: Size(320, 568), page: 2);
      expect(compact.finishRect(2).bottomCenter.dx, closeTo(160, 0.001));
      expect(compact.finishRect(2).bottom, closeTo(150.666667, 0.001));
      expect(compact.visibleSourceRect.top, closeTo(235, 0.001));
      expect(compact.visibleSourceRect.bottom, closeTo(2365, 0.001));

      const during = ActivityPanoramaLayout(
        viewport: Size(320, 568),
        page: 1.5,
      );
      expect(
        during.finishRect(2).bottom,
        closeTo(compact.finishRect(2).bottom, 0.001),
      );
      expect(
        during.finishRect(2).bottomCenter.dx -
            compact.finishRect(2).bottomCenter.dx,
        closeTo(217.333333, 0.001),
      );
    },
  );
}
