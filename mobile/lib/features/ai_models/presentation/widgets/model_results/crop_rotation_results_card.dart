import 'package:flutter/material.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/ai_model_result_card_shell.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/model_results_helpers.dart';

class CropRotationResultsCard extends StatelessWidget {
  final dynamic data;
  final AppLocalizations l;
  final Color cardColor;
  final Color textColor;
  final Color accentGreen;

  const CropRotationResultsCard({
    super.key,
    required this.data,
    required this.l,
    required this.cardColor,
    required this.textColor,
    required this.accentGreen,
  });

  @override
  Widget build(BuildContext context) {
    final payload = stringKeyedMap(data);
    final recommendedCrop = (payload['recommended_crop'] ?? payload['next_crop'] ?? payload['crop'] ?? l.tr('model_result_unknown')).toString();
    final cropLabel = recommendedCrop.isNotEmpty
        ? '${recommendedCrop[0].toUpperCase()}${recommendedCrop.substring(1)}'
        : recommendedCrop;
    final planData = payload['rotation_plan'] ?? payload['plan'] ?? payload['sequence'] ?? payload['plan_data'] ?? payload['table'];
    final exactResult = _extractMetric(payload, ['exact_result', 'exact', 'result', 'output', 'answer', 'response']);
    final reason = _extractMetric(payload, ['reason', 'explanation', 'recommendation', 'justification', 'rationale']);

    final rows = _extractPlanRows(planData);
    final rowHasContent = rows.any((row) => row.values.any((value) => value.trim().isNotEmpty && value.trim() != '-'));
    final fallbackPlanText = !rowHasContent ? _formatPlanFallback(planData) : '';
    
    // Extract metrics while excluding plan/table data to avoid picking up crop names
    final payloadForMetrics = Map<String, dynamic>.from(payload);
    payloadForMetrics.remove('rotation_plan');
    payloadForMetrics.remove('plan');
    payloadForMetrics.remove('sequence');
    payloadForMetrics.remove('plan_data');
    payloadForMetrics.remove('table');
    
    final totalProfit = _extractMetric(payloadForMetrics, ['total_est_profit', 'total_profit', 'estimated_profit', 'est_profit', 'profit']);

    return AiModelResultCardShell(
      cardColor: cardColor,
      textColor: textColor,
      accentGreen: accentGreen,
      topAccentColor: accentGreen,
      icon: Icons.rotate_left,
      iconColor: accentGreen,
      backgroundGradient: null,
      borderColor: accentGreen.withOpacity(0.16),
      title: l.tr('crop_rotation'),
      children: [
        _buildHeader(cropLabel, l.tr('model_result_field_recommended_crop'), cardColor, textColor, accentGreen, cropLabel),
        if (exactResult.isNotEmpty || reason.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDetailSection(
            exactResult: exactResult,
            reason: reason,
            cardColor: cardColor,
            textColor: textColor,
            accentColor: accentGreen,
            l: l,
          ),
        ],
        const SizedBox(height: 18),
        Text(
          l.tr('model_result_section_rotation_plan'),
          style: AppFonts.font(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: accentGreen.withOpacity(0.95),
          ),
        ),
        const SizedBox(height: 12),
        rows.isNotEmpty
            ? _buildPlanTable(rows, cardColor, textColor, accentGreen)
            : fallbackPlanText.isNotEmpty
                ? _buildPlanText(fallbackPlanText, cardColor, textColor, accentGreen)
                : _buildPlanText(l.tr('model_result_no_rotation_plan'), cardColor, textColor, accentGreen),
        const SizedBox(height: 20),
        Text(
          l.tr('model_result_section_planning_summary'),
          style: AppFonts.font(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: accentGreen.withOpacity(0.95),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildMetricBox(
              title: l.tr('model_result_field_total_profit'),
              value: totalProfit.isNotEmpty ? totalProfit : l.tr('model_result_unknown'),
              accentColor: accentGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(String cropLabel, String subtitle, Color cardColor, Color textColor, Color accentColor, String cropValue) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withOpacity(0.16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.eco,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: AppFonts.font(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor.withOpacity(0.82),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cropValue,
                  style: AppFonts.font(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanTable(List<Map<String, String>> rows, Color cardColor, Color textColor, Color accentColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withOpacity(0.16)),
      ),
      padding: const EdgeInsets.all(14),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(1.0),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.0),
          3: FlexColumnWidth(1.0),
          4: FlexColumnWidth(1.0),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: accentColor.withOpacity(0.08)),
            children: [
              _buildTableCell(l.tr('model_result_field_season'), textColor, true),
              _buildTableCell(l.tr('model_result_field_crop'), textColor, true),
              _buildTableCell(l.tr('model_result_field_total_profit'), textColor, true),
              _buildTableCell(l.tr('model_result_field_water'), textColor, true),
              _buildTableCell(l.tr('model_result_field_fertilizer'), textColor, true),
            ],
          ),
          ...rows.map((row) => TableRow(
                decoration: BoxDecoration(color: cardColor.withOpacity(0.04)),
                children: [
                  _buildTableCell(row['season'] ?? '-', textColor, false),
                  _buildTableCell(row['crop'] ?? '-', textColor, false),
                  _buildTableCell(row['profit'] ?? '-', textColor, false),
                  _buildTableCell(row['water'] ?? '-', textColor, false),
                  _buildTableCell(row['fertilizer'] ?? '-', textColor, false),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, Color textColor, bool isHeader) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Text(
        text,
        style: AppFonts.font(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          color: textColor.withOpacity(isHeader ? 0.95 : 0.82),
        ),
      ),
    );
  }

  Widget _buildPlanText(String text, Color cardColor, Color textColor, Color accentColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withOpacity(0.16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: AppFonts.font(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor.withOpacity(0.85),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String exactResult,
    required String reason,
    required Color cardColor,
    required Color textColor,
    required Color accentColor,
    required AppLocalizations l,
  }) {
    final fields = <Widget>[];
    if (exactResult.isNotEmpty) {
      fields.add(AiModelResultField(
        label: l.tr('model_result_field_exact_result'),
        value: exactResult,
        bulletColor: accentColor,
        textColor: textColor,
      ));
    }
    if (reason.isNotEmpty) {
      if (fields.isNotEmpty) fields.add(const SizedBox(height: 12));
      fields.add(AiModelResultField(
        label: l.tr('model_result_field_reason'),
        value: reason,
        bulletColor: accentColor,
        textColor: textColor,
      ));
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withOpacity(0.16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields,
      ),
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String value,
    required Color accentColor,
  }) {
    return SizedBox(
      width: 172,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111A27),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.16)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppFonts.font(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.74),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppFonts.font(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractMetric(Map<String, dynamic> payload, List<String> keys) {
    final value = _findMetricValue(payload, keys);
    if (value != null && value.toString().trim().isNotEmpty) {
      final stringValue = value.toString().trim();
      // Don't return if it's just a unit symbol
      if (!['%', 'mm', 'cm', 'kg', 'g', 'l', 'ml', 'ton', 'ha'].contains(stringValue.toLowerCase())) {
        return stringValue;
      }
    }
    return '';
  }

  dynamic _findMetricValue(dynamic node, List<String> keys) {
    if (node is Map) {
      // First check for exact key matches
      for (final key in keys) {
        if (node.containsKey(key)) {
          final value = node[key];
          if (value != null && value.toString().trim().isNotEmpty) {
            return value;
          }
        }
      }
      
      // Then check for partial matches (case-insensitive)
      for (final entry in node.entries) {
        final lowerKey = entry.key.toString().toLowerCase();
        for (final key in keys) {
          if (lowerKey.contains(key.toLowerCase())) {
            final value = entry.value;
            if (value != null && value.toString().trim().isNotEmpty) {
              return value;
            }
          }
        }
      }
      
      // Finally check nested maps/lists
      for (final entry in node.entries) {
        final nested = _findMetricValue(entry.value, keys);
        if (nested != null) return nested;
      }
    }
    
    if (node is List) {
      for (final item in node) {
        final nested = _findMetricValue(item, keys);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  List<Map<String, String>> _extractPlanRows(dynamic planData) {
    if (planData is List) {
      final rows = <Map<String, String>>[];
      for (var i = 0; i < planData.length; i++) {
        final item = planData[i];
        if (item is Map) {
          final season = _findFirstStringValue(item, ['season', 'Season', 'season_number', 'index', 'row', 'الموسم', 'رقم']);
          final crop = _findFirstStringValue(item, ['crop', 'Crop', 'recommended_crop', 'محصول', 'المحصول', 'crop_name', 'recommended']);
          final profit = _findFirstStringValue(item, ['est_profit', 'estimated_profit', 'profit', 'total_profit', 'ربح', 'مربح']);
          final water = _findFirstStringValue(item, ['water', 'water_mm', 'Water', 'ماء']);
          final fertilizer = _findFirstStringValue(item, ['fertilizer', 'fertilizer_kg', 'Fertilizer', 'سماد']);

          rows.add({
            'season': season.isNotEmpty ? season : (i + 1).toString(),
            'crop': crop.isNotEmpty ? crop : _extractFallbackFromItem(item),
            'profit': profit.isNotEmpty ? profit : '-',
            'water': water.isNotEmpty ? water : '-',
            'fertilizer': fertilizer.isNotEmpty ? fertilizer : '-',
          });
        } else if (item is String) {
          rows.add({
            'season': (i + 1).toString(),
            'crop': item,
            'profit': '-',
            'water': '-',
            'fertilizer': '-',
          });
        } else {
          rows.add({
            'season': (i + 1).toString(),
            'crop': item?.toString() ?? '-',
            'profit': '-',
            'water': '-',
            'fertilizer': '-',
          });
        }
      }
      return rows;
    }

    if (planData is Map) {
      final season = _findFirstStringValue(planData, ['season', 'Season', 'season_number', 'index', 'row', 'الموسم', 'رقم']);
      final crop = _findFirstStringValue(planData, ['crop', 'Crop', 'recommended_crop', 'محصول', 'المحصول', 'crop_name', 'recommended']);
      final profit = _findFirstStringValue(planData, ['est_profit', 'estimated_profit', 'profit', 'total_profit', 'ربح', 'مربح']);
      final water = _findFirstStringValue(planData, ['water', 'water_mm', 'Water', 'ماء']);
      final fertilizer = _findFirstStringValue(planData, ['fertilizer', 'fertilizer_kg', 'Fertilizer', 'سماد']);

      return [
        {
          'season': season.isNotEmpty ? season : '-',
          'crop': crop.isNotEmpty ? crop : _extractFallbackFromItem(planData),
          'profit': profit.isNotEmpty ? profit : '-',
          'water': water.isNotEmpty ? water : '-',
          'fertilizer': fertilizer.isNotEmpty ? fertilizer : '-',
        }
      ];
    }

    return <Map<String, String>>[];
  }

  String _findFirstStringValue(Map item, List<String> keys) {
    final unitsToSkip = ['mm', 'cm', 'kg', 'g', 'l', 'ml', 'ton', '%', 'ha'];
    
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        final stringValue = value.toString().toLowerCase().trim();
        // Skip if it's just a unit abbreviation
        if (!unitsToSkip.contains(stringValue)) {
          return value.toString();
        }
      }
    }
    
    for (final entry in item.entries) {
      final lowerKey = entry.key.toString().toLowerCase();
      for (final key in keys) {
        if (lowerKey.contains(key.toLowerCase())) {
          final value = entry.value;
          if (value != null && value.toString().trim().isNotEmpty) {
            final stringValue = value.toString().toLowerCase().trim();
            // Skip if it's just a unit abbreviation
            if (!unitsToSkip.contains(stringValue)) {
              return value.toString();
            }
          }
        }
      }
    }
    
    for (final entry in item.entries) {
      if (entry.value is Map) {
        final nested = _findFirstStringValue(entry.value as Map, keys);
        if (nested.isNotEmpty) return nested;
      }
    }
    return '';
  }

  String _extractFallbackFromItem(dynamic item) {
    if (item is! Map) {
      return item?.toString() ?? '-';
    }
    final fallback = item.values
        .map((value) => value?.toString() ?? '')
        .where((value) => value.trim().isNotEmpty)
        .join(' • ');
    return fallback.isNotEmpty ? fallback : '-';
  }

  String _formatPlanFallback(dynamic planData) {
    if (planData is String) {
      return planData.trim();
    }
    if (planData is Map || planData is List) {
      return _flattenPlanData(planData).trim();
    }
    return '';
  }

  String _flattenPlanData(dynamic planData) {
    if (planData is String) {
      return planData;
    }
    if (planData is Map<String, dynamic>) {
      return planData.entries
          .map((entry) => '${entry.key}: ${_flattenPlanData(entry.value)}')
          .where((item) => item.trim().isNotEmpty)
          .join(' \n');
    }
    if (planData is List) {
      return planData
          .map((item) => _flattenPlanData(item))
          .where((item) => item.trim().isNotEmpty)
          .join(' \n');
    }
    return planData?.toString() ?? '';
  }
}
