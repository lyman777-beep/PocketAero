import 'package:flutter/material.dart';
import '../../models/flight_data.dart';
import 'attitude_indicator.dart';

class PrimaryFlightDisplay extends StatelessWidget {
  final FlightData data;

  const PrimaryFlightDisplay({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Convert m/s to knots for speed display
    final speed = (data.speed ?? 0) * 1.94384;
    final altitude = data.altitude ?? 0;
    final verticalSpeed = data.verticalSpeed ?? 0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D1A),
        border: Border(
          top: BorderSide(color: Colors.white, width: 2),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final totalHeight = constraints.maxHeight;

          if (totalWidth <= 0 || totalHeight <= 0 || totalWidth == double.infinity) {
            return const SizedBox.shrink();
          }

          // Attitude indicator fills the entire PFD area
          return AttitudeIndicator(
            pitch: data.pitch,
            roll: data.roll,
            speed: speed,
            altitude: altitude,
            verticalSpeed: verticalSpeed,
            targetSpeed: data.targetSpeed,
            targetAltitude: data.targetAltitude,
            width: totalWidth,
            height: totalHeight,
          );
        },
      ),
    );
  }
}
