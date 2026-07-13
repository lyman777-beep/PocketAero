import 'dart:math';
import 'package:flutter/material.dart';

class MagneticCompass extends StatelessWidget {
  final double heading;
  final double size;

  const MagneticCompass({
    super.key,
    required this.heading,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassPainter(heading: heading),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double heading;

  _CompassPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    _drawOuterRing(canvas, center, radius);
    _drawCardinalLabels(canvas, center, radius);
    _drawTickMarks(canvas, center, radius);
    _drawNeedle(canvas, center, radius);
    _drawHeadingLabel(canvas, center, radius);
  }

  void _drawOuterRing(Canvas canvas, Offset center, double radius) {
    final bgPaint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final borderPaint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawCardinalLabels(Canvas canvas, Offset center, double radius) {
    final directions = [
      ('N', heading),
      ('E', heading - 90),
      ('S', heading - 180),
      ('W', heading - 270),
    ];

    for (final (label, angle) in directions) {
      final rad = angle * pi / 180;
      final textCenter = Offset(
        center.dx + sin(rad) * (radius * 0.62),
        center.dy - cos(rad) * (radius * 0.62),
      );

      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: label == 'N' ? Colors.red : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(
          textCenter.dx - painter.width / 2,
          textCenter.dy - painter.height / 2,
        ),
      );
    }
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final majorPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    final minorPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1;

    for (int deg = 0; deg < 360; deg += 5) {
      final rad = (deg - heading + 90) * pi / 180;
      final isMajor = deg % 30 == 0;
      final isMinor = deg % 10 == 0;

      final inner = radius * (isMajor ? 0.75 : isMinor ? 0.78 : 0.82);
      final outer = radius * 0.85;

      canvas.drawLine(
        Offset(center.dx + cos(rad) * inner, center.dy + sin(rad) * inner),
        Offset(center.dx + cos(rad) * outer, center.dy + sin(rad) * outer),
        isMajor ? majorPaint : minorPaint,
      );

      if (isMajor && deg % 30 == 0 && deg % 90 != 0) {
        _drawSmallLabel(canvas, deg, center, radius);
      }
    }
  }

  void _drawSmallLabel(Canvas canvas, int deg, Offset center, double radius) {
    final labelMap = {30: '30', 60: '60', 120: '120', 150: '150',
      210: '210', 240: '240', 300: '300', 330: '330'};
    final label = labelMap[deg];
    if (label == null) return;

    final rad = (deg - heading + 90) * pi / 180;
    final textPos = Offset(
      center.dx + cos(rad) * (radius * 0.58),
      center.dy + sin(rad) * (radius * 0.58),
    );

    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(textPos.dx - painter.width / 2, textPos.dy - painter.height / 2),
    );
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    final needlePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.65),
      Offset(center.dx, center.dy),
      needlePaint,
    );

    final whitePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx, center.dy + radius * 0.65),
      whitePaint,
    );

    final circlePaint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.08, circlePaint);

    final ringPaint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.08, ringPaint);
  }

  void _drawHeadingLabel(Canvas canvas, Offset center, double radius) {
    final painter = TextPainter(
      text: TextSpan(
        text: '${heading.round()}°',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(
        center.dx - painter.width / 2,
        center.dy + radius * 0.25,
      ),
    );
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.heading != heading;
}
