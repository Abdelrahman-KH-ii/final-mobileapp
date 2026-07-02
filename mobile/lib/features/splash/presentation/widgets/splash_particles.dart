import 'dart:math' as math;

import 'package:farmtec/core/themes/pallete.dart';
import 'package:flutter/material.dart';

class SplashParticles extends StatelessWidget {
  final Animation<double> particleAnimation;
  final Animation<double> iconScale;
  final bool isDark;

  const SplashParticles({
    super.key,
    required this.particleAnimation,
    required this.iconScale,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final rng = math.Random(42);
    return Stack(
      children: List.generate(18, (i) {
        final startX = rng.nextDouble();
        final startY = rng.nextDouble();
        final size = 4.0 + rng.nextDouble() * 8;
        final speed = 0.3 + rng.nextDouble() * 0.7;
        final delay = rng.nextDouble();

        return AnimatedBuilder(
          animation: particleAnimation,
          builder: (context, _) {
            final t = ((particleAnimation.value + delay) % 1.0) * speed;
            final x = startX + math.sin(t * math.pi * 2 + i) * 0.05;
            final y = startY - t * 0.3;
            final opacity = (1 - t).clamp(0.0, 0.4) * iconScale.value;

            return Positioned(
              left: x * MediaQuery.of(context).size.width,
              top: (y % 1.0) * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Pallete.chartGreen.withAlpha(80)
                        : Pallete.primary.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );

      }),
    );
  }
}
