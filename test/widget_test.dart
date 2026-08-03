// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_workout_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: RPGWorkoutApp()),
    );

    // Verify that the app loads with navigation bar.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
