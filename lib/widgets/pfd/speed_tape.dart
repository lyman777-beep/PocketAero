import 'package:flutter/material.dart';

class SpeedTape extends StatelessWidget {
  final double speed;
  final double? targetSpeed;
  final double width;
  final double height;

  const SpeedTape({
    super.key,
    required this.speed,
    this.targetSpeed,
    this.width = 75,
    this.height = 340,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          CustomPaint(
            painter: _SpeedTapePainter(
              speed: speed,
              targetSpeed: targetSpeed,
            ),
            size: Size(width, height),
          ),
          _buildSpeedLabels(),
          _buildCurrentSpeedBox(),
          _buildLabel(),
        ],
      ),
    );
  }

  double _getPixelsPerUnit() => height / (350 - 100);

  double _getCanvasOffset() {
    final pixelsPerUnit = _getPixelsPerUnit();
    final centerOffset = (speed - 100) * pixelsPerUnit;
    return centerOffset - height / 2;
  }

  Widget _buildSpeedLabels() {
    final pixelsPerUnit = _getPixelsPerUnit();
    final canvasOffset = _getCanvasOffset();
    final labels = <Widget>[];

    for (double s = 100; s <= 350; s += 20) {
      final canvasY = height - (s - 100) * pixelsPerUnit;
      final screenY = canvasY + canvasOffset;
      if (screenY < 20 || screenY > height - 20) continue;

      labels.add(
        Positioned(
          left: 4,
          top: screenY - 10,
          child: Text(
            '${s.round()}',
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

  Widget _buildCurrentSpeedBox() {
    final boxWidth = width * 0.92;
    final boxHeight = 32.0;
    final x = (width - boxWidth) / 2;
    final y = height / 2 - boxHeight / 2;

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
            '${speed.round()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel() {
    return const Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: Text(
        'SPD',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF00FF00),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SpeedTapePainter extends CustomPainter {
  final double speed;
  final double? targetSpeed;

  _SpeedTapePainter({required this.speed, this.targetSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF1A1A2E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final pixelsPerUnit = size.height / (350 - 100);
    final centerOffset = (speed - 100) * pixelsPerUnit;
    final canvasOffset = centerOffset - size.height / 2;

    canvas.save();
    canvas.translate(0, canvasOffset);

    _drawColorBands(canvas, size, pixelsPerUnit);
    _drawTicks(canvas, size, pixelsPerUnit);
    _drawTargetMarker(canvas, size, pixelsPerUnit);

    canvas.restore();
  }

  void _drawColorBands(Canvas canvas, Size size, double pixelsPerUnit) {
    final greenTop = size.height - (140 - 100) * pixelsPerUnit;
    final greenBottom = size.height - (250 - 100) * pixelsPerUnit;
    final yellowTop = size.height - (250 - 100) * pixelsPerUnit;
    final yellowBottom = size.height - (290 - 100) * pixelsPerUnit;
    final redTop = size.height - (290 - 100) * pixelsPerUnit;
    final redBottom = size.height - (350 - 100) * pixelsPerUnit;

    final greenPaint = Paint()..color = const Color(0xFF00FF00).withValues(alpha: 0.3);
    final yellowPaint = Paint()..color = const Color(0xFFFFFF00).withValues(alpha: 0.3);
    final redPaint = Paint()..color = const Color(0xFFFF0000).withValues(alpha: 0.3);

    canvas.drawRect(Rect.fromLTRB(0, greenBottom, size.width * 0.55, greenTop), greenPaint);
    canvas.drawRect(Rect.fromLTRB(0, yellowBottom, size.width * 0.55, yellowTop), yellowPaint);
    canvas.drawRect(Rect.fromLTRB(0, redBottom, size.width * 0.55, redTop), redPaint);
  }

  void _drawTicks(Canvas canvas, Size size, double pixelsPerUnit) {
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;

    for (double s = 100; s <= 350; s += 10) {
      final y = size.height - (s - 100) * pixelsPerUnit;
      if (y < -30 || y > size.height + 30) continue;

      final isMajor = s % 20 == 0;
      final tickLength = isMajor ? size.width * 0.45 : size.width * 0.2;

      canvas.drawLine(
        Offset(size.width - tickLength, y),
        Offset(size.width, y),
        tickPaint,
      );
    }
  }

  void _drawTargetMarker(Canvas canvas, Size size, double pixelsPerUnit) {
    if (targetSpeed == null) return;

    final y = size.height - (targetSpeed! - 100) * pixelsPerUnit;
    if (y < 0 || y > size.height) return;

    final markerPaint = Paint()
      ..color = const Color(0xFFFF00FF)
      ..strokeWidth = 2.5;

    canvas.drawLine(
      Offset(0, y),
      Offset(size.width * 0.35, y),
      markerPaint,
    );

    final trianglePath = Path()
      ..moveTo(size.width * 0.35, y - 8)
      ..lineTo(size.width * 0.35 + 12, y)
      ..lineTo(size.width * 0.35, y + 8)
      ..close();
    canvas.drawPath(trianglePath, markerPaint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_SpeedTapePainter old) =>
    old.speed != speed || old.targetSpeed != targetSpeed;
}
