import 'package:flutter/material.dart';

class BoundlessInteractionStack extends StatelessWidget {
  final List<Widget> children;
  final TransformationController? transformationController;
  final EdgeInsets boundaryMargin;
  final double minScale;
  final double maxScale;

  const BoundlessInteractionStack({
    Key? key,
    required this.children,
    this.transformationController,
    this.boundaryMargin = const EdgeInsets.all(5000),
    this.minScale = 0.2,
    this.maxScale = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a container that's much larger than the screen
    return SizedBox.expand(
      child: InteractiveViewer(
        transformationController: transformationController,
        boundaryMargin: boundaryMargin,
        minScale: minScale,
        maxScale: maxScale,
        child: SizedBox(
          // Make this significantly larger than the boundary margin
          width: 5000, // Large enough to contain all possible card positions
          height: 5000,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: children,
          ),
        ),
      ),
    );
  }
}
