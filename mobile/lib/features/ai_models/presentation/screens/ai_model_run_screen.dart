import 'dart:io';

import 'package:farmtec/core/themes/app_fonts.dart';

import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/services/farm_history_service.dart';
import 'package:farmtec/core/exceptions/api_exception.dart';
import 'package:farmtec/core/services/api_client.dart';
import 'package:farmtec/core/services/yield_prediction_service.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/ai_model_background.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/ai_model_definition.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AiModelRunScreen extends StatefulWidget {
  final AIModelDefinition model;

  const AiModelRunScreen({super.key, required this.model});

  @override
  State<AiModelRunScreen> createState() => _AiModelRunScreenState();
}

class _AiModelRunScreenState extends State<AiModelRunScreen> {
  late Map<String, TextEditingController> _controllers;
  final _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _loading = false;
  String? _result;
  bool _isError = false;

  static const _statValues = {
    'Disease Detection': {'accuracy': '91%', 'speed': '3.5s', 'runs': '1.8K'},
    'Crop Recommendation': {'accuracy': '94%', 'speed': '1.2s', 'runs': '2.4K'},
    'Yield Prediction': {'accuracy': '92%', 'speed': '1.5s', 'runs': '5.6K'},
    'Irrigation Planner': {'accuracy': '93%', 'speed': '1.8s', 'runs': '3.2K'},
    'Market Forecast': {'accuracy': '89%', 'speed': '0.6s', 'runs': '12K'},
  };

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final f in widget.model.fields) f.key: TextEditingController(),
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        if (_controllers.containsKey('year')) {
          _controllers['year']!.text = DateTime.now().year.toString();
        }
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _runPrediction() async {
    if (widget.model.isVisionModel && _selectedImage == null) {
      setState(() {
        _isError = true;
        _result = AppLocalizations.of(context).tr('photo_required');
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
        await _runVisionPrediction();
      } else {
        await _runStandardPrediction();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      _isError = true;
      _result = e.message;
    } catch (_) {
      if (!mounted) return;
      _isError = true;
      _result = AppLocalizations.of(context).tr('connection_error');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _runVisionPrediction() async {
    final bytes = await _selectedImage!.readAsBytes();
    final api = context.read<ApiClient>();
    final response = await api.postMultipart(
      widget.model.apiUrl,
      fileField: 'image',
      fileBytes: bytes,
      filename: 'crop.jpg',
    );
    if (!mounted) return;
    final payload = _extractPayload(response);
    _result = _fmt(payload, AppLocalizations.of(context));
    await _persistResult(payload);
  }

  Future<void> _runStandardPrediction() async {
    final api = context.read<ApiClient>();
    dynamic payload;

    if (widget.model.httpMethod == 'GET') {
      final response = await api.get(widget.model.apiUrl);
      payload = _extractPayload(response);
    } else {
      final body = <String, dynamic>{};
      for (final f in widget.model.fields) {
        final val = _controllers[f.key]!.text.isNotEmpty
            ? _controllers[f.key]!.text
            : f.hint;
        if (f.key == 'year') {
          body[f.key] = int.tryParse(val) ?? val;
        } else if (f.type == TextInputType.number ||
            f.type == const TextInputType.numberWithOptions(decimal: true)) {
          body[f.key] = double.tryParse(val) ?? val;
        } else {
          body[f.key] = val;
        }
      }
      final response = await api.postRaw(
        widget.model.apiUrl,
        body: {'data': body, 'save': true},
      );
      payload = _extractPayload(response);
    }

    if (!mounted) return;
    _result = _fmt(payload, AppLocalizations.of(context));
    await _persistResult(payload);
  }

  dynamic _extractPayload(Map<String, dynamic> envelope) {
    final data = envelope['data'];
    if (data is Map && data.containsKey('result')) {
      return data['result'];
    }
    return data;
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
      default:
        return OperationType.aiModelRun;
    }
  }

  Future<void> _persistResult(dynamic decoded) async {
    final farm = Provider.of<FarmProvider>(context, listen: false).selectedFarm;
    final summary = _result ?? decoded.toString();

    if (farm != null) {
      await Provider.of<FarmHistoryService>(context, listen: false).addOperation(
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
          await Provider.of<YieldPredictionService>(
            context,
            listen: false,
          ).updatePrediction(
            yieldPerHa: yieldVal,
            crop: crop,
            field: farm?.name ?? crop,
            unit: (decoded['unit'] ?? 't/ha').toString(),
          );
        }
      }
    }
  }

  String _fmt(dynamic d, AppLocalizations l) {
    switch (widget.model.name) {
      case 'Disease Detection':
        if (d is Map) {
          final prediction = d['prediction'] ?? 'Unknown';
          final confidence = d['confidence'];
          return l.convertNumbers(
            'Prediction: $prediction (${confidence ?? 'N/A'}%)',
          );
        }
        return d is String ? d : d.toString();
      case 'Crop Recommendation':
        final c =
            (d['predicted_crop'] ?? d['prediction'] ?? 'Unknown').toString();
        final crop =
            c.isNotEmpty ? c[0].toUpperCase() + c.substring(1) : c;
        return l.convertNumbers(
          l.trParams('recommended_crop', {'crop': crop}),
        );
      case 'Yield Prediction':
        final y = d['predicted_yield'] ?? d['yield'] ?? d['prediction'];
        if (y == null) return '📊 $d';
        final yieldStr = y is num ? y.toStringAsFixed(2) : y.toString();
        return l.convertNumbers(
          l.trParams('yield_predicted', {
            'yield': yieldStr,
            'unit': (d['unit'] ?? 't/ha').toString(),
          }),
        );
      case 'Irrigation Planner':
        return l.convertNumbers(
          l.trParams('irrigation_need', {
            'need': '${d['irrigation_need_mm'] ?? 'N/A'}',
            'class': '${d['irrigation_class'] ?? 'N/A'}',
          }),
        );
      case 'Market Forecast':
        if (d is Map && d['commodities'] is List) {
          final items = (d['commodities'] as List).take(8).join(', ');
          return l.convertNumbers('Available commodities:\n$items');
        }
        if (d is List && d.isNotEmpty) {
          return l.convertNumbers(
            '📈 Forecast:\n${d.take(5).map((e) => '  • ${e['commodity']}: \$${(e['price'] as num).toStringAsFixed(2)}${l.tr('per_ton')}').join('\n')}',
          );
        }
        return '📈 $d';
      default:
        return d.toString();
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
    final statValues = _statValues[widget.model.name] ??
        {'accuracy': '90%', 'speed': '1s', 'runs': '1K'};
    final stats = {
      l.tr('stat_accuracy'): l.convertNumbers(statValues['accuracy']!),
      l.tr('stat_speed'): l.convertNumbers(statValues['speed']!),
      l.tr('stat_runs'): l.convertNumbers(statValues['runs']!),
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
                          widget.model.isVisionModel
                              ? l.tr('vision_model_badge')
                              : 'FarmBrain ML · HuggingFace',
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
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: _controllers[f.key],
                          keyboardType: f.type,
                          style: AppFonts.font(
                            fontSize: 14,
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            labelText: f.label == 'Latitude'
                                ? l.tr('latitude')
                                : f.label == 'Longitude'
                                    ? l.tr('longitude')
                                    : f.label == 'Year'
                                        ? l.tr('year')
                                        : f.label == 'Crop'
                                            ? l.tr('crop_type')
                                            : f.label,
                            hintText: f.hint,
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
                      ),
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isError
                              ? Pallete.error.withAlpha(60)
                              : accentGreen.withAlpha(60),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isError
                                    ? Pallete.error
                                    : accentGreen)
                                .withAlpha(15),
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
                                _isError
                                    ? Icons.warning_amber_rounded
                                    : Icons.insights_rounded,
                                color: _isError
                                    ? Pallete.error
                                    : accentGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isError ? l.tr('error') : l.tr('prediction_results'),
                                style: AppFonts.font(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _result!,
                            style: AppFonts.font(
                              fontSize: 13,
                              color: textColor,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
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
