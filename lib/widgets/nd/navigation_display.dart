import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Types of navigation points displayed on the ND.
enum WaypointType { waypoint, navaid }

/// A navigation point shown on the Navigation Display.
class Waypoint {
  final String name;

  /// True bearing in degrees from the aircraft position.
  final double bearing;

  /// Distance in nautical miles from the aircraft position.
  final double distance;

  final WaypointType type;

  const Waypoint({
    required this.name,
    required this.bearing,
    required this.distance,
    required this.type,
  });
}

/// A Navigation Display (ND) widget that shows a heading-up compass rose,
/// range rings, route lines, waypoints and the aircraft symbol.
class NavigationDisplay extends StatelessWidget {
  /// Current aircraft heading in degrees (0-360).
  final double heading;

  /// Optional aircraft latitude for future expansion.
  final double? latitude;

  /// Optional aircraft longitude for future expansion.
  final double? longitude;

  /// Selected range in nautical miles (e.g. 40).
  final double range;

  const NavigationDisplay({
    super.key,
    required this.heading,
    this.latitude,
    this.longitude,
    this.range = 40,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox.expand(
          child: CustomPaint(
            painter: _NavigationDisplayPainter(
              heading: heading,
              range: range,
              waypoints: const [
                Waypoint(
                  name: 'WPT1',
                  bearing: 200,
                  distance: 25,
                  type: WaypointType.waypoint,
                ),
                Waypoint(
                  name: 'WPT2',
                  bearing: 350,
                  distance: 15,
                  type: WaypointType.waypoint,
                ),
                Waypoint(
                  name: 'WPT3',
                  bearing: 15,
                  distance: 30,
                  type: WaypointType.waypoint,
                ),
                Waypoint(
                  name: 'ZSNB',
                  bearing: 10,
                  distance: 38,
                  type: WaypointType.navaid,
                ),
                Waypoint(
                  name: 'ZSPD',
                  bearing: 210,
                  distance: 35,
                  type: WaypointType.navaid,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavigationDisplayPainter extends CustomPainter {
  final double heading;
  final double range;
  final List<Waypoint> waypoints;

  _NavigationDisplayPainter({
    required this.heading,
    required this.range,
    required this.waypoints,
  });

  // Palette
  static const Color _background = Color(0xFF0D1B2A);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _white54 = Colors.white54;
  static const Color _white38 = Colors.white38;
  static const Color _cyan = Color(0xFF00FFFF);
  static const Color _magenta = Color(0xFFFF00FF);
  static const Color _green = Color(0xFF00FF00);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.58);
    final radius = math.min(size.width, size.height) / 2 - 16;

    _drawBackground(canvas, size);
    _drawCompassRose(canvas, center, radius);
    _drawRangeRings(canvas, center, radius);
    _drawRoute(canvas, center, radius);
    _drawWaypoints(canvas, center, radius);
    _drawAircraft(canvas, center);
    _drawHdgIndicator(canvas, size, heading);
    
    // Number badges for ND elements
    _drawBadge(canvas, '10', Offset(size.width / 2 + 40, 16));  // HDG box
    _drawBadge(canvas, '11', Offset(center.dx + radius * 0.7, center.dy - radius * 0.7)); // Compass N/E
    _drawBadge(canvas, '12', Offset(center.dx + radius * 0.5, center.dy - radius * 0.5)); // Compass degrees
    _drawBadge(canvas, '13', Offset(center.dx + 14, center.dy - 14)); // ND aircraft
    _drawBadge(canvas, '14', Offset(center.dx + radius * 0.3, center.dy + radius * 0.3)); // Range rings
    _drawBadge(canvas, '15', Offset(center.dx + radius * 0.4, center.dy - radius * 0.3)); // Waypoints
    _drawBadge(canvas, '16', Offset(center.dx - radius * 0.3, center.dy + radius * 0.4)); // Navaids
    _drawBadge(canvas, '17', Offset(center.dx - radius * 0.2, center.dy + radius * 0.2)); // Route
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = _background,
    );
  }

  void _drawCompassRose(Canvas canvas, Offset center, double radius) {
    // Outer white ring.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = _white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Tick marks and degree labels.
    for (int deg = 0; deg < 360; deg += 5) {
      final relativeAngle = _toRadians(deg - heading);

      final double tickLength;
      final double tickWidth;
      final Color tickColor;

      if (deg % 30 == 0) {
        tickLength = 18;
        tickWidth = 2.5;
        tickColor = _white;
      } else if (deg % 10 == 0) {
        tickLength = 12;
        tickWidth = 1.5;
        tickColor = _white54;
      } else {
        tickLength = 6;
        tickWidth = 1;
        tickColor = _white38;
      }

      final inner = center +
          Offset(
            (radius - tickLength) * math.sin(relativeAngle),
            -(radius - tickLength) * math.cos(relativeAngle),
          );
      final outer = center +
          Offset(
            radius * math.sin(relativeAngle),
            -radius * math.cos(relativeAngle),
          );

      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = tickColor
          ..strokeWidth = tickWidth,
      );

      // Cardinal labels.
      if (deg % 90 == 0) {
        final label = _cardinalLabel(deg);
        final labelPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: _white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        labelPainter.layout();
        final labelCenter = center +
            Offset(
              (radius - 34) * math.sin(relativeAngle),
              -(radius - 34) * math.cos(relativeAngle),
            );
        labelPainter.paint(
          canvas,
          labelCenter -
              Offset(labelPainter.width / 2, labelPainter.height / 2),
        );
      }

      // Degree numbers (skip cardinal positions and only show selected marks).
      if (_shouldShowDegreeLabel(deg)) {
        final text = deg.toString().padLeft(3, '0');
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: const TextStyle(
              color: _white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout();
        final textCenter = center +
            Offset(
              (radius - 56) * math.sin(relativeAngle),
              -(radius - 56) * math.cos(relativeAngle),
            );
        textPainter.paint(
          canvas,
          textCenter - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  String _cardinalLabel(int deg) {
    switch (deg) {
      case 0:
        return 'N';
      case 90:
        return 'E';
      case 180:
        return 'S';
      case 270:
        return 'W';
      default:
        return '';
    }
  }

  bool _shouldShowDegreeLabel(int deg) {
    if (deg % 30 != 0) return false;
    return deg != 0 && deg != 90 && deg != 180 && deg != 270;
  }

  void _drawRangeRings(Canvas canvas, Offset center, double radius) {
    final ringPaint = Paint()
      ..color = _white38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final ringFractions = [0.25, 0.50, 0.75];
    final rangeLabels = [range * 0.25, range * 0.50, range * 0.75];

    for (int i = 0; i < ringFractions.length; i++) {
      final ringRadius = radius * ringFractions[i];
      _drawDashedCircle(canvas, center, ringRadius, ringPaint);

      // Range label at the right side of each ring.
      final label = rangeLabels[i].toStringAsFixed(rangeLabels[i] % 1 == 0 ? 0 : 1);
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: _white54,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx + ringRadius + 4, center.dy - textPainter.height / 2),
      );
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const dashAngle = 6.0; // degrees
    const gapAngle = 4.0; // degrees
    const step = dashAngle + gapAngle;

    for (double start = 0; start < 360; start += step) {
      final path = Path();
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        _toRadians(start - 90),
        _toRadians(dashAngle),
      );
      canvas.drawPath(path, paint);
    }
  }

  void _drawRoute(Canvas canvas, Offset center, double radius) {
    if (waypoints.isEmpty) return;

    final routePath = Path();
    bool first = true;

    for (final wpt in waypoints.where((w) => w.type == WaypointType.waypoint)) {
      final offset = _bearingDistanceToOffset(center, radius, wpt.bearing, wpt.distance);
      if (first) {
        routePath.moveTo(offset.dx, offset.dy);
        first = false;
      } else {
        routePath.lineTo(offset.dx, offset.dy);
      }
    }

    canvas.drawPath(
      routePath,
      Paint()
        ..color = _green
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawWaypoints(Canvas canvas, Offset center, double radius) {
    for (final wpt in waypoints) {
      final offset = _bearingDistanceToOffset(center, radius, wpt.bearing, wpt.distance);

      if (wpt.type == WaypointType.navaid) {
        _drawFourPointedStar(canvas, offset, 10, _magenta);
      } else {
        _drawHexagon(canvas, offset, 8, _cyan);
      }

      final labelPainter = TextPainter(
        text: TextSpan(
          text: wpt.name,
          style: TextStyle(
            color: wpt.type == WaypointType.navaid ? _magenta : _cyan,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        offset + Offset(-labelPainter.width / 2, 12),
      );
    }
  }

  Offset _bearingDistanceToOffset(
    Offset center,
    double radius,
    double bearingDeg,
    double distanceNm,
  ) {
    final relativeBearing = bearingDeg - heading;
    final angle = _toRadians(relativeBearing);
    final distanceFraction = distanceNm / range;
    final distancePixels = distanceFraction * radius;

    return center +
        Offset(
          distancePixels * math.sin(angle),
          -distancePixels * math.cos(angle),
        );
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = _toRadians(i * 60);
      final point = center + Offset(radius * math.cos(angle), radius * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawFourPointedStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    const points = 4;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.4;
      final angle = _toRadians(i * 45 - 90);
      final point = center + Offset(r * math.cos(angle), r * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawAircraft(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = _white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path()
      ..moveTo(center.dx, center.dy - 14)
      ..lineTo(center.dx - 5, center.dy - 2)
      ..lineTo(center.dx - 14, center.dy + 2)
      ..lineTo(center.dx - 14, center.dy + 6)
      ..lineTo(center.dx - 4, center.dy + 4)
      ..lineTo(center.dx - 3, center.dy + 12)
      ..lineTo(center.dx - 6, center.dy + 16)
      ..lineTo(center.dx + 6, center.dy + 16)
      ..lineTo(center.dx + 3, center.dy + 12)
      ..lineTo(center.dx + 4, center.dy + 4)
      ..lineTo(center.dx + 14, center.dy + 6)
      ..lineTo(center.dx + 14, center.dy + 2)
      ..lineTo(center.dx + 5, center.dy - 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawHdgIndicator(Canvas canvas, Size size, double heading) {
    final boxWidth = 72.0;
    final boxHeight = 30.0;
    final topPadding = 16.0;
    final boxCenter = Offset(size.width / 2, topPadding + boxHeight / 2);

    // Black box with white border.
    final boxRect = Rect.fromCenter(
      center: boxCenter,
      width: boxWidth,
      height: boxHeight,
    );
    canvas.drawRect(
      boxRect,
      Paint()..color = Colors.black,
    );
    canvas.drawRect(
      boxRect,
      Paint()
        ..color = _white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Heading value.
    final headingText = heading.toInt().toString().padLeft(3, '0');
    final textPainter = TextPainter(
      text: TextSpan(
        text: headingText,
        style: const TextStyle(
          color: _white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      boxCenter - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // HDG label to the left of the box.
    final hdgPainter = TextPainter(
      text: const TextSpan(
        text: 'HDG',
        style: TextStyle(
          color: _cyan,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    hdgPainter.layout();
    hdgPainter.paint(
      canvas,
      Offset(
        size.width / 2 - boxWidth / 2 - hdgPainter.width - 4,
        boxCenter.dy - hdgPainter.height / 2,
      ),
    );

    // Magenta triangle below the box, pointing down at the compass.
    final triangleTop = boxCenter.dy + boxHeight / 2 + 2;
    final trianglePath = Path()
      ..moveTo(size.width / 2, triangleTop + 10)
      ..lineTo(size.width / 2 - 8, triangleTop)
      ..lineTo(size.width / 2 + 8, triangleTop)
      ..close();

    canvas.drawPath(
      trianglePath,
      Paint()..color = _magenta,
    );
  }

  void _drawBadge(Canvas canvas, String number, Offset position) {
    final paint = Paint()..color = Colors.red;
    canvas.drawCircle(position, 9, paint);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: number,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  @override
  bool shouldRepaint(covariant _NavigationDisplayPainter oldDelegate) {
    return oldDelegate.heading != heading ||
        oldDelegate.range != range ||
        oldDelegate.waypoints != waypoints;
  }
}
