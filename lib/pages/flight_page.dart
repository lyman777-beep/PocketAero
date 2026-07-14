import 'package:flutter/material.dart';
import 'dart:async';
import '../models/flight_data.dart';
import '../services/sensor_service.dart';
import '../widgets/pfd/primary_flight_display.dart';
import '../widgets/nd/navigation_display.dart';
import '../widgets/control_panel.dart';

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
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                ControlPanel(
                  onMapPressed: () {},
                  onFmsPressed: () {},
                  onTerrPressed: () {},
                  onTfcPressed: () {},
                  onWxPressed: () {},
                  onRangeDecrease: () {},
                  onRangeIncrease: () {},
                ),
                const Positioned(
                  left: 8,
                  top: 8,
                  child: _NumberBadge('1'),
                ),
              ],
            ),
            Expanded(
              child: isLandscape
                  ? Row(
                      children: [
                        Expanded(
                          child: PrimaryFlightDisplay(data: _data),
                        ),
                        Expanded(
                          child: NavigationDisplay(heading: _data.heading),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: PrimaryFlightDisplay(data: _data),
                        ),
                        Expanded(
                          child: NavigationDisplay(heading: _data.heading),
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

class _NumberBadge extends StatelessWidget {
  final String number;
  const _NumberBadge(this.number);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
