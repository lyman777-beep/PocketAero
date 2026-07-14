import 'dart:math';
import 'package:flutter/material.dart';

class HeadingArc extends StatelessWidget {
  final double heading;
  final double? targetHeading;
  final double width;
  final double height;

  const HeadingArc({
    super.key,
    required this.heading,
    this.targetHeading,
    this.width = 260,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth > 0 ? constraints.maxWidth : width;
        final h = constraints.maxHeight > 0 ? constraints.maxHeight : height;

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              CustomPaint(
                painter: _HeadingArcPainter(
                  heading: heading,
                  targetHeading: targetHeading,
                ),
                size: Size(w, h),
              ),
              _buildHeadingLabels(w, h),
              _buildCurrentHeadingBox(w, h),
              _buildLabel(w, h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeadingLabels(double w, double h) {
    final centerX = w / 2;
    // Arc center is at the bottom center
    final centerY = h * 0.95;
    final radius = (w * 0.36).clamp(0.0, h * 0.5);
    final labels = <Widget>[];

    final startHeading = heading - 55;
    final endHeading = heading + 55;

    for (double hdg = startHeading; hdg <= endHeading; hdg += 30) {
      var normalizedH = hdg;
      while (normalizedH < 0) {
        normalizedH += 360;
      }
      while (normalizedH >= 360) {
        normalizedH -= 360;
      }

      // Calculate angle: 0° heading is at top (-90° in standard math)
      final angleFromTop = (normalizedH - heading) * pi / 180;
      final labelRadius = radius * 0.72;
      final lx = centerX + sin(angleFromTop) * labelRadius;
      final ly = centerY - cos(angleFromTop) * labelRadius;

      // Only show labels that are within visible area
      if (ly < 20 || ly > h - 10) continue;
      if (lx < 5 || lx > w - 5) continue;

      final label = normalizedH.round().toString().padLeft(3, '0');
      labels.add(
        Positioned(
          left: lx - 16,
          top: ly - 10,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Stack(children: labels);
  }

  Widget _buildCurrentHeadingBox(double w, double h) {
    final boxWidth = 56.0;
    final boxHeight = 24.0;
    final x = w / 2 - boxWidth / 2;
    // Position below the HDG label
    final y = 20.0;

    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: boxWidth,
        height: boxHeight,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            heading.round().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(double w, double h) {
    return Positioned(
      top: 2,
      left: w / 2 - 16,
      child: const Text(
        'HDG',
        style: TextStyle(
          color: Color(0xFF00FFFF),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _HeadingArcPainter extends CustomPainter {
  final double heading;
  final double? targetHeading;

  _HeadingArcPainter({required this.heading, this.targetHeading});

  static const double _arcSpan = 110;
  static const double _tickInterval = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    // Arc center at the bottom
    final centerY = size.height * 0.95;
    final radius = (size.width * 0.36).clamp(0.0, size.height * 0.5);

    _drawArc(canvas, centerX, centerY, radius);
    _drawTicks(canvas, centerX, centerY, radius);
    _drawTargetMarker(canvas, centerX, centerY, radius);
    _drawHeadingPointer(canvas, centerX, centerY, radius);
  }

  void _drawArc(Canvas canvas, double centerX, double centerY, double radius) {
    final arcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw arc: from left (-45°) to right (+45°), curving upward
    // In Flutter's coordinate system, -pi/2 is up
    final startAngle = -pi / 2 - (_arcSpan / 2) * pi / 180;
    final sweepAngle = _arcSpan * pi / 180;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  void _drawTicks(Canvas canvas, double centerX, double centerY, double radius) {
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;

    final startHeading = heading - _arcSpan / 2;
    final endHeading = heading + _arcSpan / 2;

    for (double h = startHeading; h <= endHeading; h += _tickInterval) {
      var normalizedH = h;
      while (normalizedH < 0) {
        normalizedH += 360;
      }
      while (normalizedH >= 360) {
        normalizedH -= 360;
      }

      // Angle from top (12 o'clock), going clockwise
      final angleFromTop = (normalizedH - heading) * pi / 180;
      final outerRadius = radius;

      final isMajor = normalizedH % 30 == 0;
      final tickLength = isMajor ? radius * 0.15 : radius * 0.08;

      final x1 = centerX + sin(angleFromTop) * (outerRadius - tickLength);
      final y1 = centerY - cos(angleFromTop) * (outerRadius - tickLength);
      final x2 = centerX + sin(angleFromTop) * outerRadius;
      final y2 = centerY - cos(angleFromTop) * outerRadius;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }
  }

  void _drawTargetMarker(Canvas canvas, double centerX, double centerY, double radius) {
    if (targetHeading == null) return;

    final angleFromTop = (targetHeading! - heading) * pi / 180;
    final markerRadius = radius * 0.82;
    final x = centerX + sin(angleFromTop) * markerRadius;
    final y = centerY - cos(angleFromTop) * markerRadius;

    final markerPaint = Paint()..color = const Color(0xFFFF00FF);
    final trianglePath = Path()
      ..moveTo(x - 6, y + 6)
      ..lineTo(x + 6, y + 6)
      ..lineTo(x, y - 6)
      ..close();
    canvas.drawPath(trianglePath, markerPaint);
  }

  void _drawHeadingPointer(Canvas canvas, double centerX, double centerY, double radius) {
    // Draw a magenta diamond at the top of the arc (current heading = 0° offset)
    final pointerY = centerY - radius;
    final pointerPaint = Paint()..color = const Color(0xFFFF00FF);

    // Diamond shape
    final diamondPath = Path()
      ..moveTo(centerX, pointerY - 6)    // top
      ..lineTo(centerX + 6, pointerY)     // right
      ..lineTo(centerX, pointerY + 6)     // bottom
      ..lineTo(centerX - 6, pointerY)     // left
      ..close();
    canvas.drawPath(diamondPath, pointerPaint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_HeadingArcPainter old) =>
    old.heading != heading || old.targetHeading != targetHeading;
}
