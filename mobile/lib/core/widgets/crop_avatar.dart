import 'package:farmtec/core/utils/crop_assets.dart';
import 'package:flutter/material.dart';

/// Circular crop photo for list tiles and stat cards.
class CropAvatar extends StatelessWidget {
  final String crop;
  final double size;
  final bool isDark;

  const CropAvatar({
    super.key,
    required this.crop,
    this.size = 50,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _CropImage(crop: crop, size: size, isDark: isDark),
      ),
    );
  }
}

/// Rounded crop photo for dropdowns and compact rows.
class CropThumbnail extends StatelessWidget {
  final String crop;
  final double size;
  final double borderRadius;
  final bool isDark;

  const CropThumbnail({
    super.key,
    required this.crop,
    this.size = 32,
    this.borderRadius = 8,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: _CropImage(crop: crop, size: size, isDark: isDark),
    );
  }
}

class _CropImage extends StatelessWidget {
  final String crop;
  final double size;
  final bool isDark;

  const _CropImage({
    required this.crop,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = CropAssets.backgroundColorFor(crop, isDark: isDark);
    return Image.asset(
      CropAssets.imagePathFor(crop),
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: bg,
        child: Icon(
          Icons.eco_rounded,
          size: size * 0.45,
          color: Colors.white70,
        ),
      ),
    );
  }
}
