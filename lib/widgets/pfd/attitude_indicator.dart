import 'dart:math';
import 'package:flutter/material.dart';

class AttitudeIndicator extends StatelessWidget {
  final double pitch;
  final double roll;
  final double speed;
  final double altitude;
  final double verticalSpeed;
  final double? targetSpeed;
  final double? targetAltitude;
  final double width;
  final double height;

  const AttitudeIndicator({
    super.key,
    required this.pitch,
    required this.roll,
    required this.speed,
    required this.altitude,
    required this.verticalSpeed,
    this.targetSpeed,
    this.targetAltitude,
    this.width = 260,
    this.height = 182,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          CustomPaint(
            painter: _AttitudePainter(
              pitch: pitch,
              roll: roll,
              verticalSpeed: verticalSpeed,
            ),
            size: Size(width, height),
          ),
          ClipRect(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: _buildPitchLabels(),
            ),
          ),
          _buildBankLabels(),
          _buildSpeedBox(),
          _buildAltBox(),
          // Number badges
          const Positioned(left: 4, top: 4, child: _PfdBadge('3')),   // Bank scale
          Positioned(left: width / 2 - 9, top: 2, child: const _PfdBadge('4')), // Bank indicator
          const Positioned(left: 4, top: 80, child: _PfdBadge('5')),  // Pitch ladder
          Positioned(left: width * 0.15 - 20, top: height * 0.5 - 9, child: const _PfdBadge('6')), // Pitch numbers left
          Positioned(left: width * 0.85 + 4, top: height * 0.5 - 9, child: const _PfdBadge('6')),  // Pitch numbers right
          Positioned(left: width / 2 - 9, top: height / 2 - 9, child: const _PfdBadge('7')), // PFD aircraft
          Positioned(left: 4, top: height * 0.5 - 30, child: const _PfdBadge('2')),  // Speed box
          Positioned(left: width - 22, top: height * 0.5 - 30, child: const _PfdBadge('8')), // Altitude box
          Positioned(left: width - 22, top: height * 0.3, child: const _PfdBadge('9')), // VS scale
        ],
      ),
    );
  }

  Widget _buildPitchLabels() {
    final centerX = width / 2;
    final centerY = height * 0.5;
    final radius = width * 0.48;
    final pitchOffset = pitch * radius / 45;
    final labels = <Widget>[];

    const pitchAngles = [-30, -20, -10, 10, 20, 30];

    for (final angle in pitchAngles) {
      final y = -angle * radius / 45 - pitchOffset;
      if (y.abs() > radius * 0.9) continue;

      final lineWidth = radius * 0.3;

      labels.add(
        Positioned(
          left: centerX - lineWidth - 22,
          top: centerY + y - 10,
          child: Text(
            '${angle.abs()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

      labels.add(
        Positioned(
          left: centerX + lineWidth + 8,
          top: centerY + y - 10,
          child: Text(
            '${angle.abs()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Stack(children: labels);
  }

  /// Bank scale labels at the TOP of the blue sky area (centered horizontally)
  Widget _buildBankLabels() {
    final centerX = width / 2;
    final radius = width * 0.48;
    final scaleRadius = radius * 0.55;
    // Arc center at top-center, raised higher
    final arcCenterX = centerX;
    final arcCenterY = 5 + scaleRadius * 0.5;
    final labels = <Widget>[];

    // Reference only shows 10° and 20° labels
    final bankAngles = [10, 20];

    for (final angle in bankAngles) {
      for (final sign in [-1, 1]) {
        final rad = (-90 + sign * angle) * pi / 180;
        final labelRadius = scaleRadius * 0.72;
        final lx = arcCenterX + cos(rad) * labelRadius;
        final ly = arcCenterY + sin(rad) * labelRadius;

        labels.add(
          Positioned(
            left: lx - 10,
            top: ly - 10,
            child: Text(
              '$angle',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
    }

    return Stack(children: labels);
  }

  /// Speed value box at left edge (box center at 1/8 of width from left)
  Widget _buildSpeedBox() {
    final boxWidth = 90.0;
    final boxHeight = 44.0;
    final arrowWidth = 16.0;
    final centerY = height * 0.5;

    // Box center at width * 0.125 from left edge (1/8)
    final boxCenterX = width * 0.125;
    final rowLeft = boxCenterX - boxWidth / 2;

    return Positioned(
      left: rowLeft,
      top: centerY - boxHeight / 2,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                width: boxWidth,
                height: boxHeight,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    '${speed.round()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          CustomPaint(
            size: Size(arrowWidth, boxHeight),
            painter: _ArrowPainter(pointRight: true),
          ),
        ],
      ),
    );
  }

  /// Altitude value box at right edge (box center at 1/8 of width from right)
  Widget _buildAltBox() {
    final boxWidth = 90.0;
    final boxHeight = 44.0;
    final arrowWidth = 16.0;
    final centerY = height * 0.5;

    // Box center at width * 0.875 from left edge (= 1/8 from right)
    final boxCenterX = width * 0.875;
    final rowLeft = boxCenterX - arrowWidth - boxWidth / 2;

    String altText;
    String? decimalText;
    if (altitude >= 10000) {
      altText = (altitude / 1000).floor().toString();
      decimalText = (altitude % 1000 / 10).floor().toString().padLeft(2, '0');
    } else {
      altText = altitude.round().toString();
    }

    return Positioned(
      left: rowLeft,
      top: centerY - boxHeight / 2,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: Size(arrowWidth, boxHeight),
            painter: _ArrowPainter(pointRight: false),
          ),
          Container(
                width: boxWidth,
                height: boxHeight,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 2.5),
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
                                fontSize: 18,
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
                            fontSize: 26,
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

class _AttitudePainter extends CustomPainter {
  final double pitch;
  final double roll;
  final double verticalSpeed;

  _AttitudePainter({
    required this.pitch,
    required this.roll,
    required this.verticalSpeed,
  });

  static const Color _skyColor = Color(0xFF1A6DD9);
  static const Color _groundColor = Color(0xFF8B5E3C);
  static const Color _magenta = Color(0xFFFF00FF);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.5;
    final radius = size.width * 0.48;

    canvas.save();

    final clipPath = Path()
      ..moveTo(0, centerY + radius)
      ..lineTo(0, centerY - radius)
      ..arcTo(
        Rect.fromCircle(center: Offset(centerX, centerY - radius), radius: radius),
        pi,
        pi,
        false,
      )
      ..lineTo(size.width, centerY - radius)
      ..lineTo(size.width, centerY + radius)
      ..close();

    canvas.clipPath(clipPath);

    canvas.translate(centerX, centerY);
    canvas.rotate(-roll * pi / 180);

    final pitchOffset = pitch * radius / 45;

    _drawSkyGround(canvas, radius, pitchOffset);
    _drawPitchLadder(canvas, radius, pitchOffset);

    canvas.restore();

    _drawAircraftSymbol(canvas, size, centerX, centerY);
    _drawBankScale(canvas, size, centerX, radius);
    _drawVSIndicator(canvas, size, centerX, centerY, radius);
  }

  void _drawSkyGround(Canvas canvas, double radius, double pitchOffset) {
    final skyRect = Rect.fromLTRB(
      -radius * 1.2,
      -radius * 1.5 - pitchOffset,
      radius * 1.2,
      -pitchOffset,
    );
    final groundRect = Rect.fromLTRB(
      -radius * 1.2,
      -pitchOffset,
      radius * 1.2,
      radius * 1.5 - pitchOffset,
    );

    canvas.drawRect(skyRect, Paint()..color = _skyColor);
    canvas.drawRect(groundRect, Paint()..color = _groundColor);

    final horizonPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5;
    canvas.drawLine(
      Offset(-radius * 1.2, -pitchOffset),
      Offset(radius * 1.2, -pitchOffset),
      horizonPaint,
    );
  }

  void _drawPitchLadder(Canvas canvas, double radius, double pitchOffset) {
    const pitchAngles = [-30, -20, -10, 10, 20, 30];

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (final angle in pitchAngles) {
      final y = -angle * radius / 45 - pitchOffset;
      if (y.abs() > radius * 0.9) continue;

      final lineWidth = radius * 0.3;

      canvas.drawLine(
        Offset(-lineWidth, y),
        Offset(-radius * 0.06, y),
        linePaint,
      );
      canvas.drawLine(
        Offset(radius * 0.06, y),
        Offset(lineWidth, y),
        linePaint,
      );
    }
  }

  void _drawAircraftSymbol(Canvas canvas, Size size, double centerX, double centerY) {
    final wingSpan = size.width * 0.2;

    final symbolPaint = Paint()
      ..color = _magenta
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // Left wing
    canvas.drawLine(
      Offset(centerX - wingSpan, centerY),
      Offset(centerX - size.width * 0.05, centerY),
      symbolPaint,
    );
    // Right wing
    canvas.drawLine(
      Offset(centerX + size.width * 0.05, centerY),
      Offset(centerX + wingSpan, centerY),
      symbolPaint,
    );

    // Center square (flight path marker)
    final squareSize = size.width * 0.045;
    final squarePaint = Paint()
      ..color = _magenta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: squareSize,
        height: squareSize,
      ),
      squarePaint,
    );
  }

  /// Bank scale at the TOP of the blue sky area (raised higher)
  void _drawBankScale(Canvas canvas, Size size, double centerX, double radius) {
    final bankAngles = [10, 20, 30, 45, 60];
    final scaleRadius = radius * 0.55;
    // Arc center at top-center, raised higher
    final arcCenterX = centerX;
    final arcCenterY = 5 + scaleRadius * 0.5;

    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (final angle in bankAngles) {
      for (final sign in [-1, 1]) {
        final rad = (-90 + sign * angle) * pi / 180;
        final inner = scaleRadius * 0.85;
        final outer = scaleRadius;

        final x1 = arcCenterX + cos(rad) * inner;
        final y1 = arcCenterY + sin(rad) * inner;
        final x2 = arcCenterX + cos(rad) * outer;
        final y2 = arcCenterY + sin(rad) * outer;

        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
      }
    }

    // Yellow triangle indicator at top center (0° / level)
    final triangleY = arcCenterY - scaleRadius;
    final trianglePaint = Paint()..color = const Color(0xFFFFFF00);
    final trianglePath = Path()
      ..moveTo(centerX - 7, triangleY - 12)
      ..lineTo(centerX + 7, triangleY - 12)
      ..lineTo(centerX, triangleY)
      ..close();
    canvas.drawPath(trianglePath, trianglePaint);
  }

  /// VS indicator: green tick marks on the right side of the attitude indicator
  void _drawVSIndicator(Canvas canvas, Size size, double centerX, double centerY, double radius) {
    final vsMax = 4000.0; // fpm, max display range
    final vsClamped = verticalSpeed.clamp(-vsMax, vsMax);
    final indicatorHeight = radius * 0.8;
    final startX = size.width - 8;

    // Draw tick marks
    final tickPaint = Paint()
      ..color = const Color(0xFF00FF00)
      ..strokeWidth = 1.5;

    // Zero line (center)
    canvas.drawLine(
      Offset(startX - 12, centerY),
      Offset(startX, centerY),
      Paint()
        ..color = const Color(0xFF00FF00)
        ..strokeWidth = 2,
    );

    // Positive ticks (up = climb)
    for (int i = 1; i <= 4; i++) {
      final y = centerY - (i / 4) * indicatorHeight / 2;
      final isMajor = i % 2 == 0;
      final tickLen = isMajor ? 10.0 : 6.0;
      canvas.drawLine(
        Offset(startX - tickLen, y),
        Offset(startX, y),
        tickPaint,
      );
    }

    // Negative ticks (down = descent)
    for (int i = 1; i <= 4; i++) {
      final y = centerY + (i / 4) * indicatorHeight / 2;
      final isMajor = i % 2 == 0;
      final tickLen = isMajor ? 10.0 : 6.0;
      canvas.drawLine(
        Offset(startX - tickLen, y),
        Offset(startX, y),
        tickPaint,
      );
    }

    // Draw current VS indicator (green triangle pointing left)
    if (vsClamped.abs() > 50) {
      final fraction = vsClamped / vsMax;
      final indicatorY = centerY - fraction * indicatorHeight / 2;
      final vsPaint = Paint()..color = const Color(0xFF00FF00);
      final vsPath = Path()
        ..moveTo(startX - 14, indicatorY)
        ..lineTo(startX - 6, indicatorY - 5)
        ..lineTo(startX - 6, indicatorY + 5)
        ..close();
      canvas.drawPath(vsPath, vsPaint);
    }
  }

  @override
  bool shouldRepaint(_AttitudePainter old) =>
      old.pitch != pitch || old.roll != roll || old.verticalSpeed != verticalSpeed;
}

/// Arrow painter for speed/altitude box pointers
class _ArrowPainter extends CustomPainter {
  final bool pointRight;

  _ArrowPainter({required this.pointRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    if (pointRight) {
      // Triangle pointing right (attached to box on left)
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height / 2);
    } else {
      // Triangle pointing left (attached to box on right)
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height / 2);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PfdBadge extends StatelessWidget {
  final String number;
  const _PfdBadge(this.number);

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
