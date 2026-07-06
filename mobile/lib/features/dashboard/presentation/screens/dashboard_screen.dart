import 'dart:async';
import 'dart:convert';
import 'package:farmtec/core/themes/app_fonts.dart';

import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/services/soil_health_service.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/add_task_sheet.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/crop_lifecycle_card.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:farmtec/features/dashboard/presentation/utils/market_crop_utils.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/market_card.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/profit_calculator_card.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/soil_card.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/task_tile.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/weather_card.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/dashboard_section_card.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:farmtec/features/dashboard/data/models/dashboard_models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Map<String, dynamic>>> _pricesFuture;
  String? _pricesCrop;
  late final PageController _advicePageController;
  int _activeAdvicePage = 0;
  Timer? _adviceTimer;

  static const _adviceKeys = [
    'advice_crop_rotation',
    'advice_irrigation_practices',
    'advice_soil_fertility',
    'advice_pest_monitoring',
  ];

  static const _adviceImages = [
    'assets/images/crop_rec.png',
    'assets/images/irri.png',
    'assets/images/plant.png',
    'assets/images/market_illus.png',
  ];

  static const _soilMetrics = <SoilMetricModel>[
    SoilMetricModel(label: 'ph_level', value: '6.8', progress: 0.68),
    SoilMetricModel(label: 'organic_matter', value: '2.9%', progress: null),
    SoilMetricModel(label: 'nitrogen', value: 'Medium', progress: null),
    SoilMetricModel(label: 'texture', value: 'Loam', progress: null),
  ];

  String? _loadedFarmId;
  List<Map<String, dynamic>> _tasks = [];
  double _soilScore = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final farm = Provider.of<FarmProvider>(context).selectedFarm;
    if (farm != null && _loadedFarmId != farm.id) {
      _loadTasks(farm.id);
    }
  }

  Future<void> _loadTasks(String farmId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('tasks_$farmId');
    if (jsonStr != null) {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      if (mounted) {
        setState(() {
          _tasks = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          _loadedFarmId = farmId;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _tasks = [];
          _loadedFarmId = farmId;
        });
      }
    }
  }

  Future<void> _saveTasks(String farmId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks_$farmId', jsonEncode(_tasks));
  }

  @override
  void initState() {
    super.initState();
    _advicePageController = PageController(viewportFraction: 0.94);
    _adviceTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_advicePageController.hasClients) return;
      final nextPage = (_activeAdvicePage + 1) % _adviceKeys.length;
      _advicePageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _adviceTimer?.cancel();
    _advicePageController.dispose();
    super.dispose();
  }

  void _ensurePricesLoaded(String crop) {
    if (_pricesCrop == crop) return;
    _pricesCrop = crop;
    _pricesFuture = _fetchPricesForCrop(crop);
  }

  Future<List<Map<String, dynamic>>> _fetchPricesForCrop(String crop) async {
    final symbol = MarketCropUtils.apiSymbolFor(crop);

    if (symbol != null) {
      try {
        final r = await http
            .get(
              Uri.parse(
                'https://commodities-api.com/api/latest?access_key=DEMO&base=USD&symbols=$symbol',
              ),
            )
            .timeout(const Duration(seconds: 4));
        if (r.statusCode == 200) {
          final data = jsonDecode(r.body);
          if (data['data'] != null && data['data']['rates'] != null) {
            final rates = data['data']['rates'] as Map<String, dynamic>;
            if (rates.containsKey(symbol)) {
              final value = (rates[symbol] as num).toDouble();
              return [
                {
                  'name': crop,
                  'price': '\$${value.toStringAsFixed(2)}/t',
                  'change': '+1.2%',
                  'isUp': true,
                  'rawValue': value,
                },
              ];
            }
          }
        }
      } catch (_) {}
    }

    try {
      final r = await http.get(
        Uri.parse('https://b1r-14n15-forecast.hf.space/forecast'),
      );
      if (r.statusCode == 200) {
        final List<dynamic> data = jsonDecode(r.body);
        final Map<String, List<double>> grouped = {};
        for (var item in data) {
          final commodity = item['commodity'] as String;
          if (!MarketCropUtils.matchesCommodity(commodity, crop)) continue;
          grouped
              .putIfAbsent(commodity, () => [])
              .add((item['price'] as num).toDouble());
        }
        if (grouped.isNotEmpty) {
          final entry = grouped.entries.first;
          final prices = entry.value;
          final change =
              prices.first != 0
                  ? ((prices.last - prices.first) / prices.first) * 100
                  : 0.0;
          return [
            {
              'name': entry.key,
              'price': '\$${prices.first.toStringAsFixed(2)}/t',
              'change':
                  '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
              'isUp': change >= 0,
              'rawValue': prices.first,
            },
          ];
        }
      }
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final l = AppLocalizations.of(context);
    final farmService = Provider.of<FarmProvider>(context);
    final farm = farmService.selectedFarm;
    final crop = farm?.crop ?? 'Wheat';
    final soilHealthService = Provider.of<SoilHealthService>(context);
    if (farm != null && mounted) {
      Future.microtask(() async {
        final score = await soilHealthService.getScoreForLocation(
          lat: farm.lat,
          lng: farm.lng,
        );
        if (mounted && (_soilScore - score).abs() > 0.0001) {
          setState(() => _soilScore = score);
        }
      });
    }
    _ensurePricesLoaded(crop);
    final textColor = colors.textPrimary;
    final subColor = colors.textSecondary;
    final cardColor = colors.card;
    final bgColor = colors.background;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 260 + MediaQuery.of(context).padding.top,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/dashboard_illus.png',
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          bgColor.withAlpha(0),
                          bgColor,
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withAlpha(100)
                        : Colors.white.withAlpha(30),
                  ),
                ),
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 16,
            20,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(
                farmName: farm?.name ?? l.tr('my_farm'),
                isDark: isDark,
                textColor: textColor,
                subColor: subColor,
              ),
              const SizedBox(height: 16),
              const WeatherCard(),
              const SizedBox(height: 14),
              DashboardSectionCard(
                icon: Icons.eco_rounded,
                title: l.tr('crop_lifecycle'),
                titleColor: textColor,
                isDark: isDark,
                cardColor: cardColor,
                child: CropLifecycleCard(
                  isDark: isDark,
                  textColor: textColor,
                  subColor: subColor,
                  crop: farm?.crop ?? 'Wheat',
                  plantedAt: farm?.plantedAt,
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDark ? cardColor : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Pallete.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l.tr('farming_advice_tips'),
                      style: AppFonts.font(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _advicePageController,
                  itemCount: _adviceKeys.length,
                  onPageChanged: (page) => setState(() => _activeAdvicePage = page),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              _adviceImages[index],
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.18),
                                    Colors.black.withOpacity(0.60),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 18,
                              right: 18,
                              bottom: 18,
                              child: Text(
                                l.tr(_adviceKeys[index]),
                                style: AppFonts.font(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 8,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _adviceKeys.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _activeAdvicePage == index ? 18 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _activeAdvicePage == index
                          ? (isDark ? Pallete.chartGreen : Pallete.primary)
                          : (isDark ? const Color(0xFF4B4F5E) : const Color(0xFFD3D7DE)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DashboardSectionCard(
                icon: Icons.terrain_rounded,
                title: l.tr('soil_metrics'),
                titleColor: textColor,
                isDark: isDark,
                cardColor: cardColor,
                child: SoilCard(
                  metrics: _soilMetrics,
                  isDark: isDark,
                  textColor: textColor,
                  overallHealth: (_soilScore / 100).clamp(0.0, 1.0),
                  overallValue: '${l.convertNumbers(_soilScore.toStringAsFixed(0))}%',
                  overallLabelKey: 'overall_soil_health',
                ),
              ),
              const SizedBox(height: 14),
              DashboardSectionCard(
                icon: Icons.task_alt_rounded,
                title: l.tr('task_automation'),
                titleColor: textColor,
                isDark: isDark,
                cardColor: cardColor,
                centerContent: _tasks.isEmpty,
                child:
                    _tasks.isEmpty
                        ? _buildEmptyTasks(l, textColor, subColor)
                        : Column(
                          children: List.generate(_tasks.length, (index) {
                            final task = _tasks[index];
                            return TaskTile(
                              title: task['title'],
                              schedule: task['schedule'],
                              initialCompleted: task['completed'] ?? false,
                              isDark: isDark,
                              cardColor: cardColor,
                              textColor: textColor,
                              subColor: subColor,
                              onDelete: () {
                                setState(() {
                                  _tasks.removeAt(index);
                                });
                                if (farm != null) {
                                  _saveTasks(farm.id);
                                }
                              },
                            );
                          }),
                        ),
              ),
              const SizedBox(height: 14),
              DashboardSectionCard(
                icon: Icons.shopping_cart_outlined,
                title: l.tr('market_snapshot'),
                titleColor: textColor,
                isDark: isDark,
                cardColor: cardColor,
                child: MarketCard(
                  future: _pricesFuture,
                  cropName: crop,
                  isDark: isDark,
                  textColor: textColor,
                  subColor: subColor,
                ),
              ),
              const SizedBox(height: 14),
              DashboardSectionCard(
                icon: Icons.calculate_rounded,
                title: l.tr('profit_calculator'),
                titleColor: textColor,
                isDark: isDark,
                cardColor: cardColor,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _pricesFuture,
                  builder: (context, snapshot) {
                    double price = 245.0;
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final List<Map<String, dynamic>> data = snapshot.data!;
                      Map<String, dynamic>? match;
                      for (final m in data) {
                        if (MarketCropUtils.matchesCommodity(
                          m['name']?.toString() ?? '',
                          crop,
                        )) {
                          match = m;
                          break;
                        }
                      }
                      match ??= data.isNotEmpty ? data.first : null;
                      if (match != null && match['rawValue'] != null) {
                        price = (match['rawValue'] as num).toDouble();
                      }
                    }

                    return ProfitCalculatorCard(
                      isDark: isDark,
                      textColor: textColor,
                      subColor: subColor,
                      marketPrice: price,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTasks(
    AppLocalizations l,
    Color textColor,
    Color subColor,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TasksBackdropPainter(isDark: Theme.of(context).brightness == Brightness.dark),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _showAddTaskSheet,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Pallete.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Pallete.primary.withAlpha(45),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.isArabic ? 'لا توجد مهام بعد' : 'No tasks yet',
                textAlign: TextAlign.center,
                style: AppFonts.font(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Pallete.primary,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l.isArabic
                      ? 'اضغط على + لإضافة مهمة جديدة لمزرعتك'
                      : 'Tap + to add a new task for your farm',
                  textAlign: TextAlign.center,
                  style: AppFonts.font(fontSize: 11, color: subColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet() {
    final farm = Provider.of<FarmProvider>(context, listen: false).selectedFarm;
    final soilHealthService = Provider.of<SoilHealthService>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => AddTaskSheet(
            onAdd: (title) {
              setState(() {
                _tasks.add({'title': title, 'schedule': 'One-time • Today'});
              });
              if (farm != null) {
                _saveTasks(farm.id);
              }
            },
          ),
    );
  }
}

class _TasksBackdropPainter extends CustomPainter {
  final bool isDark;

  _TasksBackdropPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color =
              isDark
                  ? Colors.white.withAlpha(12)
                  : const Color(0xFFDDE3D8).withAlpha(120)
          ..style = PaintingStyle.fill;

    final hill = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.45,
        size.width * 0.5,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.78,
        size.width,
        size.height * 0.55,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hill, paint);

    final cloudPaint =
        Paint()..color = isDark ? Colors.white12 : const Color(0xFFE8EDE4);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.28), 10, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.26), 8, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.22), 9, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.24), 7, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant _TasksBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
