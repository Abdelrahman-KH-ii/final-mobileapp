import 'package:flutter/material.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
// app_fonts import removed — not needed after UI simplification
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/ai_model_result_card_shell.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/model_results_helpers.dart';

class FertilizerPlannerResultsCard extends StatelessWidget {
  final dynamic data;
  final AppLocalizations l;
  final Color cardColor;
  final Color textColor;
  final Color accentGreen;

  const FertilizerPlannerResultsCard({
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
    Map<String, dynamic>? record;

    if (payload['data'] is List) {
      final list = payload['data'] as List;
      // Merge any map entries in the list so we can find keys regardless of which
      // element contains them (some responses wrap recommendation parts in multiple maps)
      final merged = <String, dynamic>{};
      for (final item in list) {
        if (item is Map) {
          item.forEach((k, v) => merged[k.toString()] = v);
        }
      }

      // Prefer the map that contains fertilizer recommendation keys if present
      final found = list.whereType<Map<String, dynamic>>().firstWhere(
        (item) => item.containsKey('Selected Fertilizer') || item.containsKey('recommended_fertilizer_amount'),
        orElse: () => <String, dynamic>{},
      );
      if (found.isNotEmpty) {
        record = found;
      } else if (merged.isNotEmpty) {
        record = merged;
      }
    } else if (payload['data'] is Map<String, dynamic>) {
      record = payload['data'] as Map<String, dynamic>;
    }

    record ??= payload;

    final amount = record['recommended_fertilizer_amount'] ?? record['amount_kg_ha'] ?? record['amount'] ?? record['dose_kg_ha'] ?? (record['current_application'] is Map<String, dynamic> ? record['current_application']['amount_kg_ha'] : null);
    final amountText = amount is num ? (amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(1)) : amount?.toString() ?? l.tr('model_result_unknown');

    // Build tables from response. Support several shapes: flat keys or nested maps like
    // record['expected_outcomes'] or record['yield_information'] or record['yield_info'].
    Map<String, dynamic> expectedRows = {};
    Map<String, dynamic> yieldRows = {};
    // keep raw keyed copies so we can prefer 'new' variants when formatting
    Map<String, dynamic> rawExpected = {};
    Map<String, dynamic> rawYield = {};

    // Helper to pretty label keys
    String labelForKey(String key) {
      final k = key.toLowerCase();
      if (k.contains('expected_yield_gain')) return l.tr('expected_yield_gain');
      if (k.contains('expected_yield_gain_pct') || k.contains('expected_yield_gain_percentage')) return l.tr('expected_yield_gain_pct');
      if (k.contains('predicted_yield') || k.contains('predicted')) return l.tr('model_result_field_yield');
      if (k.contains('target_yield')) return l.tr('target_yield');
      if (k.contains('yield_gap')) return l.tr('yield_gap');
      // Fallback: humanize
      final s = key.replaceAll('_', ' ');
      return s.substring(0, 1).toUpperCase() + s.substring(1);
    }

    // Extract expected outcomes
    if (record.containsKey('expected_outcomes') && record['expected_outcomes'] is Map<String, dynamic>) {
      (record['expected_outcomes'] as Map<String, dynamic>).forEach((k, v) {
        expectedRows[labelForKey(k)] = v;
        rawExpected[k.toString()] = v;
      });
    } else if (record.containsKey('expected') && record['expected'] is Map<String, dynamic>) {
      (record['expected'] as Map<String, dynamic>).forEach((k, v) {
        expectedRows[labelForKey(k)] = v;
        rawExpected[k.toString()] = v;
      });
    } else {
      // fallback to specific keys
      if (record.containsKey('expected_yield_gain')) {
        expectedRows[l.tr('expected_yield_gain')] = record['expected_yield_gain'];
        rawExpected['expected_yield_gain'] = record['expected_yield_gain'];
      }
      if (record.containsKey('expected_yield_gain_pct')) {
        expectedRows[l.tr('expected_yield_gain_pct')] = record['expected_yield_gain_pct'];
        rawExpected['expected_yield_gain_pct'] = record['expected_yield_gain_pct'];
      }
      if (record.containsKey('expected_yield_gain_percentage')) {
        expectedRows[l.tr('expected_yield_gain_pct')] = record['expected_yield_gain_percentage'];
        rawExpected['expected_yield_gain_percentage'] = record['expected_yield_gain_percentage'];
      }
    }

    // Extract yield information
    if (record.containsKey('yield_information') && record['yield_information'] is Map<String, dynamic>) {
      (record['yield_information'] as Map<String, dynamic>).forEach((k, v) {
        yieldRows[labelForKey(k)] = v;
        rawYield[k.toString()] = v;
      });
    } else if (record.containsKey('yield_info') && record['yield_info'] is Map<String, dynamic>) {
      (record['yield_info'] as Map<String, dynamic>).forEach((k, v) {
        yieldRows[labelForKey(k)] = v;
        rawYield[k.toString()] = v;
      });
    } else {
      if (record.containsKey('predicted_yield')) {
        yieldRows[l.tr('model_result_field_yield')] = record['predicted_yield'];
        rawYield['predicted_yield'] = record['predicted_yield'];
      }
      if (record.containsKey('target_yield')) {
        yieldRows[l.tr('target_yield')] = record['target_yield'];
        rawYield['target_yield'] = record['target_yield'];
      }
      if (record.containsKey('yield_gap')) {
        yieldRows[l.tr('yield_gap')] = record['yield_gap'];
        rawYield['yield_gap'] = record['yield_gap'];
      }
      // also, some responses include 'predicted' or 'predicted_yield_t_ha'
      if (record.containsKey('predicted')) {
        yieldRows[l.tr('model_result_field_yield')] = record['predicted'];
        rawYield['predicted'] = record['predicted'];
      }
    }

    // Prefer 'new' / 'after' predicted values when available (top-level or nested)
    final newPredKeys = [
      'predicted_yield_new',
      'predicted_yield_after',
      'predicted_after',
      'predicted_with_fertilizer',
      'predicted_yield_with_fertilizer',
      'predicted_yield_post',
      'predicted_yield_after_application',
      'predicted_yield_recommended',
      'predicted_new',
      'predicted_after_application',
    ];

    for (final k in newPredKeys) {
      if (record.containsKey(k)) {
        yieldRows[l.tr('model_result_field_yield')] = record[k];
        rawYield[k] = record[k];
        break;
      }
    }

    // Also check nested maps
    for (final containerKey in ['expected_outcomes', 'yield_information', 'yield_info', 'expected', 'data']) {
      final cont = record[containerKey];
      if (cont is Map<String, dynamic>) {
        for (final k in newPredKeys) {
          if (cont.containsKey(k)) {
            yieldRows[l.tr('model_result_field_yield')] = cont[k];
            rawYield[k] = cont[k];
            break;
          }
        }
      }
    }

    // Prefer new expected yield gain keys if present
    final newExpectedKeys = [
      'expected_yield_gain_new',
      'expected_yield_gain_after',
      'expected_yield_gain_post',
      'expected_yield_gain_recommended',
    ];
    for (final k in newExpectedKeys) {
      if (record.containsKey(k)) {
        expectedRows[l.tr('expected_yield_gain')] = record[k];
        rawExpected[k] = record[k];
        break;
      }
    }
    for (final containerKey in ['expected_outcomes', 'expected', 'data']) {
      final cont = record[containerKey];
      if (cont is Map<String, dynamic>) {
        for (final k in newExpectedKeys) {
          if (cont.containsKey(k)) {
            expectedRows[l.tr('expected_yield_gain')] = cont[k];
            rawExpected[k] = cont[k];
            break;
          }
        }
      }
    }

    return AiModelResultCardShell(
      cardColor: cardColor,
      textColor: textColor,
      accentGreen: accentGreen,
      topAccentColor: const Color(0xFFFBBF24),
      icon: Icons.local_florist,
      iconColor: const Color(0xFFB45309),
      backgroundGradient: const LinearGradient(
        colors: [Color(0xFFFFFBEB), Color(0xFFF7F3E9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: const Color(0xFFF3C072),
      title: l.tr('model_result_fertilizer_title'),
      children: [
        AiModelResultSection(
          title: l.tr('model_result_section_fertilizer_recommendation'),
          textColor: textColor,
          accentGreen: accentGreen,
          sectionColor: cardColor.withOpacity(0.88),
          sectionBorderColor: accentGreen.withOpacity(0.16),
          children: [
            AiModelResultField(label: l.tr('model_result_field_amount'), value: '$amountText kg/ha', bulletColor: accentGreen, textColor: textColor),
            const SizedBox(height: 12),
          ],
        ),
      ],
    );
  }

  // Table renderer removed — metrics are displayed as a simple list now.

  // Metrics list renderer removed — fertilizer card no longer shows expected/yield metrics.

  // Ordered table rows removed; metrics rendered via _buildMetricsList now.

  // value-picker removed — metrics no longer displayed here.
}
