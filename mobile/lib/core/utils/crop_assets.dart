import 'package:flutter/material.dart';

/// Crop image paths and tile colors under [assets/images/].
abstract class CropAssets {
  static String imagePathFor(String crop) {
    switch (crop.toLowerCase().trim()) {
      case 'wheat':
        return 'assets/images/wheat.png';
      case 'maize':
      case 'corn':
        return 'assets/images/maize.png';
      case 'rice':
        return 'assets/images/rice.png';
      case 'tomato':
        return 'assets/images/tomato.png';
      case 'potato':
        return 'assets/images/potato.png';
      case 'mango':
        return 'assets/images/mango.png';
      case 'jowar (sorghum)':
      case 'jowar':
      case 'sorghum':
        return 'assets/images/jowar.png';
      case 'green fodder':
        return 'assets/images/green_fodder.png';
      default:
        return 'assets/images/green_fodder.png';
    }
  }

  static Color backgroundColorFor(String crop, {bool isDark = false}) {
    if (isDark) return const Color(0xFF2C2C2E);
    switch (crop.toLowerCase().trim()) {
      case 'wheat':
        return const Color(0xFFFEF3C7);
      case 'maize':
      case 'corn':
        return const Color(0xFFECFCCB);
      case 'rice':
        return const Color(0xFFCFFAFE);
      case 'tomato':
        return const Color(0xFFFEE2E2);
      case 'potato':
        return const Color(0xFFFEF08A);
      case 'mango':
        return const Color(0xFFFEF9C3);
      case 'jowar (sorghum)':
      case 'jowar':
      case 'sorghum':
        return const Color(0xFFD1FAE5);
      case 'green fodder':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFDCFCE7);
    }
  }
}
