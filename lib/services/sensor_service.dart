import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../models/flight_data.dart';

class SensorService {
  StreamSubscription? _accelerometerSub;
  StreamSubscription? _gyroscopeSub;
  StreamSubscription? _magnetometerSub;
  StreamSubscription<Position>? _gpsSub;

  double _pitch = 0;
  double _roll = 0;
  double _heading = 0;
  double _filteredPitch = 0;
  double _filteredRoll = 0;
  double _filteredHeading = 0;

  double? _latitude;
  double? _longitude;
  double? _altitude;
  double? _speed;
  double? _verticalSpeed;
  int? _satelliteCount;

  final _controller = StreamController<FlightData>.broadcast();
  Stream<FlightData> get dataStream => _controller.stream;

  static const _lowPassAlpha = 0.15;

  Future<bool> initialize() async {
    await _initGPS();
    _initSensors();
    return true;
  }

  Future<void> _initGPS() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 1,
    );

    _gpsSub = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((pos) {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
      _altitude = pos.altitude;
      _speed = pos.speed;
      _verticalSpeed = pos.speed * sin(_pitch * pi / 180);
      _satelliteCount = pos.isMocked ? null : 12;
      _emit();
    });
  }

  void _initSensors() {
    _accelerometerSub = accelerometerEventStream(
      samplingPeriod: Duration.zero,
    ).listen((event) {
      final x = event.x;
      final y = event.y;
      final z = event.z;

      final pitch = atan2(-x, sqrt(y * y + z * z)) * 180 / pi;
      final roll = atan2(y, z) * 180 / pi;

      _filteredPitch = _lowPass(_filteredPitch, pitch);
      _filteredRoll = _lowPass(_filteredRoll, roll);
      _pitch = _filteredPitch;
      _roll = _filteredRoll;
    });

    _magnetometerSub = magnetometerEventStream(
      samplingPeriod: Duration.zero,
    ).listen((event) {
      final heading = atan2(event.y, event.x) * 180 / pi;
      var h = 90 - heading;
      if (h < 0) h += 360;
      if (h >= 360) h -= 360;

      _filteredHeading = _lowPass(_filteredHeading, h);
      _heading = _filteredHeading;
    });
  }

  double _lowPass(double previous, double current) {
    return previous + _lowPassAlpha * (current - previous);
  }

  void _emit() {
    _controller.add(FlightData(
      pitch: _pitch,
      roll: _roll,
      heading: _heading,
      latitude: _latitude,
      longitude: _longitude,
      altitude: _altitude,
      speed: _speed,
      verticalSpeed: _verticalSpeed,
      satelliteCount: _satelliteCount,
    ));
  }

  void dispose() {
    _accelerometerSub?.cancel();
    _gyroscopeSub?.cancel();
    _magnetometerSub?.cancel();
    _gpsSub?.cancel();
    _controller.close();
  }
}
