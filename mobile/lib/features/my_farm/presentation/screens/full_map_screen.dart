import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/map/satellite_map_tiles.dart';
import 'package:farmtec/core/services/agromonitoring_client.dart';
import 'package:farmtec/core/services/farm_history_service.dart';
import 'package:farmtec/core/services/ndvi_service.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/widgets/farm_marker_icon.dart';
import 'package:farmtec/features/farm/domain/entities/farm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class FullMapScreen extends StatefulWidget {
  static const routeName = '/full-map';

  final Farm farm;

  const FullMapScreen({super.key, required this.farm});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  final MapController _mapController = MapController();
  bool _showNDVI = false;
  bool _ndviLoading = false;
  NdviAnalysisResult? _ndviResult;
  double _currentZoom = 15;

  List<Polygon> _ndviPolygons(NdviAnalysisResult result) {
    final fieldOutline = Polygon(
      points: result.fieldBoundary,
      borderStrokeWidth: 2.5,
      borderColor: Colors.white,
      color: Colors.transparent,
    );
    final zones = result.zones.map((zone) {
      final color = NdviService.colorForNdvi(zone.ndvi);
      return Polygon(
        points: zone.polygon,
        color: color.withAlpha(110),
        borderColor: color.withAlpha(230),
        borderStrokeWidth: 1.2,
      );
    });
    return [fieldOutline, ...zones];
  }

  Future<void> _onNdviTap() async {
    final l = AppLocalizations.of(context);
    if (_showNDVI) {
      setState(() => _showNDVI = false);
      return;
    }
    setState(() => _ndviLoading = true);
    try {
      final result = await NdviService().analyze(
        farmId: widget.farm.id,
        lat: widget.farm.lat,
        lng: widget.farm.lng,
        area: widget.farm.area,
      );
      if (!mounted) return;
      setState(() {
        _ndviResult = result;
        _showNDVI = true;
        _ndviLoading = false;
      });
      final ndviLabel = result.averageNdvi.toStringAsFixed(2);
      await Provider.of<FarmHistoryService>(context, listen: false).addOperation(
        FarmOperation(
          id: 'op_${DateTime.now().microsecondsSinceEpoch}',
          farmId: widget.farm.id,
          type: OperationType.ndviScan,
          title: 'NDVI Scan',
          titleKey: 'ndvi_scan',
          description: l.trParams('ndvi_scan_result', {'value': ndviLabel}),
          timestamp: DateTime.now(),
        ),
      );
    } on AgromonitoringException catch (e) {
      if (mounted) {
        setState(() => _ndviLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _ndviLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).tr('failed_to_load'))),
        );
      }
    }
  }

  void _zoom(bool zoomIn) {
    _currentZoom = (_currentZoom + (zoomIn ? 1 : -1)).clamp(3.0, 22.0);
    _mapController.move(_mapController.camera.center, _currentZoom);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final center = LatLng(widget.farm.lat, widget.farm.lng);
    final textColor = colors.textPrimary;
    final subColor = colors.textSecondary;
    final surfaceColor = colors.card;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-screen Map ─────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _currentZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onMapEvent: (event) {
                if (event is MapEventMove) {
                  setState(() => _currentZoom = event.camera.zoom);
                }
              },
            ),
            children: [
              ...SatelliteMapTiles.layers(),
              if (_showNDVI && _ndviResult != null)
                PolygonLayer(polygons: _ndviPolygons(_ndviResult!)),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 48,
                    height: 48,
                    child: const FarmMarkerIcon(size: 48, iconSize: 24),
                  ),
                ],
              ),
            ],
          ),

          // ── NDVI loading overlay ────────────────────────────────────────────
          if (_ndviLoading)
            Container(
              color: Colors.black.withAlpha(100),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      l.tr('ndvi_analyzing'),
                      style: AppFonts.font(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Top bar (close + farm name) ─────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Farm name pill
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.farm.name,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.font(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── NDVI legend overlay ─────────────────────────────────────────────
          if (_showNDVI && _ndviResult != null)
            Positioned(
              top: 100,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.trParams(
                        'ndvi_scan_result',
                        {'value': _ndviResult!.averageNdvi.toStringAsFixed(2)},
                      ),
                      style: AppFonts.font(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _legendRow(const Color(0xFF4CAF50), l.tr('ndvi_healthy')),
                    const SizedBox(height: 4),
                    _legendRow(const Color(0xFFF44336), l.tr('ndvi_stressed')),
                  ],
                ),
              ),
            ),

          // ── Zoom controls ────────────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: 160,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _mapButton(
                  icon: Icons.add,
                  onTap: () => _zoom(true),
                ),
                const SizedBox(height: 8),
                _mapButton(
                  icon: Icons.remove,
                  onTap: () => _zoom(false),
                ),
                const SizedBox(height: 8),
                _mapButton(
                  icon: Icons.my_location_rounded,
                  onTap: () {
                    _mapController.move(center, 15);
                    setState(() => _currentZoom = 15);
                  },
                ),
              ],
            ),
          ),

          // ── Bottom info bar ──────────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: BoxDecoration(
                  color: surfaceColor.withAlpha(230),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white24
                            : Colors.black.withAlpha(30),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      children: [
                        // Satellite icon
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: colors.chipBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.satellite_alt_rounded,
                            color: Pallete.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Coordinates
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.tr('gps_coordinates'),
                                style: AppFonts.font(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l.isArabic
                                    ? l.trParams('lat_lng_format_ar', {
                                        'lat': l.convertNumbers(
                                          widget.farm.lat.toStringAsFixed(5),
                                        ),
                                        'lng': l.convertNumbers(
                                          widget.farm.lng.toStringAsFixed(5),
                                        ),
                                      })
                                    : l.trParams('lat_lng_format', {
                                        'lat': widget.farm.lat.toStringAsFixed(5),
                                        'lng': widget.farm.lng.toStringAsFixed(5),
                                      }),
                                style: AppFonts.font(
                                  fontSize: 11,
                                  color: subColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // NDVI toggle button
                        GestureDetector(
                          onTap: _ndviLoading ? null : _onNdviTap,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _showNDVI
                                  ? Pallete.primary
                                  : colors.chipBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _ndviLoading
                                ? const SizedBox(
                                    width: 40,
                                    height: 16,
                                    child: Center(
                                      child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.satellite_alt_rounded,
                                        size: 14,
                                        color: _showNDVI
                                            ? Colors.white
                                            : Pallete.primary,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        l.tr('vegetation_health'),
                                        style: AppFonts.font(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: _showNDVI
                                              ? Colors.white
                                              : Pallete.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                    // Attribution
                    const SizedBox(height: 10),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        l.tr('map_satellite_attribution'),
                        style: AppFonts.font(
                          fontSize: 9,
                          color: subColor.withAlpha(140),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppFonts.font(fontSize: 10, color: Colors.white),
        ),
      ],
    );
  }

  Widget _mapButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(160),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
