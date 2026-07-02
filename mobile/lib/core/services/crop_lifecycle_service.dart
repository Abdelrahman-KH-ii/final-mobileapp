import 'package:farmtec/core/services/api_client.dart';
import 'package:flutter/material.dart';

class CropStage {
  final String name;
  final String window;
  final String action;
  final IconData icon;

  const CropStage({
    required this.name,
    required this.window,
    required this.action,
    required this.icon,
  });
}

class CropLifecycle {
  final String crop;
  final int daysToHarvest;
  final List<CropStage> stages;

  const CropLifecycle({
    required this.crop,
    required this.daysToHarvest,
    required this.stages,
  });
}

class CropLifecycleStatus {
  final CropLifecycle lifecycle;
  final CropStage currentStage;
  final int currentDay;
  final double progress;
  final DateTime expectedHarvest;

  const CropLifecycleStatus({
    required this.lifecycle,
    required this.currentStage,
    required this.currentDay,
    required this.progress,
    required this.expectedHarvest,
  });
}

class CropLifecycleService {
  CropLifecycleService._();

  static Map<String, CropLifecycle>? _remoteLifecycles;

  static Future<void> ensureLoaded({ApiClient? apiClient}) async {
    if (_remoteLifecycles != null) return;
    final api = apiClient ?? ApiClient();
    final response = await api.get('crops/lifecycle/', auth: false);
    final data = response['data'] as Map<String, dynamic>;
    _remoteLifecycles = {
      for (final entry in data.entries)
        entry.key: _parseLifecycle(entry.value as Map<String, dynamic>),
    };
  }

  static CropLifecycle _parseLifecycle(Map<String, dynamic> json) {
    final stages = (json['stages'] as List<dynamic>? ?? [])
        .map(
          (stage) => CropStage(
            name: stage['name']?.toString() ?? '',
            window: stage['window']?.toString() ?? '',
            action: stage['action']?.toString() ?? '',
            icon: _iconFromName(stage['icon']?.toString() ?? 'eco'),
          ),
        )
        .toList();
    return CropLifecycle(
      crop: json['crop']?.toString() ?? '',
      daysToHarvest: (json['daysToHarvest'] as num?)?.toInt() ?? 120,
      stages: stages,
    );
  }

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'spa':
        return Icons.spa_rounded;
      case 'grass':
        return Icons.grass_rounded;
      case 'eco':
        return Icons.eco_rounded;
      case 'agriculture':
        return Icons.agriculture_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'local_florist':
        return Icons.local_florist_rounded;
      case 'park':
        return Icons.park_rounded;
      default:
        return Icons.eco_rounded;
    }
  }

  static List<String> get availableCrops {
    final remote = _remoteLifecycles;
    if (remote == null) return const [];
    return remote.values.map((lifecycle) => lifecycle.crop).toList();
  }

  static String cropL10nKey(String crop) {
    switch (crop.toLowerCase()) {
      case 'jowar (sorghum)':
        return 'jowar_(sorghum)';
      case 'green fodder':
        return 'green_fodder';
      default:
        return crop.toLowerCase();
    }
  }

  static CropLifecycle forCrop(String crop) {
    final key = crop.toLowerCase();
    final remote = _remoteLifecycles;
    if (remote != null && remote.isNotEmpty) {
      return remote[key] ?? remote.values.first;
    }
    throw StateError('Crop lifecycle data not loaded. Call ensureLoaded() first.');
  }

  static CropLifecycleStatus statusFor(String crop, DateTime plantedAt) {
    final lifecycle = forCrop(crop);
    final daysSince =
        DateTime.now().difference(plantedAt).inDays.clamp(0, lifecycle.daysToHarvest);
    final progress =
        (daysSince / lifecycle.daysToHarvest).clamp(0.0, 1.0).toDouble();
    final stageIndex = progress >= 1.0
        ? lifecycle.stages.length - 1
        : (progress * lifecycle.stages.length).floor().clamp(
              0,
              lifecycle.stages.length - 1,
            );
    return CropLifecycleStatus(
      lifecycle: lifecycle,
      currentStage: lifecycle.stages[stageIndex],
      currentDay: daysSince,
      progress: progress,
      expectedHarvest: plantedAt.add(Duration(days: lifecycle.daysToHarvest)),
    );
  }

  static final Map<String, CropLifecycle> _lifecycles = {
    'wheat': CropLifecycle(
      crop: 'Wheat',
      daysToHarvest: 120,
      stages: [
        CropStage(
          name: 'Germination',
          window: '0-10 days',
          action: 'Keep seedbed evenly moist.',
          icon: Icons.spa_rounded,
        ),
        CropStage(
          name: 'Tillering',
          window: '21-45 days',
          action: 'Check nitrogen and weed pressure.',
          icon: Icons.grass_rounded,
        ),
        CropStage(
          name: 'Heading',
          window: '70-95 days',
          action: 'Watch disease and water stress.',
          icon: Icons.eco_rounded,
        ),
        CropStage(
          name: 'Maturity',
          window: '100-120 days',
          action: 'Reduce irrigation before harvest.',
          icon: Icons.agriculture_rounded,
        ),
      ],
    ),
    'maize': CropLifecycle(
      crop: 'Maize',
      daysToHarvest: 110,
      stages: [
        CropStage(
          name: 'Emergence',
          window: '0-12 days',
          action: 'Protect seedlings and confirm stand.',
          icon: Icons.spa_rounded,
        ),
        CropStage(
          name: 'Vegetative',
          window: '20-55 days',
          action: 'Apply nitrogen and monitor moisture.',
          icon: Icons.grass_rounded,
        ),
        CropStage(
          name: 'Tasseling',
          window: '60-80 days',
          action: 'Avoid water stress during pollination.',
          icon: Icons.eco_rounded,
        ),
        CropStage(
          name: 'Grain Fill',
          window: '80-110 days',
          action: 'Track pests and prepare harvest.',
          icon: Icons.agriculture_rounded,
        ),
      ],
    ),
    'rice': CropLifecycle(
      crop: 'Rice',
      daysToHarvest: 135,
      stages: [
        CropStage(
          name: 'Seedling',
          window: '0-20 days',
          action: 'Keep shallow water and strong nursery growth.',
          icon: Icons.water_drop_rounded,
        ),
        CropStage(
          name: 'Tillering',
          window: '20-55 days',
          action: 'Maintain water depth and nitrogen.',
          icon: Icons.grass_rounded,
        ),
        CropStage(
          name: 'Panicle',
          window: '60-95 days',
          action: 'Watch blast risk and nutrient balance.',
          icon: Icons.eco_rounded,
        ),
        CropStage(
          name: 'Ripening',
          window: '100-135 days',
          action: 'Drain gradually before harvest.',
          icon: Icons.agriculture_rounded,
        ),
      ],
    ),
    'tomato': CropLifecycle(
      crop: 'Tomato',
      daysToHarvest: 95,
      stages: [
        CropStage(
          name: 'Transplant',
          window: '0-14 days',
          action: 'Reduce shock with steady moisture.',
          icon: Icons.spa_rounded,
        ),
        CropStage(
          name: 'Vegetative',
          window: '15-40 days',
          action: 'Prune, stake, and feed evenly.',
          icon: Icons.grass_rounded,
        ),
        CropStage(
          name: 'Flowering',
          window: '40-65 days',
          action: 'Avoid heat and moisture swings.',
          icon: Icons.local_florist_rounded,
        ),
        CropStage(
          name: 'Fruiting',
          window: '65-95 days',
          action: 'Harvest ripe clusters frequently.',
          icon: Icons.agriculture_rounded,
        ),
      ],
    ),
    'potato': CropLifecycle(
      crop: 'Potato',
      daysToHarvest: 100,
      stages: [
        CropStage(
          name: 'Sprouting',
          window: '0-20 days',
          action: 'Keep beds loose and moist.',
          icon: Icons.spa_rounded,
        ),
        CropStage(
          name: 'Canopy Growth',
          window: '20-45 days',
          action: 'Hill soil and monitor blight.',
          icon: Icons.grass_rounded,
        ),
        CropStage(
          name: 'Tuber Bulking',
          window: '45-85 days',
          action: 'Keep moisture consistent.',
          icon: Icons.eco_rounded,
        ),
        CropStage(
          name: 'Maturation',
          window: '85-100 days',
          action: 'Stop irrigation before lifting.',
          icon: Icons.agriculture_rounded,
        ),
      ],
    ),
    'mango': CropLifecycle(
      crop: 'Mango',
      daysToHarvest: 150,
      stages: [
        CropStage(
          name: 'Flush',
          window: '0-35 days',
          action: 'Support new leaves and pest control.',
          icon: Icons.park_rounded,
        ),
        CropStage(
          name: 'Flowering',
          window: '35-70 days',
          action: 'Protect bloom from stress.',
          icon: Icons.local_florist_rounded,
        ),
        CropStage(
          name: 'Fruit Set',
          window: '70-110 days',
          action: 'Thin weak fruit and manage irrigation.',
          icon: Icons.eco_rounded,
        ),
        CropStage(
          name: 'Ripening',
          window: '110-150 days',
          action: 'Harvest by color and firmness.',
          icon: Icons.agriculture_rounded,
        ),
      ],
    ),
    'jowar (sorghum)': CropLifecycle(
      crop: 'Jowar (Sorghum)',
      daysToHarvest: 115,
      stages: [
        CropStage(
          name: 'Emergence',
          window: '0-10 days',
          action: 'Confirm stand and early weeds.',
          icon: Icons.spa_rounded,
        ),
        CropStage(
          name: 'Vegetative',
          window: '20-50 days',
          action: 'Scout shoot fly and moisture stress.',
          icon: Icons.grass_rounded,
        ),
        CropStage(
          name: 'Booting',
          window: '55-80 days',
          action: 'Protect heads and maintain nutrients.',
          icon: Icons.eco_rounded,
        ),
        CropStage(
          name: 'Grain Maturity',
          window: '90-115 days',
          action: 'Harvest when grain hardens.',
          icon: Icons.agriculture_rounded,
        ),
      ],
    ),
    'green fodder': CropLifecycle(
      crop: 'Green Fodder',
      daysToHarvest: 60,
      stages: [
        CropStage(
          name: 'Establishment',
          window: '0-12 days',
          action: 'Keep germination moisture steady.',
          icon: Icons.spa_rounded,
        ),
        CropStage(
          name: 'Leaf Growth',
          window: '12-35 days',
          action: 'Apply nitrogen after establishment.',
          icon: Icons.grass_rounded,
        ),
        CropStage(
          name: 'Canopy',
          window: '35-50 days',
          action: 'Irrigate for fast biomass gain.',
          icon: Icons.eco_rounded,
        ),
        CropStage(
          name: 'Cutting',
          window: '50-60 days',
          action: 'Cut before quality declines.',
          icon: Icons.agriculture_rounded,
        ),
      ],
    ),
  };
}
