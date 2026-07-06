import 'dart:convert';
import 'dart:io';

import 'package:farmtec/core/themes/app_fonts.dart';

import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/services/farm_history_service.dart';
import 'package:farmtec/core/services/plant_disease_vision_service.dart';
import 'package:farmtec/core/services/soil_health_service.dart';
import 'package:farmtec/core/services/yield_prediction_service.dart';
import 'package:farmtec/core/services/crop_lifecycle_service.dart';
import 'package:farmtec/features/dashboard/presentation/utils/market_crop_utils.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/ai_model_background.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/ai_model_definition.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/model_results.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

Map<String, dynamic> _stringKeyedMap(dynamic data) {
  if (data is Map) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

String findClosestCropRotationFarmId(List<String> farmIds, double lat, double lng) {
  var bestId = farmIds.isNotEmpty ? farmIds.first : 'F_28.825_30.775';
  var bestDistance = double.infinity;
  for (final id in farmIds) {
    final parts = id.split('_');
    if (parts.length != 3) continue;
    final candidateLat = double.tryParse(parts[1]);
    final candidateLng = double.tryParse(parts[2]);
    if (candidateLat == null || candidateLng == null) continue;
    final distance = (lat - candidateLat) * (lat - candidateLat) +
        (lng - candidateLng) * (lng - candidateLng);
    if (distance < bestDistance) {
      bestDistance = distance;
      bestId = id;
    }
  }
  return bestId;
}

String formatModelResult({
  required String modelName,
  required dynamic data,
  required AppLocalizations l,
  String Function(num, AppLocalizations)? formatEgp,
}) {
  switch (modelName) {
    case 'Disease Detection':
      final response = data is String ? data : data.toString();
      return l.convertNumbers(
        l.trParams('model_result_disease_detection', {'response': response}),
      );
    case 'Crop Recommendation':
      final c = (data['predicted_crop'] ?? data['prediction'] ?? 'Unknown').toString();
      final crop = c.isNotEmpty ? c[0].toUpperCase() + c.substring(1) : c;
      return l.convertNumbers(
        l.trParams('recommended_crop', {'crop': crop}),
      );
    case 'Crop Rotation':
      final payload = _stringKeyedMap(data);
      if (payload.isNotEmpty) {
        final recommendedCrop = (payload['recommended_crop'] ?? payload['next_crop'] ?? payload['crop'] ?? 'Unknown').toString();
        final cropLabel = recommendedCrop.isNotEmpty
            ? recommendedCrop[0].toUpperCase() + recommendedCrop.substring(1)
            : recommendedCrop;

        final reason = (payload['reason'] ?? payload['recommendation'] ?? payload['explanation'] ?? '').toString();
        final sequence = payload['sequence'];
        final summary = payload['summary'];
        final lines = <String>[
          l.tr('crop_rotation'),
          l.trParams('crop_rotation_recommended_crop', {'crop': cropLabel}),
        ];

        if (reason.isNotEmpty) {
          lines.add(l.trParams('crop_rotation_reason', {'reason': reason}));
        } else if (summary is Map && summary.isNotEmpty) {
          final soilInfo = summary.entries.where((entry) => entry.key.toString().toLowerCase().contains('soil')).toList();
          if (soilInfo.isNotEmpty) {
            lines.add(l.trParams('crop_rotation_reason', {'reason': soilInfo.map((entry) => '${entry.key}: ${entry.value}').join(' • ')}));
          }
        }

        if (sequence is List && sequence.isNotEmpty) {
          final firstStep = sequence.first;
          if (firstStep is Map) {
            final stepCrop = (firstStep['Recommended Crop'] ?? firstStep['crop'] ?? '').toString();
            if (stepCrop.isNotEmpty) {
              lines.add(l.trParams('crop_rotation_plan', {'plan': 'Season 1 → $stepCrop'}));
            }
          }
        }

        return l.convertNumbers(lines.join('\n'));
      }
      return l.convertNumbers('${l.tr('crop_rotation')} $data');
    case 'Yield Prediction':
      final y = data['predicted_yield'] ?? data['yield'] ?? data['prediction'];
      if (y == null) {
        return l.convertNumbers('${l.tr('model_result_yield_prediction')} $data');
      }
      final yieldStr = y is num ? y.toStringAsFixed(2) : y.toString();
      return l.convertNumbers(
        l.trParams('yield_predicted', {
          'yield': yieldStr,
          'unit': (data['unit'] ?? 't/ha').toString(),
        }),
      );
    case 'Irrigation Planner':
      final need = data['irrigation_need_mm_season'] ??
          data['irrigation_need_mm'] ??
          l.tr('model_result_unknown');
      final irrigationClass = data['irrigation_class'] ?? l.tr('model_result_unknown');
      final confidence = data['confidence']?.toString() ?? l.tr('model_result_unknown');
      final reliability = data['reliability_flag']?.toString() ?? l.tr('model_result_unknown');
      final season = data['season']?.toString() ?? l.tr('model_result_unknown');
      return l.convertNumbers(
        [
          l.tr('model_result_irrigation_estimate'),
          l.trParams('model_result_irrigation_need', {'need': '$need'}),
          l.trParams('model_result_irrigation_class', {'class': '$irrigationClass'}),
          l.trParams('model_result_confidence', {'confidence': '$confidence'}),
          l.trParams('model_result_reliability', {'reliability': '$reliability'}),
          l.trParams('model_result_season', {'season': '$season'}),
        ].join('\n'),
      );
    case 'Fertilizer Planner':
      if (data is Map<String, dynamic>) {
        Map<String, dynamic>? payload;
        if (data['data'] is List) {
          payload = (data['data'] as List).whereType<Map<String, dynamic>>().firstWhere(
            (item) => item.containsKey('Selected Fertilizer') || item.containsKey('recommended_fertilizer_amount'),
            orElse: () => <String, dynamic>{},
          );
          if (payload.isEmpty) payload = null;
        } else if (data['data'] is Map<String, dynamic>) {
          payload = data['data'] as Map<String, dynamic>;
        }

        final record = payload ?? data;
        final fertilizerName = record['Selected Fertilizer']?.toString() ??
            record['fertilizer_type']?.toString() ??
            record['fertilizer_name']?.toString() ??
            record['fertilizer']?.toString() ??
            l.tr('model_result_unknown');

        final amount = record['recommended_fertilizer_amount'] ??
            record['amount_kg_ha'] ??
            record['amount'] ??
            record['dose_kg_ha'] ??
            (record['current_application'] is Map<String, dynamic>
                ? record['current_application']['amount_kg_ha']
                : null);

        final recommendation = record['schedule_summary']?.toString() ??
            record['agronomic_explanation']?.toString() ??
            record['recommendation']?.toString() ??
            record['notes']?.toString() ??
            l.tr('model_result_unknown');

        final amountText = amount is num
            ? (amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(1))
            : amount?.toString() ?? l.tr('model_result_unknown');

        return l.convertNumbers(
          [
            l.tr('model_result_fertilizer_title'),
            l.trParams('model_result_fertilizer_name', {'name': fertilizerName}),
            l.trParams('model_result_fertilizer_amount', {'amount': amountText}),
            l.trParams('model_result_fertilizer_recommendation', {'recommendation': recommendation}),
          ].join('\n'),
        );
      }
      return l.convertNumbers('${l.tr('model_result_fertilizer_title')} $data');
    default:
      return data.toString();
  }
}

class AiModelRunScreen extends StatefulWidget {
  final AIModelDefinition model;

  const AiModelRunScreen({super.key, required this.model});

  @override
  State<AiModelRunScreen> createState() => _AiModelRunScreenState();
}

class _AiModelRunScreenState extends State<AiModelRunScreen> {
  late Map<String, TextEditingController> _controllers;
  final _visionService = PlantDiseaseVisionService();
  final _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _loading = false;
  String? _result;
  dynamic _resultData;
  bool _isError = false;

  String _lastScanLabel(AppLocalizations l) {
    final farm = Provider.of<FarmProvider>(context, listen: false).selectedFarm;
    if (farm == null) {
      return l.tr('last_scan');
    }

    final historyService = Provider.of<FarmHistoryService>(context, listen: false);
    final recentEntries = historyService.getForFarm(farm.id);
    final matching = recentEntries.where((op) {
      return op.title == widget.model.name || op.titleKey == _titleKeyForModel(widget.model.name);
    }).toList();

    if (matching.isEmpty) {
      return l.tr('no_scans_yet');
    }

    final latest = matching.first.timestamp;
    final now = DateTime.now();
    final diffInDays = now.difference(latest).inDays;
    final diffInHours = now.difference(latest).inHours;

    if (diffInDays >= 1) {
      return l.trParams('days_ago', {'days': l.convertNumbers(diffInDays.toString())});
    }
    if (diffInHours >= 1) {
      return l.trParams('hours_ago', {'hours': l.convertNumbers(diffInHours.toString())});
    }
    return l.tr('just_now');
  }

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final f in widget.model.fields) f.key: TextEditingController(),
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final yieldService = Provider.of<YieldPredictionService>(context, listen: false);
      final cachedYieldText = yieldService.yieldPerHa.toStringAsFixed(2);
      final farm = Provider.of<FarmProvider>(context, listen: false).selectedFarm;
      if (farm != null) {
        if (farm.lat != 0 && _controllers.containsKey('lat')) {
          _controllers['lat']!.text = farm.lat.toStringAsFixed(4);
        }
        if (farm.lng != 0 && _controllers.containsKey('lon')) {
          _controllers['lon']!.text = farm.lng.toStringAsFixed(4);
        }
        if (_controllers.containsKey('crop') && farm.crop.isNotEmpty) {
          _controllers['crop']!.text = farm.crop;
        }
        if (_controllers.containsKey('current_crop') && farm.crop.isNotEmpty) {
          _controllers['current_crop']!.text = farm.crop;
        }
        if (_controllers.containsKey('soil_health')) {
          final soilHealthService = Provider.of<SoilHealthService>(context, listen: false);
          soilHealthService
              .getScoreForLocation(lat: farm.lat, lng: farm.lng)
              .then((score) {
            if (mounted && score > 0) {
              _controllers['soil_health']!.text = score.toStringAsFixed(1);
            }
          });
        }
        if (_controllers.containsKey('year')) {
          _controllers['year']!.text = DateTime.now().year.toString();
        }
        if (_controllers.containsKey('predicted_yield')) {
          _controllers['predicted_yield']!.text = cachedYieldText;
        }
        if (_controllers.containsKey('soil_nitrogen')) {
          _controllers['soil_nitrogen']!.text = '0.1';
        }
        if (_controllers.containsKey('soil_soc')) {
          _controllers['soil_soc']!.text = '1.5';
        }
        if (_controllers.containsKey('soil_ph')) {
          _controllers['soil_ph']!.text = '7.2';
        }
        if (_controllers.containsKey('fertilizer_type')) {
          _controllers['fertilizer_type']!.text = 'Urea (46% N)';
        }
        if (_controllers.containsKey('plant_date')) {
          if (farm.plantedAt != null) {
            final y = farm.plantedAt!.year.toString().padLeft(4, '0');
            final m = farm.plantedAt!.month.toString().padLeft(2, '0');
            final d = farm.plantedAt!.day.toString().padLeft(2, '0');
            _controllers['plant_date']!.text = '$y-$m-$d';
          } else {
            _controllers['plant_date']!.text = '2025-11-01';
          }
        }
        if (_controllers.containsKey('current_date')) {
          final now = DateTime.now();
          final y = now.year.toString().padLeft(4, '0');
          final m = now.month.toString().padLeft(2, '0');
          final d = now.day.toString().padLeft(2, '0');
          _controllers['current_date']!.text = '$y-$m-$d';
        }
      } else {
        if (_controllers.containsKey('predicted_yield')) {
          _controllers['predicted_yield']!.text = cachedYieldText;
        }
        if (_controllers.containsKey('soil_nitrogen')) {
          _controllers['soil_nitrogen']!.text = '0.1';
        }
        if (_controllers.containsKey('soil_soc')) {
          _controllers['soil_soc']!.text = '1.5';
        }
        if (_controllers.containsKey('soil_ph')) {
          _controllers['soil_ph']!.text = '7.2';
        }
        if (_controllers.containsKey('fertilizer_type')) {
          _controllers['fertilizer_type']!.text = 'Urea (46% N)';
        }
        if (_controllers.containsKey('plant_date')) {
          _controllers['plant_date']!.text = '2025-11-01';
        }
        if (_controllers.containsKey('current_date')) {
          final now = DateTime.now();
          final y = now.year.toString().padLeft(4, '0');
          final m = now.month.toString().padLeft(2, '0');
          final d = now.day.toString().padLeft(2, '0');
          _controllers['current_date']!.text = '$y-$m-$d';
        }
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _visionService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (image == null) return;
    if (!mounted) return;
    setState(() => _selectedImage = image);
  }

  Future<void> _runPrediction() async {
    final l = AppLocalizations.of(context);
    if (widget.model.isVisionModel && _selectedImage == null) {
      setState(() {
        _isError = true;
        _result = l.tr('photo_required');
      });
      return;
    }

    setState(() {
      _loading = true;
      _result = null;
      _isError = false;
    });
    try {
      if (widget.model.isVisionModel) {
        final bytes = await _selectedImage!.readAsBytes();
        final prompt = _controllers['prompt']?.text ?? '';
        final analysis = await _visionService.analyze(
          imageBytes: bytes,
          prompt: prompt,
        );
        if (!mounted) return;
        _result = analysis;
        await _persistResult(analysis);
      } else {
        await _runStandardPrediction(l);
      }
    } catch (_) {
      if (!mounted) return;
      _isError = true;
      _result = l.tr('connection_error');
    }
    if (mounted) setState(() => _loading = false);
  }

  String _formatEgp(num rawValue, AppLocalizations l) {
    final formatted = l.convertNumbers(rawValue.toStringAsFixed(2));
    return l.isArabic
        ? 'ج.م$formatted${l.tr('per_ton')}'
        : 'EGP $formatted${l.tr('per_ton')}';
  }

  Future<double> _resolveSoilHealthScore(Farm? farm) async {
    final soilHealthService = Provider.of<SoilHealthService>(context, listen: false);
    if (farm != null && farm.lat != 0 && farm.lng != 0) {
      final score = await soilHealthService.getScoreForLocation(lat: farm.lat, lng: farm.lng);
      if (score > 0) {
        return score;
      }
    }
    return 70.0;
  }

  Future<String> _resolveCropRotationFarmId(Farm? farm) async {
    final apiUri = Uri.parse(widget.model.apiUrl);
    final farmIdsUri = apiUri.replace(path: '/farm_ids', queryParameters: null);
    try {
      final response = await http
          .get(farmIdsUri)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          final raw = decoded['farm_ids'];
          if (raw is List) {
            final validIds = raw.whereType<String>().toList();
            if (validIds.isNotEmpty) {
              if (farm != null && farm.lat != 0 && farm.lng != 0) {
                return findClosestCropRotationFarmId(validIds, farm.lat, farm.lng);
              }
              return validIds.first;
            }
          }
        }
      }
    } catch (_) {}

    if (farm != null) {
      return 'F_${farm.lat.toStringAsFixed(3)}_${farm.lng.toStringAsFixed(3)}';
    }
    return 'F_28.825_30.775';
  }

  Future<void> _runStandardPrediction(AppLocalizations l) async {
    http.Response response;
    if (widget.model.name == 'Market Forecast') {
      final selectedCrop = _controllers['crop']?.text.trim() ?? '';
      response = await http
          .get(Uri.parse(widget.model.apiUrl))
          .timeout(const Duration(seconds: 30));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is List) {
          final filtered = selectedCrop.isNotEmpty
              ? decoded.where((item) {
                  final commodity = '${item['commodity'] ?? ''}';
                  return MarketCropUtils.matchesCommodity(commodity, selectedCrop);
                }).toList()
              : decoded;
          _result = formatModelResult(
            modelName: widget.model.name,
            data: filtered,
            l: l,
            formatEgp: (value, localization) => _formatEgp(value, localization),
          );
          if (mounted) await _persistResult(filtered);
          return;
        }
        _isError = true;
        _result = l.tr('connection_error');
        return;
      }
      _isError = true;
      _result = l.trParams(
        'api_error',
        {'code': response.statusCode.toString()},
      );
      return;
    } else if (widget.model.name == 'Crop Rotation') {
      final farm = Provider.of<FarmProvider>(context, listen: false).selectedFarm;
      final currentCrop = _controllers['current_crop']?.text.trim().isNotEmpty == true
          ? _controllers['current_crop']!.text.trim()
          : (farm?.crop ?? 'wheat');
      final requestedSoilHealth = _controllers['soil_health']?.text.trim().isNotEmpty == true
          ? double.tryParse(_controllers['soil_health']!.text.trim())
          : null;
      final yearValue = _controllers['year']?.text.trim().isNotEmpty == true
          ? int.tryParse(_controllers['year']!.text.trim()) ?? DateTime.now().year
          : DateTime.now().year;

      final soilHealthValue = requestedSoilHealth ?? await _resolveSoilHealthScore(farm);
      final farmId = await _resolveCropRotationFarmId(farm);

      final uri = Uri.parse(widget.model.apiUrl).replace(queryParameters: {
        'farm_id': farmId,
        'current_crop': currentCrop,
        'soil_health': soilHealthValue.toStringAsFixed(1),
        'year': yearValue.toString(),
      });

      response = await http
          .get(uri)
          .timeout(const Duration(seconds: 30));
    } else if (widget.model.name == 'Irrigation Planner') {
      final body = <String, dynamic>{};
      for (final f in widget.model.fields) {
        final val = _controllers[f.key]!.text.isNotEmpty
            ? _controllers[f.key]!.text
            : f.hint;
        body[f.key] = double.tryParse(val) ?? val;
      }
      response = await http
          .post(
            Uri.parse(widget.model.apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } else if (widget.model.name == 'Fertilizer Planner') {
      final farm = Provider.of<FarmProvider>(context, listen: false).selectedFarm;
      final cropVal = _controllers['crop']!.text.isNotEmpty
          ? _controllers['crop']!.text.toLowerCase()
          : (farm?.crop.toLowerCase() ?? 'wheat');
      final predictedYield = double.tryParse(_controllers['predicted_yield']!.text) ?? 4.5;
      final soilNitrogen = double.tryParse(_controllers['soil_nitrogen']!.text) ?? 0.1;
      final soilSoc = double.tryParse(_controllers['soil_soc']!.text) ?? 1.5;
      final soilPh = double.tryParse(_controllers['soil_ph']!.text) ?? 7.2;
      final fertilizerType = _controllers['fertilizer_type']!.text.isNotEmpty
          ? _controllers['fertilizer_type']!.text
          : 'Urea (46% N)';
      final plantDate = _controllers['plant_date']!.text.isNotEmpty
          ? _controllers['plant_date']!.text
          : '2025-11-01';
      final currentDate = _controllers['current_date']!.text.isNotEmpty
          ? _controllers['current_date']!.text
          : '2025-12-10';

      final lat = farm?.lat != 0 ? farm!.lat : 30.0;
      final lon = farm?.lng != 0 ? farm!.lng : 31.0;
      final harvestedArea = double.tryParse(farm?.area ?? '5.0') ?? 5.0;

      final dataList = [
        "F-001", // field_id
        lat,     // lat
        lon,     // lon
        cropVal, // crop
        DateTime.now().year, // year
        harvestedArea, // harvested area
        predictedYield, // predicted_yield
        soilNitrogen, // s_n
        soilSoc,     // s_soc
        soilPh,      // s_ph
        18.0,        // s_cec
        35.0,        // s_clay
        0.25,        // s_moist
        0.6,         // s_fi
        0.5,         // wb
        0.7,         // wa
        0.2,         // hs
        "Basic",     // sat_mode
        0.3,         // season_ndre
        0.5,         // season_ndvi
        0.2,         // season_evi
        // ndre m01-m12
        0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3,
        // ndvi m01-m12
        0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
        // evi m01-m12
        0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2,
        fertilizerType,
        plantDate,
        currentDate,
      ];

      final body = {
        "fn_index": 1,
        "data": dataList,
      };

      response = await http
          .post(
            Uri.parse(widget.model.apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } else {
      final body = <String, dynamic>{};
      for (final f in widget.model.fields) {
        final val = _controllers[f.key]!.text.isNotEmpty
            ? _controllers[f.key]!.text
            : f.hint;
        if (f.key == 'year') {
          body[f.key] = int.tryParse(val) ?? val;
        } else if (f.type == TextInputType.number ||
            f.type ==
                const TextInputType.numberWithOptions(decimal: true)) {
          body[f.key] = double.tryParse(val) ?? val;
        } else {
          body[f.key] = val;
        }
      }
      response = await http
          .post(
            Uri.parse(widget.model.apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    }
    if (!mounted) return;
    if (response.statusCode == 200) {
      dynamic decoded;
      try {
        decoded = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        _isError = true;
        _result = l.tr('connection_error');
        return;
      }
      _resultData = decoded;
      _result = formatModelResult(
        modelName: widget.model.name,
        data: decoded,
        l: l,
        formatEgp: (value, localization) => _formatEgp(value, localization),
      );
      if (mounted) await _persistResult(decoded);
    } else {
      _isError = true;
      _result = l.trParams(
        'api_error',
        {'code': response.statusCode.toString()},
      );
    }
  }

  String _localizedFieldLabel(AppLocalizations l, AIModelFieldDefinition field) {
    return l.trOr('field_${field.key}', field.label == 'Latitude'
        ? l.tr('latitude')
        : field.label == 'Longitude'
            ? l.tr('longitude')
            : field.label == 'Year'
                ? l.tr('year')
                : field.label == 'Crop'
                    ? l.tr('crop_type')
                    : field.label);
  }

  String _localizedFieldHint(AppLocalizations l, AIModelFieldDefinition field) {
    return l.trOr('hint_${field.key}', field.hint);
  }

  String? _titleKeyForModel(String name) {
    switch (name) {
      case 'Disease Detection':
        return 'op_ai_disease_detection';
      case 'Crop Recommendation':
        return 'op_ai_crop_recommendation';
      case 'Yield Prediction':
        return 'op_ai_yield_prediction';
      case 'Irrigation Planner':
        return 'op_ai_irrigation_planner';
      case 'Market Forecast':
        return 'op_ai_market_forecast';
      case 'Soil Health':
        return 'op_ai_soil_health';
      default:
        return null;
    }
  }

  OperationType _typeForModel(String name) {
    switch (name) {
      case 'Disease Detection':
        return OperationType.diseaseScan;
      case 'Irrigation Planner':
        return OperationType.irrigation;
      case 'Crop Recommendation':
        return OperationType.cropPlant;
      case 'Soil Health':
        return OperationType.aiModelRun;
      default:
        return OperationType.aiModelRun;
    }
  }

  Future<void> _persistResult(dynamic decoded) async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    final yieldService = Provider.of<YieldPredictionService>(context, listen: false);
    final historyService = Provider.of<FarmHistoryService>(context, listen: false);
    final farm = farmProvider.selectedFarm;
    final summary = _result ?? decoded.toString();

    if (farm != null) {
      await historyService.addOperation(
        FarmOperation(
          id: 'op_${DateTime.now().microsecondsSinceEpoch}',
          farmId: farm.id,
          type: _typeForModel(widget.model.name),
          title: widget.model.name,
          titleKey: _titleKeyForModel(widget.model.name),
          description: summary,
          timestamp: DateTime.now(),
        ),
      );
    }

    if (widget.model.name == 'Yield Prediction' && decoded is Map) {
      final y = decoded['predicted_yield'] ?? decoded['yield'] ?? decoded['prediction'];
      if (y != null) {
        final yieldVal = y is num ? y.toDouble() : double.tryParse(y.toString());
        if (yieldVal != null) {
          final crop =
              _controllers['crop']?.text.trim().isNotEmpty == true
                  ? _controllers['crop']!.text.trim()
                  : (farm?.crop ?? 'Wheat');
          await yieldService.updatePrediction(
            yieldPerHa: yieldVal,
            crop: crop,
            field: farm?.name ?? crop,
            unit: (decoded['unit'] ?? 't/ha').toString(),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final bgColor = colors.background;
    final textColor = colors.textPrimary;
    final subColor = colors.textSecondary;
    final fillColor = colors.surfaceVariant;
    final cardColor = colors.card;
    final descKey =
        '${widget.model.name.toLowerCase().replaceAll(' ', '_')}_desc';
    final desc = l.tr(descKey);
    final stats = {
      l.tr('last_scan'): _lastScanLabel(l),
    };
    const accentGreen = Pallete.aiModelGreen;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: bgColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: AiModelBackground(
                imageAsset: widget.model.backgroundImage,
                gradientColors: [
                  Colors.black.withAlpha(70),
                  Colors.black.withAlpha(140),
                  bgColor,
                ],
                gradientStops: const [0.0, 0.6, 1.0],
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(35),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withAlpha(50),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(80),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.model.icon,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l.tr(
                          widget.model.name.toLowerCase().replaceAll(' ', '_'),
                        ),
                        style: AppFonts.font(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (widget.model.isVisionModel)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l.tr('vision_model_badge'),
                            style: AppFonts.font(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 25 : 8),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: stats.entries
                          .map(
                            (e) => Column(
                              children: [
                                Text(
                                  e.value,
                                  style: AppFonts.font(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: accentGreen,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  e.key,
                                  style: AppFonts.font(
                                    fontSize: 11,
                                    color: subColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.tr('about'),
                    style: AppFonts.font(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: AppFonts.font(
                      fontSize: 13,
                      color: subColor,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.model.isVisionModel) ...[
                    Text(
                      l.tr('upload_plant_photo'),
                      style: AppFonts.font(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildVisionPhotoPicker(
                      l: l,
                      isDark: isDark,
                      textColor: textColor,
                      subColor: subColor,
                      fillColor: fillColor,
                      colors: colors,
                      accentGreen: accentGreen,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.tr('optional_question'),
                      style: AppFonts.font(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _controllers['prompt'],
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      minLines: 3,
                      style: AppFonts.font(fontSize: 14, color: textColor),
                      decoration: InputDecoration(
                        hintText: l.tr('plant_question_hint'),
                        hintStyle: AppFonts.font(
                          fontSize: 13,
                          color: colors.textHint,
                        ),
                        filled: true,
                        fillColor: fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: accentGreen,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ] else if (widget.model.fields.isNotEmpty) ...[
                    Text(
                      l.tr('input_parameters'),
                      style: AppFonts.font(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.tr('auto_filled_gps'),
                      style: AppFonts.font(fontSize: 12, color: subColor),
                    ),
                    const SizedBox(height: 14),
                    ...widget.model.fields.map(
                      (f) {
                        if (widget.model.name == 'Market Forecast' && f.key == 'crop') {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DropdownButtonFormField<String>(
                              initialValue: _controllers[f.key]!.text.isNotEmpty
                                  ? _controllers[f.key]!.text
                                  : null,
                              items: CropLifecycleService.availableCrops
                                  .map(
                                    (crop) => DropdownMenuItem(
                                      value: crop,
                                      child: Text(
                                        l.tr(CropLifecycleService.cropL10nKey(crop)),
                                        style: AppFonts.font(fontSize: 14),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _controllers[f.key]!.text = value;
                                  });
                                }
                              },

                              decoration: InputDecoration(
                                labelText: _localizedFieldLabel(l, f),
                                labelStyle: AppFonts.font(
                                  fontSize: 13,
                                  color: subColor,
                                ),
                                filled: true,
                                fillColor: fillColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: accentGreen,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          );
                        }
                        
                        // Handle dropdown fields
                        if (f.options != null && f.options!.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DropdownButtonFormField<String>(
                              initialValue: _controllers[f.key]!.text.isNotEmpty
                                  ? _controllers[f.key]!.text
                                  : null,
                              items: f.options!
                                  .map(
                                    (option) => DropdownMenuItem(
                                      value: option,
                                      child: Text(
                                        option,
                                        style: AppFonts.font(fontSize: 14),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _controllers[f.key]!.text = value;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                labelText: _localizedFieldLabel(l, f),
                                labelStyle: AppFonts.font(
                                  fontSize: 13,
                                  color: subColor,
                                ),
                                filled: true,
                                fillColor: fillColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: accentGreen,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          );
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextField(
                            controller: _controllers[f.key],
                            keyboardType: f.type,
                            style: AppFonts.font(
                              fontSize: 14,
                              color: textColor,
                            ),
                            decoration: InputDecoration(
                              labelText: _localizedFieldLabel(l, f),
                              hintText: _localizedFieldHint(l, f),
                              labelStyle: AppFonts.font(
                                fontSize: 13,
                                color: subColor,
                              ),
                              hintStyle: AppFonts.font(
                                fontSize: 13,
                                color: colors.textHint,
                              ),
                              filled: true,
                              fillColor: fillColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: accentGreen,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: accentGreen.withAlpha(100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      icon: _loading
                          ? const SizedBox.shrink()
                          : Icon(
                              widget.model.isVisionModel
                                  ? Icons.biotech_rounded
                                  : Icons.play_arrow_rounded,
                              size: 22,
                            ),
                      onPressed: _loading ? null : _runPrediction,
                      label: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              widget.model.isVisionModel
                                  ? l.tr('analyze_plant')
                                  : l.tr('run_prediction'),
                              style: AppFonts.font(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  if (_result != null) ...[
                    const SizedBox(height: 24),
                    _buildModelResultCard(
                      l: l,
                      cardColor: cardColor,
                      textColor: textColor,
                      accentGreen: accentGreen,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultLine(
    String line, {
    required Color bulletColor,
    required Color textColor,
  }) {
    final colonIndex = line.indexOf(':');
    final hasLabel = colonIndex > 0;
    final label = hasLabel ? line.substring(0, colonIndex + 1) : '';
    final value = hasLabel ? line.substring(colonIndex + 1).trim() : line;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: bulletColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: hasLabel
              ? Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$label ',
                        style: AppFonts.font(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      TextSpan(
                        text: value,
                        style: AppFonts.font(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: textColor,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  value,
                  style: AppFonts.font(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                    height: 1.6,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildModelResultCard({
    required AppLocalizations l,
    required Color cardColor,
    required Color textColor,
    required Color accentGreen,
  }) {
    if (_isError) {
      return _buildResultCardShell(
        cardColor: cardColor,
        textColor: textColor,
        accentGreen: accentGreen,
        title: l.tr('error'),
        children: [
          _buildResultText(_result ?? l.tr('connection_error'), textColor, accentGreen),
        ],
      );
    }

    if (_resultData != null) {
      switch (widget.model.name) {
        case 'Disease Detection':
          return DiseaseDetectionResultsCard(
            data: _resultData,
            l: l,
            cardColor: cardColor,
            textColor: textColor,
            accentGreen: accentGreen,
          );
        case 'Crop Recommendation':
          return CropRecommendationResultsCard(
            data: _resultData,
            l: l,
            cardColor: cardColor,
            textColor: textColor,
            accentGreen: accentGreen,
          );
        case 'Crop Rotation':
          return CropRotationResultsCard(
            data: _resultData,
            l: l,
            cardColor: cardColor,
            textColor: textColor,
            accentGreen: accentGreen,
          );
        case 'Yield Prediction':
          return YieldPredictionResultsCard(
            data: _resultData,
            l: l,
            cardColor: cardColor,
            textColor: textColor,
            accentGreen: accentGreen,
          );
        case 'Irrigation Planner':
          return IrrigationPlannerResultsCard(
            data: _resultData,
            l: l,
            cardColor: cardColor,
            textColor: textColor,
            accentGreen: accentGreen,
          );
        case 'Market Forecast':
          return MarketForecastResultsCard(
            data: _resultData,
            l: l,
            cardColor: cardColor,
            textColor: textColor,
            accentGreen: accentGreen,
          );
        case 'Soil Health':
          return SoilHealthResultsCard(
            data: _resultData,
            l: l,
            cardColor: cardColor,
            textColor: textColor,
            accentGreen: accentGreen,
          );
        case 'Fertilizer Planner':
          return FertilizerPlannerResultsCard(
            data: _resultData,
            l: l,
            cardColor: cardColor,
            textColor: textColor,
            accentGreen: accentGreen,
          );
        default:
          break;
      }
    }

    return _buildResultCardShell(
      cardColor: cardColor,
      textColor: textColor,
      accentGreen: accentGreen,
      title: l.tr('prediction_results'),
      children: [
        _buildResultText(_result ?? '', textColor, accentGreen),
      ],
    );
  }

  Widget _buildResultCardShell({
    required Color cardColor,
    required Color textColor,
    required Color accentGreen,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentGreen.withAlpha(60),
        ),
        boxShadow: [
          BoxShadow(
            color: accentGreen.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: accentGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppFonts.font(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _buildResultText(String text, Color textColor, Color bulletColor) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildResultLine(
                line,
                bulletColor: bulletColor,
                textColor: textColor,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildVisionPhotoPicker({
    required AppLocalizations l,
    required bool isDark,
    required Color textColor,
    required Color subColor,
    required Color fillColor,
    required AppThemeColors colors,
    required Color accentGreen,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _selectedImage == null
                  ? colors.outline.withAlpha(isDark ? 80 : 120)
                  : accentGreen.withAlpha(120),
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _selectedImage == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 42,
                      color: subColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.tr('tap_to_add_photo'),
                      style: AppFonts.font(fontSize: 13, color: subColor),
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withAlpha(140),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => setState(() => _selectedImage = null),
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: Text(l.tr('take_photo')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  side: BorderSide(color: colors.outline.withAlpha(120)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: Text(l.tr('choose_from_gallery')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  side: BorderSide(color: colors.outline.withAlpha(120)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
