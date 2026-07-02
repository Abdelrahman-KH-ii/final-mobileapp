import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/services/weather_service.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/weather_forecast_day.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  Future<WeatherData?>? _weatherFuture;
  bool _showForecast = false;
  String? _lastFarmId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final farm = Provider.of<FarmProvider>(context, listen: true).selectedFarm;
    if (farm?.id != _lastFarmId || _weatherFuture == null) {
      _lastFarmId = farm?.id;
      final lat = farm?.lat ?? 30.0444;
      final lng = farm?.lng ?? 31.2357;
      _weatherFuture = WeatherService.fetchWeather(lat, lng);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<WeatherData?>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white70,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final weather = snapshot.data;
        if (weather == null) return _buildFallbackCard(l);

        final emoji = WeatherService.getEmoji(weather.weatherCode);
        final desc =
            l.isArabic
                ? WeatherService.getDescriptionAr(weather.weatherCode)
                : weather.description;
        final isOptimal =
            weather.temperature >= 15 &&
            weather.temperature <= 35 &&
            weather.humidity >= 40 &&
            weather.humidity <= 85;

        return GestureDetector(
          onTap: () => setState(() => _showForecast = !_showForecast),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B4332).withAlpha(90),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Top section: temp + status ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.convertNumbers(
                                l.trParams('temp_value', {
                                  'value': '${weather.temperature.round()}',
                                }),
                              ),
                              style: AppFonts.font(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              desc,
                              style: AppFonts.font(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(38),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isOptimal
                                  ? '${l.tr('optimal')} ${l.tr('for_growth')}'
                                  : l.tr('alert'),
                              style: AppFonts.font(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color:
                                    isOptimal
                                        ? const Color(0xFF86EFAC)
                                        : const Color(0xFFFCA5A5),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ── Bottom quadrant grid ──
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            _weatherQuadrant(
                              Icons.thermostat_rounded,
                              l.convertNumbers(
                                l.trParams('temp_value', {
                                  'value': '${(weather.temperature - 5).round()}',
                                }),
                              ),
                              l.tr('soil_temp'),
                            ),
                            VerticalDivider(
                              color: Colors.white.withAlpha(30),
                              width: 1,
                              thickness: 1,
                            ),
                            _weatherQuadrant(
                              Icons.air_rounded,
                              l.convertNumbers(
                                l.trParams('wind_value', {
                                  'value': '${weather.windSpeed.round()}',
                                }),
                              ),
                              l.tr('wind'),
                            ),
                            VerticalDivider(
                              color: Colors.white.withAlpha(30),
                              width: 1,
                              thickness: 1,
                            ),
                            _weatherQuadrant(
                              Icons.grain_rounded,
                              l.convertNumbers(
                                l.trParams('precipitation_value', {
                                  'value': '${weather.precipitation}',
                                }),
                              ),
                              l.tr('precipitation'),
                            ),
                            VerticalDivider(
                              color: Colors.white.withAlpha(30),
                              width: 1,
                              thickness: 1,
                            ),
                            _weatherQuadrant(
                              Icons.water_drop_rounded,
                              l.convertNumbers('${weather.humidity}%'),
                              l.tr('humidity'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // ── 5-day forecast (expandable) ──
                if (_showForecast && weather.forecast.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 10),
                        Text(
                          l.tr('forecast_5day'),
                          style: AppFonts.font(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white60,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:
                              weather.forecast.map((day) {
                                return Expanded(
                                  child: WeatherForecastDay(
                                    day: _getDayName(day.date, l.isArabic),
                                    emoji: WeatherService.getEmoji(day.weatherCode),
                                    high: '${day.maxTemp.round()}°',
                                    low: '${day.minTemp.round()}°',
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _weatherQuadrant(IconData icon, String value, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white54, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppFonts.font(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppFonts.font(
                fontSize: 9,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackCard(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white54, size: 32),
          const SizedBox(width: 12),
          Text(
            l.tr('weather_unavailable'),
            style: AppFonts.font(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  String _getDayName(DateTime date, bool isArabic) {
    final now = DateTime.now();
    if (date.day == now.day) return isArabic ? 'اليوم' : 'Today';
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const ar = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return isArabic ? ar[date.weekday - 1] : en[date.weekday - 1];
  }
}
