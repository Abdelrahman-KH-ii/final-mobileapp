import 'package:farmtec/core/themes/pallete.dart';
import 'package:flutter/material.dart';

/// Farm pin for map markers.
class FarmMarkerIcon extends StatelessWidget {
  final double size;
  final double iconSize;

  const FarmMarkerIcon({
    super.key,
    this.size = 40,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Pallete.primary,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: size >= 38 ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(70),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.grass_rounded,
          size: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }
}
