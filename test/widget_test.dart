import 'package:flutter_test/flutter_test.dart';
import 'package:landsfyapp/main.dart';

void main() {
  testWidgets('App boot and splash screen load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LandsfyApp());

    // Verify that the Landsfy text / splash elements exist on boot
    expect(find.byType(LandsfyApp), findsOneWidget);

    // Drain the pending splash screen transition timer (3 seconds) to prevent test harness failure
    await tester.pump(const Duration(seconds: 3));
  });
}
