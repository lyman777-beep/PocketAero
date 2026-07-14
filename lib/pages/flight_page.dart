import 'package:flutter/material.dart';
import 'dart:async';
import '../models/flight_data.dart';
import '../services/sensor_service.dart';
import '../widgets/pfd/primary_flight_display.dart';
import '../widgets/offline_map.dart';

class FlightPage extends StatefulWidget {
  const FlightPage({super.key});

  @override
  State<FlightPage> createState() => _FlightPageState();
}

class _FlightPageState extends State<FlightPage> {
  final _sensorService = SensorService();
  FlightData _data = const FlightData(
    targetAltitude: 10000,
    targetSpeed: 250,
    targetHeading: 136,
    baroPressure: 1013,
  );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusItem('AP', const Color(0xFF00FF00)),
                  _buildStatusItem('LNAV', Colors.white54),
                  _buildStatusItem('VNAV', Colors.white54),
                  _buildStatusItem('SPD', Colors.white54),
                  const SizedBox(width: 16),
                  _buildDataItem('HDG', '${_data.heading.round()}', const Color(0xFF00FF00)),
                  _buildDataItem('ALT', '${(_data.altitude ?? 0).round()}', const Color(0xFF00FF00)),
                  _buildDataItem('VS', '${(_data.verticalSpeed ?? 0).round()}', const Color(0xFF00FF00)),
                  _buildDataItem('FPA', '0.0', const Color(0xFF00FF00)),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: PrimaryFlightDisplay(data: _data),
                  ),
                  Container(width: 1, color: Colors.white12),
                  Expanded(
                    flex: 4,
                    child: OfflineMap(
                      latitude: _data.latitude,
                      longitude: _data.longitude,
                      heading: _data.heading,
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

  Widget _buildStatusItem(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDataItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 10),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
