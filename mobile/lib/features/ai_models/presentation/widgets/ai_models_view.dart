import 'package:farmtec/core/config/api_config.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/ai_model_definition.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/ai_model_tile.dart';
import 'package:flutter/material.dart';

class AIModelsView extends StatelessWidget {
  const AIModelsView({super.key});

  static final _models = [
    AIModelDefinition(
      name: 'Disease Detection',
      desc: 'Upload crop photos for instant disease identification.',
      icon: Icons.bug_report_rounded,
      backgroundImage: 'assets/images/plant.png',
      apiUrl: ApiConfig.mobilePath('ai/plant-disease/'),
      kind: AIModelKind.vision,
      fields: [
        AIModelFieldDefinition(
          key: 'prompt',
          label: 'Question',
          hint: 'Describe symptoms or ask about the plant...',
          type: TextInputType.multiline,
        ),
      ],
    ),
    AIModelDefinition(
      name: 'Crop Recommendation',
      desc: 'Predicts optimal crop based on GPS location',
      icon: Icons.agriculture_rounded,
      backgroundImage: 'assets/images/crop_rec.png',
      apiUrl: ApiConfig.mobilePath('ai/crop-recommendation/'),
      fields: [
        AIModelFieldDefinition(
          key: 'lat',
          label: 'Latitude',
          hint: '30.0444',
          type: TextInputType.numberWithOptions(decimal: true),
        ),
        AIModelFieldDefinition(
          key: 'lon',
          label: 'Longitude',
          hint: '31.2357',
          type: TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    ),
    AIModelDefinition(
      name: 'Yield Prediction',
      desc: 'Forecasts crop yield from location, year & crop type',
      icon: Icons.trending_up_rounded,
      backgroundImage: 'assets/images/yield.png',
      apiUrl: ApiConfig.mobilePath('ai/yield/'),
      fields: [
        AIModelFieldDefinition(
          key: 'lat',
          label: 'Latitude',
          hint: '30.0444',
          type: TextInputType.numberWithOptions(decimal: true),
        ),
        AIModelFieldDefinition(
          key: 'lon',
          label: 'Longitude',
          hint: '31.2357',
          type: TextInputType.numberWithOptions(decimal: true),
        ),
        AIModelFieldDefinition(
          key: 'year',
          label: 'Year',
          hint: '2026',
          type: TextInputType.number,
        ),
        AIModelFieldDefinition(
          key: 'crop',
          label: 'Crop',
          hint: 'Wheat',
          type: TextInputType.text,
        ),
      ],
    ),
    AIModelDefinition(
      name: 'Irrigation Planner',
      desc: 'Calculates irrigation needs from GPS coordinates',
      icon: Icons.water_drop_rounded,
      backgroundImage: 'assets/images/irri.png',
      apiUrl: ApiConfig.mobilePath('ai/irrigation/'),
      fields: [
        AIModelFieldDefinition(
          key: 'lat',
          label: 'Latitude',
          hint: '30.0444',
          type: TextInputType.numberWithOptions(decimal: true),
        ),
        AIModelFieldDefinition(
          key: 'lon',
          label: 'Longitude',
          hint: '31.2357',
          type: TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    ),
    AIModelDefinition(
      name: 'Market Forecast',
      desc: 'Commodity price forecast from live market data',
      icon: Icons.insights_rounded,
      backgroundImage: 'assets/images/prices.png',
      apiUrl: ApiConfig.mobilePath('ai/forecast/'),
      httpMethod: 'GET',
      fields: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final l = AppLocalizations.of(context);
    final textColor = colors.textPrimary;
    final subColor = colors.textSecondary;
    final cardColor = colors.card;
    final bgColor = colors.background;
    const heroHeight = 200.0;
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topPadding,
          child: ColoredBox(color: bgColor),
        ),
        Positioned(
          top: topPadding,
          left: 0,
          right: 0,
          child: SizedBox(
            height: heroHeight,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: [
                Image.asset(
                  'assets/images/models_illus.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withAlpha(100)
                        : Colors.white.withAlpha(30),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          bgColor,
                          bgColor.withAlpha(0),
                        ],
                      ),
                    ),
                  ),
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
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 100),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.eco_rounded,
                      size: 18,
                      color: context.screenHeaderTitle.withAlpha(180),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Text(
                        l.tr('ai_models'),
                        style: AppFonts.font(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: context.screenHeaderTitle,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.tr('tap_model_subtitle'),
                        style: AppFonts.font(
                          fontSize: 12,
                          color: context.screenHeaderSubtitle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.eco_rounded,
                      size: 18,
                      color: context.screenHeaderTitle.withAlpha(180),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 72),
              ...List.generate(
                _models.length,
                (i) => AiModelTile(
                  model: _models[i],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subColor: subColor,
                  isNew: _models[i].isVisionModel,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
