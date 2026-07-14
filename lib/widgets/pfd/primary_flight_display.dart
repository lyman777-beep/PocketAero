import 'package:flutter/material.dart';
import '../../models/flight_data.dart';
import 'speed_tape.dart';
import 'attitude_indicator.dart';
import 'altitude_tape.dart';
import 'vertical_speed_tape.dart';
import 'heading_arc.dart';

class PrimaryFlightDisplay extends StatelessWidget {
  final FlightData data;

  const PrimaryFlightDisplay({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0D1A),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SpeedTape(
            speed: (data.speed ?? 0) * 1.94384,
            targetSpeed: data.targetSpeed,
            height: 340,
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AttitudeIndicator(
                  pitch: data.pitch,
                  roll: data.roll,
                  size: 260,
                ),
                const SizedBox(height: 4),
                HeadingArc(
                  heading: data.heading,
                  targetHeading: data.targetHeading,
                ),
              ],
            ),
          ),
          const SizedBox(width: 2),
          AltitudeTape(
            altitude: data.altitude ?? 0,
            targetAltitude: data.targetAltitude,
            height: 340,
          ),
          const SizedBox(width: 2),
          VerticalSpeedTape(
            verticalSpeed: (data.verticalSpeed ?? 0) * 196.85,
            height: 340,
          ),
        ],
      ),
    );
  }
}
