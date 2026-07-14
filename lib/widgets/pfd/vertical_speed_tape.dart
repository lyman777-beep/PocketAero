import 'package:flutter/material.dart';

class VerticalSpeedTape extends StatelessWidget {
  final double verticalSpeed;
  final double width;
  final double height;

  const VerticalSpeedTape({
    super.key,
    required this.verticalSpeed,
    this.width = 60,
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
            painter: _VerticalSpeedTapePainter(verticalSpeed: verticalSpeed),
            size: Size(width, height),
          ),
          _buildVSLabels(),
          _buildCurrentVSBox(),
          _buildLabel(),
        ],
      ),
    );
  }

  double _getPixelsPerUnit() => height / (6000 - (-6000));

  double _getCanvasOffset() {
    final pixelsPerUnit = _getPixelsPerUnit();
    final centerOffset = (verticalSpeed - (-6000)) * pixelsPerUnit;
    return centerOffset - height / 2;
  }

  Widget _buildVSLabels() {
    final pixelsPerUnit = _getPixelsPerUnit();
    final canvasOffset = _getCanvasOffset();
    final labels = <Widget>[];

    for (double vs = -6000; vs <= 6000; vs += 2000) {
      if (vs == 0) continue;
      final canvasY = height - (vs - (-6000)) * pixelsPerUnit;
      final screenY = canvasY + canvasOffset;
      if (screenY < 20 || screenY > height - 20) continue;

      labels.add(
        Positioned(
          left: 35,
          top: screenY - 10,
          child: Text(
            (vs / 1000).round().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Stack(children: labels);
  }

  Widget _buildCurrentVSBox() {
    final boxWidth = width * 0.95;
    final boxHeight = 28.0;
    final x = (width - boxWidth) / 2;
    final y = height / 2 - boxHeight / 2;

    final vsText = verticalSpeed >= 0
        ? '+${(verticalSpeed / 100).round()}'
        : '${(verticalSpeed / 100).round()}';

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
            vsText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel() {
    return Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: Column(
        children: const [
          Text(
            'VS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF00FF00),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'FPM',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF00FF00),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalSpeedTapePainter extends CustomPainter {
  final double verticalSpeed;

  _VerticalSpeedTapePainter({required this.verticalSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF1A1A2E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final pixelsPerUnit = size.height / (6000 - (-6000));
    final centerOffset = (verticalSpeed - (-6000)) * pixelsPerUnit;
    final canvasOffset = centerOffset - size.height / 2;

    canvas.save();
    canvas.translate(0, canvasOffset);

    _drawTicks(canvas, size, pixelsPerUnit);

    canvas.restore();
  }

  void _drawTicks(Canvas canvas, Size size, double pixelsPerUnit) {
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;

    for (double vs = -6000; vs <= 6000; vs += 1000) {
      final y = size.height - (vs - (-6000)) * pixelsPerUnit;
      if (y < -30 || y > size.height + 30) continue;

      final isMajor = vs % 2000 == 0;
      final tickLength = isMajor ? size.width * 0.55 : size.width * 0.25;

      canvas.drawLine(
        Offset(0, y),
        Offset(tickLength, y),
        tickPaint,
      );
    }

    final zeroY = size.height - (0 - (-6000)) * pixelsPerUnit;
    final zeroPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, zeroY),
      Offset(size.width * 0.65, zeroY),
      zeroPaint,
    );
  }

  @override
  bool shouldRepaint(_VerticalSpeedTapePainter old) =>
    old.verticalSpeed != verticalSpeed;
}
