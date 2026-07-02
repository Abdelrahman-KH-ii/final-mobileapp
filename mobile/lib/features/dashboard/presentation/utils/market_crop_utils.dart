import 'package:farmtec/core/services/crop_lifecycle_service.dart';

/// Maps farm crop names to commodities API symbols and matches API labels.
class MarketCropUtils {
  MarketCropUtils._();

  static String l10nKey(String crop) => CropLifecycleService.cropL10nKey(crop);

  static String? apiSymbolFor(String crop) {
    switch (crop.toLowerCase()) {
      case 'wheat':
        return 'WHEAT';
      case 'maize':
      case 'corn':
        return 'CORN';
      case 'rice':
        return 'RICE';
      default:
        return null;
    }
  }

  static bool matchesCommodity(String apiName, String farmCrop) {
    final key = l10nKey(farmCrop);
    final normalized = apiName.toLowerCase().replaceAll(' ', '_');
    if (normalized == key) return true;
    if (normalized.contains(key) || key.contains(normalized)) return true;
    if ((key == 'maize' || key == 'corn') &&
        (normalized == 'corn' || normalized == 'maize')) {
      return true;
    }
    if (key == 'jowar_(sorghum)' &&
        (normalized.contains('sorghum') || normalized.contains('jowar'))) {
      return true;
    }
    return false;
  }
}
