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
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AttitudePainter(pitch: pitch, roll: roll),
      ),
    );
  }
}

class _AttitudePainter extends CustomPainter {
  final double pitch;
  final double roll;

  _AttitudePainter({required this.pitch, required this.roll});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(roll * pi / 180);

    _drawGroundSky(canvas, size, radius);
    _drawPitchLadder(canvas, radius);
    _drawInstruments(canvas, radius);

    canvas.restore();
    _drawFixedElements(canvas, center, radius);
  }

  void _drawGroundSky(Canvas canvas, Size size, double radius) {
    final pitchOffset = pitch * radius / 45;
    final skyRect = Rect.fromLTRB(
      -radius, -radius - pitchOffset - radius, radius, 0 - pitchOffset,
    );
    final groundRect = Rect.fromLTRB(
      -radius, 0 - pitchOffset, radius, radius + pitchOffset + radius,
    );

    canvas.drawRect(
      skyRect,
      Paint()..color = const Color(0xFF1A6DD9),
    );
    canvas.drawRect(
      groundRect,
      Paint()..color = const Color(0xFF8B5E3C),
    );

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;
    canvas.drawLine(
      Offset(-radius, -pitchOffset),
      Offset(radius, -pitchOffset),
      linePaint,
    );
  }

  void _drawPitchLadder(Canvas canvas, double radius) {
    const pitchAngles = [-30, -20, -15, -10, -5, 0, 5, 10, 15, 20, 30];
    final pitchOffset = pitch * radius / 45;

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (final angle in pitchAngles) {
      if (angle == 0) continue;
      final y = -angle * radius / 45 - pitchOffset;
      if (y.abs() > radius * 0.85) continue;

      double lineWidth;
      if (angle % 10 == 0) {
        lineWidth = radius * 0.6;
      } else {
        lineWidth = radius * 0.3;
      }

      canvas.drawLine(
        Offset(-lineWidth / 2, y),
        Offset(lineWidth / 2, y),
        linePaint,
      );

      textPainter.text = TextSpan(
        text: '${angle.abs()}',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      );
      textPainter.layout();

      final labelX = lineWidth / 2 + 8;
      textPainter.paint(canvas, Offset(labelX, y - 5));
      textPainter.paint(canvas, Offset(-labelX - textPainter.width, y - 5));
    }
  }

  void _drawInstruments(Canvas canvas, double radius) {
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset.zero, radius, borderPaint);

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(Offset.zero, radius * 0.9, innerPaint);

    for (int i = 0; i < 360; i += 30) {
      final rad = i * pi / 180;
      final inner = radius * 0.85;
      final outer = radius * 0.9;
      canvas.drawLine(
        Offset(cos(rad) * inner, sin(rad) * inner),
        Offset(cos(rad) * outer, sin(rad) * outer),
        borderPaint,
      );
    }
  }

  void _drawFixedElements(Canvas canvas, Offset center, double radius) {
    final fixedPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    final wingSpan = radius * 0.4;
    final y = center.dy;

    path.moveTo(center.dx - wingSpan, y);
    path.lineTo(center.dx - radius * 0.15, y);
    path.moveTo(center.dx + radius * 0.15, y);
    path.lineTo(center.dx + wingSpan, y);

    path.moveTo(center.dx - radius * 0.08, y);
    path.lineTo(center.dx, y - radius * 0.06);
    path.lineTo(center.dx + radius * 0.08, y);

    canvas.drawPath(path, fixedPaint);

    final dotPaint = Paint()..color = Colors.yellow;
    canvas.drawCircle(center, 3, dotPaint);
  }

  @override
  bool shouldRepaint(_AttitudePainter old) =>
    old.pitch != pitch || old.roll != roll;
}
