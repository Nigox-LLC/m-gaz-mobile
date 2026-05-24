import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/common/words.dart';
import '../../../../core/utils/services/location_service.dart';

typedef LocationProvider = Future<Position?> Function();
typedef LocationAddressResolver = Future<String?> Function(Position position);

class TaskLocationPickerResult {
  final Position position;
  final String? address;

  const TaskLocationPickerResult({required this.position, this.address});
}

class TaskLocationPickerScreen extends StatefulWidget {
  final Position? initialPosition;
  final String? initialAddress;
  final LocationProvider? locationProvider;
  final LocationAddressResolver? locationAddressResolver;

  const TaskLocationPickerScreen({
    super.key,
    this.initialPosition,
    this.initialAddress,
    this.locationProvider,
    this.locationAddressResolver,
  });

  @override
  State<TaskLocationPickerScreen> createState() =>
      _TaskLocationPickerScreenState();
}

class _TaskLocationPickerScreenState extends State<TaskLocationPickerScreen> {
  static const double _initialZoom = 13;
  static const double _minZoom = 3;
  static const double _maxZoom = 19;
  static const Color _textStrong = Color(0xFF1A1D2E);
  static const Color _textDefault = Color(0xFF202020);
  static const Color _strokeSoft = Color(0xFFE8E8E8);
  static const Color _success = Color(0xFF1FC16B);
  static const Color _info = Color(0xFF335CFF);

  final MapController _mapController = MapController();

  Position? _position;
  String? _address;
  double _zoom = _initialZoom;
  bool _isLoading = false;
  bool _isResolvingAddress = false;

  @override
  void initState() {
    super.initState();
    _address = _normalizeAddress(widget.initialAddress);
    if (widget.initialPosition != null) {
      _position = widget.initialPosition;
      unawaited(_resolveAddress(widget.initialPosition!));
    } else {
      unawaited(_fetchLocation());
    }
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLoading = true);
    try {
      final provider =
          widget.locationProvider ?? LocationService.getCurrentLocation;
      final position = await provider().timeout(const Duration(seconds: 20));
      if (!mounted) return;
      if (position == null) {
        _popWithError(Words.locationUnavailable.tr());
        return;
      }
      setState(() {
        _position = position;
        _isLoading = false;
      });
      unawaited(_resolveAddress(position));
    } catch (e) {
      if (!mounted) return;
      _popWithError(
        "Lokatsiyani olib bo'lmadi: ${e.toString().replaceAll('Exception: ', '')}",
      );
    }
  }

  Future<void> _resolveAddress(Position position) async {
    if (_address?.isNotEmpty == true) return;
    setState(() => _isResolvingAddress = true);
    try {
      final resolver =
          widget.locationAddressResolver ??
          (Position p) => LocationService.getAddressFromCoordinates(
            latitude: p.latitude,
            longitude: p.longitude,
          );
      final address = _normalizeAddress(await resolver(position));
      if (!mounted) return;
      setState(() {
        _address = address;
        _isResolvingAddress = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isResolvingAddress = false);
    }
  }

  void _popWithError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
    Navigator.of(context).pop();
  }

  Future<void> _confirm() async {
    final position = _position;
    if (position == null) return;

    if (_address == null) {
      await _resolveAddress(position);
      if (!mounted) return;
    }

    Navigator.of(
      context,
    ).pop(TaskLocationPickerResult(position: position, address: _address));
  }

  @override
  Widget build(BuildContext context) {
    final systemStyle = SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEAE3),
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(child: _buildMapArea()),
            _TopLocationBar(addressText: _addressText, onBack: _popBack),
            _PositionedMapControls(
              child: _MapControls(
                onZoomIn: () => _changeZoom(1),
                onZoomOut: () => _changeZoom(-1),
                onRecenter: _recenter,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ConfirmBar(
                isLoading: _isResolvingAddress,
                onConfirm: _position == null ? null : _confirm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapArea() {
    final position = _position;
    if (_isLoading || position == null) {
      return const ColoredBox(
        color: Color(0xFFEEEAE3),
        child: Center(child: CircularProgressIndicator(color: _success)),
      );
    }

    final point = LatLng(position.latitude, position.longitude);
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: point,
        initialZoom: _initialZoom,
        minZoom: _minZoom,
        maxZoom: _maxZoom,
        backgroundColor: const Color(0xFFEEEAE3),
        interactionOptions: const InteractionOptions(
          flags:
              InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom |
              InteractiveFlag.flingAnimation |
              InteractiveFlag.scrollWheelZoom,
        ),
        onPositionChanged: (camera, _) {
          _zoom = camera.zoom;
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'uz.m_gaz.mobile',
          tileProvider: NetworkTileProvider(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 44,
              height: 59,
              alignment: Alignment.topCenter,
              child: const _MapPin(),
            ),
          ],
        ),
      ],
    );
  }

  String get _addressText {
    if (_address?.isNotEmpty == true) return _address!;
    if (_isResolvingAddress || _isLoading) return Words.locationLoading.tr();

    final position = _position;
    if (position == null) return Words.locationUnavailable.tr();
    return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
  }

  void _popBack() {
    Navigator.of(context).pop();
  }

  void _changeZoom(int delta) {
    final nextZoom = (_zoom + delta).clamp(_minZoom, _maxZoom).toDouble();
    _zoom = nextZoom;
    _mapController.move(_mapController.camera.center, nextZoom);
  }

  void _recenter() {
    final position = _position;
    if (position == null) return;
    _mapController.move(LatLng(position.latitude, position.longitude), _zoom);
  }
}

class _PositionedMapControls extends StatelessWidget {
  final Widget child;

  const _PositionedMapControls({required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding = MediaQuery.paddingOf(context);
          final bottomBarHeight = 86 + padding.bottom;
          final minTop = padding.top + 120;
          final maxTop = constraints.maxHeight - bottomBarHeight - 172;
          final upperTop = maxTop < minTop ? minTop : maxTop;
          final preferredTop = constraints.maxHeight * 0.49;
          final top = preferredTop.clamp(minTop, upperTop).toDouble();

          return Stack(
            children: [Positioned(right: 20, top: top, child: child)],
          );
        },
      ),
    );
  }
}

class _TopLocationBar extends StatelessWidget {
  final String addressText;
  final VoidCallback onBack;

  const _TopLocationBar({required this.addressText, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      top: MediaQuery.paddingOf(context).top + 24,
      child: Row(
        children: [
          _MapFloatingButton(
            key: const Key('task-location-back-button'),
            size: 56,
            icon: Icons.chevron_left,
            iconSize: 28,
            onTap: onBack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              key: const Key('task-location-address-field'),
              height: 56,
              padding: const EdgeInsets.only(left: 12, right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFCFC),
                border: Border.all(
                  color: _TaskLocationPickerScreenState._strokeSoft,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFFA1A8B0), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      addressText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        height: 24 / 15,
                        fontWeight: FontWeight.w500,
                        color: _TaskLocationPickerScreenState._textDefault,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRecenter;

  const _MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC),
            borderRadius: BorderRadius.circular(24),
            boxShadow: _softShadow,
          ),
          child: Column(
            children: [
              _MapControlIcon(icon: Icons.add, onTap: onZoomIn),
              _MapControlIcon(icon: Icons.remove, onTap: onZoomOut),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _MapFloatingButton(
          key: const Key('task-location-recenter-button'),
          size: 44,
          icon: Icons.near_me,
          iconSize: 20,
          onTap: onRecenter,
        ),
      ],
    );
  }
}

class _MapControlIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapControlIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, size: 24, color: Colors.black),
      ),
    );
  }
}

class _MapFloatingButton extends StatelessWidget {
  final double size;
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;

  const _MapFloatingButton({
    super.key,
    required this.size,
    required this.icon,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFCFCFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(
              color: _TaskLocationPickerScreenState._strokeSoft,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _softShadow,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: _TaskLocationPickerScreenState._textStrong,
          ),
        ),
      ),
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onConfirm;

  const _ConfirmBar({required this.isLoading, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        14 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(color: Color(0xFFFCFCFC)),
      child: SizedBox(
        height: 56,
        child: Material(
          color: onConfirm == null || isLoading
              ? _TaskLocationPickerScreenState._success.withValues(alpha: 0.6)
              : _TaskLocationPickerScreenState._success,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            key: const Key('task-location-confirm-button'),
            onTap: isLoading ? null : onConfirm,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.near_me_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            Words.confirm.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 17,
                              height: 28 / 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 59,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const Positioned(
            top: 0,
            child: Icon(
              Icons.location_on,
              color: _TaskLocationPickerScreenState._info,
              size: 50,
            ),
          ),
          Positioned(
            top: 13,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFFFCFCFC),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 54,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: _TaskLocationPickerScreenState._info,
                border: Border.all(color: const Color(0xFFFCFCFC), width: 2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<BoxShadow> _softShadow = [
  BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
];

String? _normalizeAddress(String? address) {
  final trimmed = address?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
