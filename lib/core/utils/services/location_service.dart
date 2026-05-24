import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    } catch (e) {
      throw Exception('Joylashuvni olishda xatolik: $e');
    }
  }

  static String generateYandexMapsLink(double lat, double lon) {
    return 'https://yandex.com/maps/?pt=$lon,$lat&z=16&l=map';
  }

  static Future<String?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'zoom': '18',
      'addressdetails': '1',
      'accept-language': 'uz',
    });

    try {
      final response = await http
          .get(
            uri,
            headers: const {
              'User-Agent': 'm-gaz-mobile/1.0 (task-location-address)',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) return null;

      final address = body['address'];
      if (address is Map<String, dynamic>) {
        final formattedAddress = _formatAddressParts(address);
        if (formattedAddress != null) return formattedAddress;
      }

      final displayName = body['display_name']?.toString().trim();
      return displayName?.isEmpty == true ? null : displayName;
    } catch (_) {
      return null;
    }
  }

  static String? _formatAddressParts(Map<String, dynamic> address) {
    final parts = <String>[];

    _addUniquePart(
      parts,
      _normalizeAdministrativeName(
        _firstAddressValue(address, const ['state', 'province', 'region']),
      ),
    );
    _addUniquePart(
      parts,
      _normalizeAdministrativeName(
        _firstAddressValue(address, const [
          'county',
          'district',
          'municipality',
          'city_district',
          'state_district',
        ]),
      ),
    );
    _addUniquePart(
      parts,
      _firstAddressValue(address, const [
        'village',
        'town',
        'city',
        'suburb',
        'neighbourhood',
        'hamlet',
      ]),
    );
    _addUniquePart(parts, _firstAddressValue(address, const ['road']));

    return parts.isEmpty ? null : parts.join(', ');
  }

  static String? _firstAddressValue(
    Map<String, dynamic> address,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = address[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static String? _normalizeAdministrativeName(String? value) {
    return value
        ?.replaceAll(RegExp(r'\bRegion\b', caseSensitive: false), 'viloyati')
        .replaceAll(RegExp(r'\bDistrict\b', caseSensitive: false), 'tumani')
        .trim();
  }

  static void _addUniquePart(List<String> parts, String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return;

    final comparable = normalized.toLowerCase();
    final alreadyExists = parts.any((part) {
      final existing = part.toLowerCase();
      return existing == comparable ||
          existing.contains(comparable) ||
          comparable.contains(existing);
    });
    if (!alreadyExists) parts.add(normalized);
  }
}
