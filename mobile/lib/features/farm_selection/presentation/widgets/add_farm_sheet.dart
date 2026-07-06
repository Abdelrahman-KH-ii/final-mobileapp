import 'package:farmtec/core/constants/farm_icons.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/widgets/farm_marker_icon.dart';
import 'package:farmtec/core/map/satellite_map_tiles.dart';
import 'package:farmtec/core/services/crop_lifecycle_service.dart';
import 'package:farmtec/core/services/farm_history_service.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:farmtec/features/farm_selection/presentation/widgets/farm_sheet_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class AddFarmSheet extends StatefulWidget {
  const AddFarmSheet({super.key});

  @override
  State<AddFarmSheet> createState() => _AddFarmSheetState();
}

class _AddFarmSheetState extends State<AddFarmSheet> {
  final _nameCtrl = TextEditingController();
  String _selectedCrop = 'Wheat';
  final _areaCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _mapCtrl = MapController();
  bool _loadingGps = false;
  DateTime _plantedAt = DateTime.now();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _areaCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchGps() async {
    setState(() => _loadingGps = true);

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).tr('location_services_disabled') ??
                  'Location services are disabled. Please enable GPS.',
            ),
          ),
        );
        setState(() => _loadingGps = false);
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                      context,
                    ).tr('location_permissions_denied') ??
                    'Location permissions are denied.',
              ),
            ),
          );
          setState(() => _loadingGps = false);
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                    context,
                  ).tr('location_permissions_permanently_denied') ??
                  'Location permissions are permanently denied.',
            ),
          ),
        );
        setState(() => _loadingGps = false);
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _latCtrl.text = position.latitude.toStringAsFixed(4);
          _lngCtrl.text = position.longitude.toStringAsFixed(4);
          _loadingGps = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).tr('location_fetch_failed'),
            ),
          ),
        );
        setState(() => _loadingGps = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final l = AppLocalizations.of(context);
    final textColor = colors.textPrimary;
    final fillColor = colors.surfaceVariant;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.tr('add_farm'),
              style: AppFonts.font(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),

            FarmSheetField(
              label: l.tr('farm_name'),
              ctrl: _nameCtrl,
              icon: FarmIcons.farm,
              isDark: isDark,
              fillColor: fillColor,
              textColor: textColor,
            ),
            const SizedBox(height: 12),
            FarmSheetDropdown(
              label: l.tr('crop_type'),
              value: _selectedCrop,
              items: CropLifecycleService.availableCrops,
              onChanged: (val) {
                if (val != null) setState(() => _selectedCrop = val);
              },
              icon: Icons.eco_rounded,
              isDark: isDark,
              fillColor: fillColor,
              textColor: textColor,
            ),
            const SizedBox(height: 12),
            FarmSheetField(
              label: l.tr('area_hectares'),
              ctrl: _areaCtrl,
              icon: Icons.map_rounded,
              isDark: isDark,
              fillColor: fillColor,
              textColor: textColor,
              type: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildPlantingDateField(l, isDark, textColor, fillColor),
            const SizedBox(height: 16),

            Text(
              l.tr('location'),
              style: AppFonts.font(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FarmSheetField(
                    label: l.tr('latitude'),
                    ctrl: _latCtrl,
                    icon: Icons.explore_rounded,
                    isDark: isDark,
                    fillColor: fillColor,
                    textColor: textColor,
                    type: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FarmSheetField(
                    label: l.tr('longitude'),
                    ctrl: _lngCtrl,
                    icon: Icons.explore_rounded,
                    isDark: isDark,
                    fillColor: fillColor,
                    textColor: textColor,
                    type: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadingGps ? null : _fetchGps,
                icon:
                    _loadingGps
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Pallete.primary,
                          ),
                        )
                        : const Icon(
                          Icons.my_location_rounded,
                          color: Pallete.primary,
                          size: 18,
                        ),
                label: Text(
                  _loadingGps ? l.tr('fetching_gps') : l.tr('use_gps'),
                  style: AppFonts.font(
                    fontWeight: FontWeight.w700,
                    color: Pallete.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Pallete.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            _buildMapPreview(isDark),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (_nameCtrl.text.isNotEmpty) {
                    final farmId =
                        'farm_${DateTime.now().millisecondsSinceEpoch}';
                    final areaHa =
                        _areaCtrl.text.isNotEmpty ? _areaCtrl.text : '0';
                    Provider.of<FarmProvider>(context, listen: false).addFarm(
                      Farm(
                        id: farmId,
                        name: _nameCtrl.text,
                        crop: _selectedCrop,
                        area: '$areaHa ha',
                        health: 'healthy',
                        lastScan: '',
                        lat: double.tryParse(_latCtrl.text) ?? 0,
                        lng: double.tryParse(_lngCtrl.text) ?? 0,
                        plantedAt: _plantedAt,
                      ),
                    );
                    Provider.of<FarmHistoryService>(
                      context,
                      listen: false,
                    ).addOperation(
                      FarmOperation(
                        id: 'op_${DateTime.now().microsecondsSinceEpoch}',
                        farmId: farmId,
                        type: OperationType.cropPlant,
                        title: 'Farm Created',
                        titleKey: 'farm_created',
                        description: '$_selectedCrop · $areaHa ha',
                        timestamp: DateTime.now(),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  l.tr('add_farm'),
                  style: AppFonts.font(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantingDateField(
    AppLocalizations l,
    bool isDark,
    Color textColor,
    Color fillColor,
  ) {
    final colors = context.appColors;
    final dateLabel =
        '${_plantedAt.year}-${_plantedAt.month.toString().padLeft(2, '0')}-${_plantedAt.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.tr('planting_date'),
          style: AppFonts.font(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _plantedAt,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _plantedAt = picked);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Pallete.primary, size: 18),
                const SizedBox(width: 12),
                Text(
                  l.convertNumbers(dateLabel),
                  style: AppFonts.font(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Text(
                  l.tr('select_planting_date'),
                  style: AppFonts.font(
                    fontSize: 11,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview(bool isDark) {
    final colors = context.appColors;
    final l = AppLocalizations.of(context);
    final lat = double.tryParse(_latCtrl.text) ?? 0;
    final lng = double.tryParse(_lngCtrl.text) ?? 0;
    final hasCoords = lat != 0 || lng != 0;
    final center =
        hasCoords ? LatLng(lat, lng) : const LatLng(30.0444, 31.2357);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.satellite_alt_rounded,
              size: 16,
              color: colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              l.tr('map_preview'),
              style: AppFonts.font(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const Spacer(),
            if (!hasCoords)
              Text(
                l.tr('tap_map_set_location'),
                style: AppFonts.font(
                  fontSize: 10,
                  color: colors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 160,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.outline,
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.5),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapCtrl,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: hasCoords ? 14 : 5,
                    onTap: (tapPos, latlng) {
                      setState(() {
                        _latCtrl.text = latlng.latitude.toStringAsFixed(6);
                        _lngCtrl.text = latlng.longitude.toStringAsFixed(6);
                      });
                    },
                  ),
                  children: [
                    ...SatelliteMapTiles.layers(),
                    if (hasCoords)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(lat, lng),
                            width: 36,
                            height: 36,
                            child: const FarmMarkerIcon(size: 36, iconSize: 18),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(150),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        AppLocalizations.of(context).tr('map_satellite_attribution'),
                        style: AppFonts.font(
                          fontSize: 8,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
