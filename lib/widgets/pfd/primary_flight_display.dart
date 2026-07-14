import 'package:flutter/material.dart';
import '../../models/flight_data.dart';
import 'attitude_indicator.dart';
import 'heading_arc.dart';

class PrimaryFlightDisplay extends StatelessWidget {
  final FlightData data;

  const PrimaryFlightDisplay({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final speed = (data.speed ?? 0) * 1.94384;
    final altitude = data.altitude ?? 0;
    final attitudeSize = 440.0;
    final attHeight = attitudeSize * 0.7;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final headingHeight = (availableHeight - attHeight - 10 - 23).clamp(150.0, availableHeight);

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D1A),
            border: const Border(
              top: BorderSide(color: Colors.white, width: 2),
            ),
          ),
          padding: const EdgeInsets.only(top: 3),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white, width: 2),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: attitudeSize,
                  height: attHeight,
                  child: Stack(
                    children: [
                      AttitudeIndicator(
                        pitch: data.pitch,
                        roll: data.roll,
                        size: attitudeSize,
                      ),
                      _buildSpeedBox(speed, attitudeSize, attHeight),
                      _buildAltBox(altitude, attitudeSize, attHeight),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                HeadingArc(
                  heading: data.heading,
                  targetHeading: data.targetHeading,
                  width: attitudeSize,
                  height: headingHeight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeedBox(double speed, double attSize, double attHeight) {
    return Positioned(
      left: attSize / 4 - 50,
      top: attHeight / 2 - 25,
      child: Column(
        children: [
          const Text(
            'SPD',
            style: TextStyle(
              color: Color(0xFF00FF00),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                '${speed.round()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAltBox(double altitude, double attSize, double attHeight) {
    String altText;
    String? decimalText;
    if (altitude >= 10000) {
      altText = (altitude / 1000).floor().toString();
      decimalText = (altitude % 1000 / 10).floor().toString().padLeft(2, '0');
    } else {
      altText = altitude.round().toString();
    }

    return Positioned(
      right: 70,
      top: attHeight / 2 - 25,
      child: Column(
        children: [
          const Text(
            'ALT',
            style: TextStyle(
              color: Color(0xFF00FF00),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: 90,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: decimalText != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          altText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 0.9,
                          ),
                        ),
                        Text(
                          decimalText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 0.9,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      altText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
