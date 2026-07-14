import 'dart:math';
import 'package:flutter/material.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback? onMapPressed;
  final VoidCallback? onFmsPressed;
  final VoidCallback? onTerrPressed;
  final VoidCallback? onTfcPressed;
  final VoidCallback? onWxPressed;
  final VoidCallback? onRangeDecrease;
  final VoidCallback? onRangeIncrease;

  const ControlPanel({
    super.key,
    this.onMapPressed,
    this.onFmsPressed,
    this.onTerrPressed,
    this.onTfcPressed,
    this.onWxPressed,
    this.onRangeDecrease,
    this.onRangeIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(
          top: BorderSide(color: Colors.white12),
        ),
      ),
      child: Row(
        children: [
          // BRIGHT knob
          _buildBrightKnob(),
          const SizedBox(width: 8),
          // Mode buttons - flexible width
          Expanded(
            child: Row(
              children: [
                _buildModeButton('MAP', onMapPressed),
                _buildModeButton('FMS', onFmsPressed),
                _buildModeButton('TERR', onTerrPressed),
                _buildModeButton('TFC', onTfcPressed),
                _buildModeButton('WX', onWxPressed),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Range buttons
          _buildRangeButton('RNG \u2212', onRangeDecrease),
          const SizedBox(width: 4),
          _buildRangeButton('RNG +', onRangeIncrease),
        ],
      ),
    );
  }

  Widget _buildBrightKnob() {
    return SizedBox(
      width: 44,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'BRIGHT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 1),
          SizedBox(
            width: 28,
            height: 28,
            child: CustomPaint(
              painter: _KnobPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, VoidCallback? onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 3),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A2E),
            side: const BorderSide(color: Colors.white24),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildRangeButton(String label, VoidCallback? onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFF1A1A2E),
        side: const BorderSide(color: Colors.white24),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(label),
    );
  }
}

class _KnobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Draw knob circle
    final bgPaint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw tick marks around the perimeter
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * 3.14159 / 180;
      final innerR = radius * 0.7;
      final outerR = radius * 0.92;

      final x1 = center.dx + cos(angle) * innerR;
      final y1 = center.dy + sin(angle) * innerR;
      final x2 = center.dx + cos(angle) * outerR;
      final y2 = center.dy + sin(angle) * outerR;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }

    // Draw indicator line (white line at top)
    final indicatorPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.3),
      Offset(center.dx, center.dy - radius * 0.85),
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
