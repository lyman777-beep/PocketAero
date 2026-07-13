import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_aero/widgets/attitude_indicator.dart';
import 'package:pocket_aero/widgets/magnetic_compass.dart';

void main() {
  testWidgets('AttitudeIndicator renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: AttitudeIndicator(pitch: 0, roll: 0)),
        ),
      ),
    );
    expect(find.byType(AttitudeIndicator), findsOneWidget);
  });

  testWidgets('MagneticCompass renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: MagneticCompass(heading: 0)),
        ),
      ),
    );
    expect(find.byType(MagneticCompass), findsOneWidget);
  });
}
