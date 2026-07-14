import 'package:flutter/material.dart';

class AltitudeTape extends StatelessWidget {
  final double altitude;
  final double? targetAltitude;
  final double width;
  final double height;

  const AltitudeTape({
    super.key,
    required this.altitude,
    this.targetAltitude,
    this.width = 80,
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
            painter: _AltitudeTapePainter(
              altitude: altitude,
              targetAltitude: targetAltitude,
            ),
            size: Size(width, height),
          ),
          _buildAltitudeLabels(),
          _buildCurrentAltBox(),
          _buildLabel(),
        ],
      ),
    );
  }

  double _getPixelsPerUnit() => height / (12000 - 8000);

  double _getCanvasOffset() {
    final pixelsPerUnit = _getPixelsPerUnit();
    final centerOffset = (altitude - 8000) * pixelsPerUnit;
    return centerOffset - height / 2;
  }

  Widget _buildAltitudeLabels() {
    final pixelsPerUnit = _getPixelsPerUnit();
    final canvasOffset = _getCanvasOffset();
    final labels = <Widget>[];

    for (double alt = 8000; alt <= 12000; alt += 200) {
      final canvasY = height - (alt - 8000) * pixelsPerUnit;
      final screenY = canvasY + canvasOffset;
      if (screenY < 20 || screenY > height - 20) continue;

      labels.add(
        Positioned(
          left: 42,
          top: screenY - 10,
          child: Text(
            alt.round().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Stack(children: labels);
  }

  Widget _buildCurrentAltBox() {
    final boxWidth = width * 0.92;
    final boxHeight = 32.0;
    final x = (width - boxWidth) / 2;
    final y = height / 2 - boxHeight / 2;

    final altText = altitude >= 10000
        ? (altitude / 1000).floor().toString()
        : altitude.round().toString();
    final decimalText = altitude >= 10000
        ? (altitude % 1000 / 10).floor().toString().padLeft(2, '0')
        : '';

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
          child: altitude >= 10000
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      altText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
                    fontSize: 18,
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
        'ALT',
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

class _AltitudeTapePainter extends CustomPainter {
  final double altitude;
  final double? targetAltitude;

  _AltitudeTapePainter({required this.altitude, this.targetAltitude});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF1A1A2E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final pixelsPerUnit = size.height / (12000 - 8000);
    final centerOffset = (altitude - 8000) * pixelsPerUnit;
    final canvasOffset = centerOffset - size.height / 2;

    canvas.save();
    canvas.translate(0, canvasOffset);

    _drawTicks(canvas, size, pixelsPerUnit);
    _drawTargetMarker(canvas, size, pixelsPerUnit);

    canvas.restore();
  }

  void _drawTicks(Canvas canvas, Size size, double pixelsPerUnit) {
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;

    for (double alt = 8000; alt <= 12000; alt += 100) {
      final y = size.height - (alt - 8000) * pixelsPerUnit;
      if (y < -30 || y > size.height + 30) continue;

      final isMajor = alt % 200 == 0;
      final tickLength = isMajor ? size.width * 0.45 : size.width * 0.2;

      canvas.drawLine(
        Offset(0, y),
        Offset(tickLength, y),
        tickPaint,
      );
    }
  }

  void _drawTargetMarker(Canvas canvas, Size size, double pixelsPerUnit) {
    if (targetAltitude == null) return;

    final y = size.height - (targetAltitude! - 8000) * pixelsPerUnit;
    if (y < 0 || y > size.height) return;

    final markerPaint = Paint()
      ..color = const Color(0xFFFF00FF)
      ..strokeWidth = 2.5;

    canvas.drawLine(
      Offset(size.width * 0.55, y),
      Offset(size.width, y),
      markerPaint,
    );

    final trianglePath = Path()
      ..moveTo(size.width * 0.55, y - 8)
      ..lineTo(size.width * 0.55 - 12, y)
      ..lineTo(size.width * 0.55, y + 8)
      ..close();
    canvas.drawPath(trianglePath, markerPaint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_AltitudeTapePainter old) =>
    old.altitude != altitude || old.targetAltitude != targetAltitude;
}
