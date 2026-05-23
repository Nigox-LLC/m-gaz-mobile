// import 'dart:async';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
//
// class LocationService {
//   static final LocationService _instance = LocationService._internal();
//   factory LocationService() => _instance;
//
//   LocationService._internal();
//
//   final StreamController<Position> _locationController =
//   StreamController<Position>.broadcast();
//
//   Stream<Position> get locationStream => _locationController.stream;
//
//   bool _isTracking = false;
//   List<Position> _routePoints = [];
//
//   Future<void> initialize() async {
//     // Ruxsatnomalarni so'rash
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw Exception('Lokatsiya xizmati o\'chirilgan');
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw Exception('Lokatsiya ruxsatnomasi berilmadi');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       throw Exception('Lokatsiya ruxsatnomasi butunlay rad etilgan');
//     }
//   }
//
//   void startTracking() {
//     if (_isTracking) return;
//
//     _isTracking = true;
//     _routePoints.clear();
//
//     // Har 5 soniyada lokatsiyani yangilash
//     const LocationSettings locationSettings = LocationSettings(
//       accuracy: LocationAccuracy.high,
//       distanceFilter: 10, // 10 metr harakatdan keyin yangilash
//     );
//
//     Geolocator.getPositionStream(locationSettings: locationSettings)
//         .listen((Position position) {
//       _locationController.add(position);
//       _routePoints.add(position);
//       // Serverga jo'natish (optional)
//       _sendLocationToServer(position);
//     });
//
//     // Orqa fon service'ni boshlash
//     _startBackgroundService();
//   }
//
//   void stopTracking() {
//     _isTracking = false;
//     Geolocator.getPositionStream().listen((_) {}).cancel();
//     _stopBackgroundService();
//   }
//
//   List<Position> getRoutePoints() => List.unmodifiable(_routePoints);
//
//   void clearRoute() => _routePoints.clear();
//
//   void _startBackgroundService() {
//     final service = FlutterBackgroundService();
//     service.configure(
//       iosConfiguration: IosConfiguration(
//         autoStart: true,
//         onForeground: _onBackgroundServiceStart,
//         // onBackground: _onBackgroundServiceStart,
//       ),
//       androidConfiguration: AndroidConfiguration(
//         onStart: _onBackgroundServiceStart,
//         isForegroundMode: true,
//         autoStart: true,
//       ),
//     );
//   }
//
//   void _stopBackgroundService() {
//     FlutterBackgroundService().invoke("stop");
//   }
//
//   void _onBackgroundServiceStart(ServiceInstance service) {
//     Timer.periodic(const Duration(seconds: 5), (timer) async {
//       if (service is AndroidServiceInstance) {
//         service.setForegroundNotificationInfo(
//           title: "Yo'l kuzatilmoqda",
//           content: "Lokatsiya yangilanmoqda",
//         );
//       }
//
//       // Orqa fondan ham lokatsiyani olish
//       final position = await Geolocator.getCurrentPosition();
//       _locationController.add(position);
//       _routePoints.add(position);
//     });
//   }
//
//   void _sendLocationToServer(Position position) {
//     // Bu yerda lokatsiyani serverga jo'natish logikasi
//     // Masalan: HTTP POST so'rovi
//   }
// }