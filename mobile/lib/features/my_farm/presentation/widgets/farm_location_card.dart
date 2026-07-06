import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/map/field_boundary.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/map/satellite_map_tiles.dart';
import 'package:farmtec/core/services/farm_history_service.dart';
import 'package:farmtec/core/services/agromonitoring_client.dart';
import 'package:farmtec/core/services/ndvi_service.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/widgets/farm_marker_icon.dart';
import 'package:farmtec/features/farm/domain/entities/farm.dart';
import 'package:farmtec/features/my_farm/presentation/screens/full_map_screen.dart';
import 'package:farmtec/features/my_farm/presentation/widgets/my_farm_card_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class FarmLocationCard extends StatefulWidget {
  final Farm farm;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color subColor;

  const FarmLocationCard({
    super.key,
    required this.farm,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
  });

  @override
  State<FarmLocationCard> createState() => _FarmLocationCardState();
}

class _FarmLocationCardState extends State<FarmLocationCard> {
  static const _mapHeight = 185.0;

  final MapController _mapController = MapController();

  bool _showNDVI = false;
  bool _ndviLoading = false;
  NdviAnalysisResult? _ndviResult;

  Color get _pillBg =>
      widget.isDark ? Pallete.darkSurfaceVariant : const Color(0xFFF0F2EE);

  FieldBoundary get _fieldBoundary {
    final hectares = FieldBoundary.parseHectares(widget.farm.area);
    return FieldBoundary.fromCenter(
      lat: widget.farm.lat,
      lng: widget.farm.lng,
      hectares: hectares,
      orientationSeed: widget.farm.id,
    );
  }

  List<Polygon> _fieldOverlay() {
    return [
      Polygon(
        points: _fieldBoundary.drawRing,
        color: const Color(0xFF7CB87C).withAlpha(95),
        borderColor: Colors.white,
        borderStrokeWidth: 2,
      ),
    ];
  }

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
    final hasCoords = widget.farm.lat != 0 || widget.farm.lng != 0;

    if (!hasCoords) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.tr('ndvi_no_location'))),
      );
      return;
    }

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
          SnackBar(content: Text(l.tr('failed_to_load'))),
        );
      }
    }
  }

  void _recenterMap() {
    final center = LatLng(widget.farm.lat, widget.farm.lng);
    _mapController.move(center, _mapController.camera.zoom);
  }

  String _coordsText(AppLocalizations l) {
    final lat = widget.farm.lat.toStringAsFixed(4);
    final lng = widget.farm.lng.toStringAsFixed(4);
    return l.trParams('coords_short_format', {
      'lat': l.convertNumbers(lat),
      'lng': l.convertNumbers(lng),
    });
  }

  Widget _actionPill({
    required VoidCallback? onTap,
    required Widget child,
    bool active = false,
  }) {
    return Material(
      color: active ? Pallete.primary : _pillBg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasCoords = widget.farm.lat != 0 || widget.farm.lng != 0;
    final center = LatLng(widget.farm.lat, widget.farm.lng);

    if (!hasCoords) return const SizedBox.shrink();

    return Container(
      decoration: myFarmCardDecoration(widget.isDark, widget.cardColor),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: Pallete.primary,
              ),
              const SizedBox(width: 6),
              Text(
                l.tr('location'),
                style: AppFonts.font(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: widget.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: _mapHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 14,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      ),
                    ),
                    children: [
                      ...SatelliteMapTiles.layers(),
                      if (_showNDVI && _ndviResult != null)
                        PolygonLayer(polygons: _ndviPolygons(_ndviResult!))
                      else
                        PolygonLayer(polygons: _fieldOverlay()),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: center,
                            width: 36,
                            height: 36,
                            child: const FarmMarkerIcon(size: 36, iconSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_ndviLoading)
                    Container(
                      color: Colors.black.withAlpha(80),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              l.tr('ndvi_analyzing'),
                              style: AppFonts.font(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(140),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l.tr('map_satellite_attribution'),
                          style: AppFonts.font(
                            fontSize: 7,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_showNDVI && _ndviResult != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: widget.cardColor.withAlpha(220),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l.trParams(
                            'ndvi_scan_result',
                            {
                              'value': l.convertNumbers(
                                _ndviResult!.averageNdvi.toStringAsFixed(2),
                              ),
                            },
                          ),
                          style: AppFonts.font(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: widget.textColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Material(
                      color: _pillBg,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: _recenterMap,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.gps_fixed_rounded,
                            size: 16,
                            color: Pallete.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.tr('location_coordinates'),
                            style: AppFonts.font(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: widget.subColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _coordsText(l),
                            style: AppFonts.font(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Pallete.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _actionPill(
                onTap: _ndviLoading ? null : _onNdviTap,
                active: _showNDVI,
                child:
                    _ndviLoading
                        ? const SizedBox(
                          width: 52,
                          height: 14,
                          child: Center(
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Pallete.primary,
                              ),
                            ),
                          ),
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.eco_rounded,
                              size: 13,
                              color: _showNDVI ? Colors.white : Pallete.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l.tr('vegetation_health'),
                              style: AppFonts.font(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color:
                                    _showNDVI ? Colors.white : Pallete.primary,
                              ),
                            ),
                          ],
                        ),
              ),
              const SizedBox(width: 8),
              _actionPill(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FullMapScreen(farm: widget.farm),
                    ),
                  );
                },
                child: const Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                  color: Pallete.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
