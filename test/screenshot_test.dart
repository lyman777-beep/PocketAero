import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_aero/models/flight_data.dart';
import 'package:pocket_aero/widgets/pfd/primary_flight_display.dart';

void main() {
  testWidgets('PFD screenshot', (WidgetTester tester) async {
    final key = GlobalKey();
    final testData = FlightData(
      pitch: 2,
      roll: -5,
      heading: 136,
      altitude: 10000,
      speed: 119,
      verticalSpeed: 0,
      targetAltitude: 10000,
      targetSpeed: 232,
      targetHeading: 136,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: const Color(0xFF0D0D1A),
          body: Align(
            alignment: Alignment.topCenter,
            child: RepaintBoundary(
              key: key,
              child: PrimaryFlightDisplay(data: testData),
            ),
          ),
        ),
      ),
    );

    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject()!;
      final renderObject = boundary as dynamic;
      final image = await renderObject.toImage(pixelRatio: 2.0) as ui.Image;
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('pfd_preview.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());
    });
  });
}
