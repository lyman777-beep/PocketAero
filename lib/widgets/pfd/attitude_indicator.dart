import 'dart:math';
import 'package:flutter/material.dart';

class AttitudeIndicator extends StatelessWidget {
  final double pitch;
  final double roll;
  final double size;

  const AttitudeIndicator({
    super.key,
    required this.pitch,
    required this.roll,
    this.size = 260,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.7,
      child: Stack(
        children: [
          CustomPaint(
            painter: _AttitudePainter(
              pitch: pitch,
              roll: roll,
            ),
            size: Size(size, size * 0.7),
          ),
          ClipRect(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: _buildPitchLabels(),
            ),
          ),
          _buildBankLabels(),
        ],
      ),
    );
  }

  Widget _buildPitchLabels() {
    final centerX = size / 2;
    final centerY = size * 0.7 * 0.55;
    final radius = size * 0.48;
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

  Widget _buildBankLabels() {
    final centerX = size / 2;
    final radius = size * 0.48;
    final scaleRadius = radius * 0.65;
    final arcCenterY = 15 + scaleRadius;
    final labels = <Widget>[];

    final bankAngles = [10, 20, 30];

    for (final angle in bankAngles) {
      for (final sign in [-1, 1]) {
        final rad = (-90 + sign * angle) * pi / 180;
        final labelRadius = scaleRadius * 0.72;
        final lx = centerX + cos(rad) * labelRadius;
        final ly = arcCenterY + sin(rad) * labelRadius;

        labels.add(
          Positioned(
            left: lx - 10,
            top: ly - 10,
            child: Text(
              '$angle',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
    }

    return Stack(children: labels);
  }
}

class _AttitudePainter extends CustomPainter {
  final double pitch;
  final double roll;

  _AttitudePainter({
    required this.pitch,
    required this.roll,
  });

  static const Color _skyColor = Color(0xFF1A6DD9);
  static const Color _groundColor = Color(0xFF8B5E3C);
  static const Color _magenta = Color(0xFFFF00FF);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.55;
    final radius = size.width * 0.48;

    canvas.save();

    final clipPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, centerY - radius)
      ..arcTo(
        Rect.fromCircle(center: Offset(centerX, centerY - radius), radius: radius),
        pi,
        pi,
        false,
      )
      ..lineTo(size.width, size.height)
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

    canvas.drawLine(
      Offset(centerX - wingSpan, centerY),
      Offset(centerX - size.width * 0.05, centerY),
      symbolPaint,
    );
    canvas.drawLine(
      Offset(centerX + size.width * 0.05, centerY),
      Offset(centerX + wingSpan, centerY),
      symbolPaint,
    );

    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(centerX, centerY - size.height * 0.15),
      symbolPaint,
    );

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

  void _drawBankScale(Canvas canvas, Size size, double centerX, double radius) {
    final bankAngles = [10, 20, 30, 45, 60];
    final scaleRadius = radius * 0.65;
    final arcCenterY = 15 + scaleRadius;

    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (final angle in bankAngles) {
      for (final sign in [-1, 1]) {
        final rad = (-90 + sign * angle) * pi / 180;
        final inner = scaleRadius * 0.85;
        final outer = scaleRadius;

        final x1 = centerX + cos(rad) * inner;
        final y1 = arcCenterY + sin(rad) * inner;
        final x2 = centerX + cos(rad) * outer;
        final y2 = arcCenterY + sin(rad) * outer;

        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
      }
    }

    final triangleY = arcCenterY - scaleRadius;
    final trianglePaint = Paint()..color = const Color(0xFFFFFF00);
    final trianglePath = Path()
      ..moveTo(centerX - 7, triangleY - 12)
      ..lineTo(centerX + 7, triangleY - 12)
      ..lineTo(centerX, triangleY)
      ..close();
    canvas.drawPath(trianglePath, trianglePaint);
  }

  @override
  bool shouldRepaint(_AttitudePainter old) =>
    old.pitch != pitch || old.roll != roll;
}
