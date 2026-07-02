import 'package:flutter/material.dart';

/// Full-bleed asset image with a gradient overlay for readable foreground content.
class AiModelBackground extends StatelessWidget {
  final String imageAsset;
  final Widget? child;
  final List<Color>? gradientColors;
  final List<double>? gradientStops;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;

  const AiModelBackground({
    super.key,
    required this.imageAsset,
    this.child,
    this.gradientColors,
    this.gradientStops,
    this.gradientBegin = Alignment.topCenter,
    this.gradientEnd = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: gradientBegin,
              end: gradientEnd,
              colors: gradientColors ??
                  [
                    Colors.black.withAlpha(90),
                    Colors.black.withAlpha(160),
                    Colors.black.withAlpha(220),
                  ],
              stops: gradientStops ?? const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}
