import 'package:flutter/material.dart';
import 'dart:async';
import '../models/flight_data.dart';
import '../services/sensor_service.dart';
import '../widgets/attitude_indicator.dart';
import '../widgets/magnetic_compass.dart';
import '../widgets/offline_map.dart';

class FlightPage extends StatefulWidget {
  const FlightPage({super.key});

  @override
  State<FlightPage> createState() => _FlightPageState();
}

class _FlightPageState extends State<FlightPage> {
  final _sensorService = SensorService();
  FlightData _data = const FlightData();
  StreamSubscription<FlightData>? _sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _sensorService.initialize();
    _sub = _sensorService.dataStream.listen((data) {
      if (mounted) setState(() => _data = data);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sensorService.dispose();
    super.dispose();
  }

  Widget _buildDataRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  const Spacer(),
                  AttitudeIndicator(
                    pitch: _data.pitch,
                    roll: _data.roll,
                    size: 200,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MagneticCompass(
                        heading: _data.heading,
                        size: 140,
                      ),
                      const SizedBox(height: 8),
                      _buildDataRow(
                        'HDG',
                        '${_data.heading.round()}°',
                      ),
                      _buildDataRow(
                        'PITCH',
                        '${_data.pitch.toStringAsFixed(1)}°',
                      ),
                      _buildDataRow(
                        'ROLL',
                        '${_data.roll.toStringAsFixed(1)}°',
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Container(
              height: 1,
              color: Colors.white12,
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: OfflineMap(
                      latitude: _data.latitude,
                      longitude: _data.longitude,
                      heading: _data.heading,
                    ),
                  ),
                  Container(
                    width: 1,
                    color: Colors.white12,
                  ),
                  Container(
                    width: 110,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDataRow(
                          'ALT',
                          _data.altitude != null
                              ? '${_data.altitude!.round()}m'
                              : '---',
                          color: const Color(0xFF00FF88),
                        ),
                        _buildDataRow(
                          'SPD',
                          _data.speed != null
                              ? '${(_data.speed! * 3.6).round()}km/h'
                              : '---',
                          color: const Color(0xFF00D4FF),
                        ),
                        _buildDataRow(
                          'V/S',
                          _data.verticalSpeed != null
                              ? '${_data.verticalSpeed!.round()}m/s'
                              : '---',
                        ),
                        _buildDataRow(
                          'SAT',
                          '${_data.satelliteCount ?? 0}',
                        ),
                        const Spacer(),
                        Center(
                          child: Text(
                            'POCKET AERO',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 9,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
