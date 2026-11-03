import 'package:flutter/material.dart';

/// Renders the shared island and positions a widget at an artwork anchor.
class ActivityIsland extends StatelessWidget {
  const ActivityIsland({
    super.key,
    required this.summitContent,
    required this.summitSizeFactor,
    this.summitAnchor = roadEndpointAnchor,
    this.floatFactor = 0,
  });

  static const backgroundAsset = 'assets/images/island_background.png';
  static const artworkSize = Size(852, 1846);
  // Normalized coordinates of the path tip in the source island artwork.
  static const roadEndpointAnchor = Offset(0.539, 0.285);

  final Widget summitContent;
  final Size summitSizeFactor;
  final Offset summitAnchor;
  final double floatFactor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = constraints.biggest;
        final fitted = applyBoxFit(BoxFit.cover, artworkSize, viewportSize);
        final imageOffset = Offset(
          (viewportSize.width - fitted.destination.width) / 2,
          (viewportSize.height - fitted.destination.height) / 2,
        );
        final summit =
            imageOffset +
            Offset(
              fitted.destination.width * summitAnchor.dx,
              fitted.destination.height * summitAnchor.dy,
            );
        final summitSize = Size(
          fitted.destination.width * summitSizeFactor.width,
          fitted.destination.height * summitSizeFactor.height,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            ExcludeSemantics(
              child: Image.asset(backgroundAsset, fit: BoxFit.cover),
            ),
            Positioned(
              left: summit.dx - summitSize.width / 2,
              top:
                  summit.dy -
                  summitSize.height -
                  summitSize.height * floatFactor,
              child: SizedBox.fromSize(size: summitSize, child: summitContent),
            ),
          ],
        );
      },
    );
  }
}
