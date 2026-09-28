import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/widgets/dashboard/progress_ring.dart';

void main() {
  testWidgets('ProgressRing animates to the target percentage', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressRing(progress: 0.65, centerLabel: 'This week', centerSubLabel: 'of your goals'),
        ),
      ),
    );

    // Before the animation settles, the ring starts at 0%.
    expect(find.text('0%'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('65%'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('of your goals'), findsOneWidget);
  });

  testWidgets('ProgressRing clamps progress above 1.0 to 100%', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressRing(progress: 1.4, centerLabel: 'Overachiever', centerSubLabel: ''),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('100%'), findsOneWidget);
  });
}
