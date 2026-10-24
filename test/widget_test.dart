import 'package:flutter_test/flutter_test.dart';
import 'package:evoqe/main.dart';

void main() {
  testWidgets('Evoqe app loads home screen components', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EvoqeApp());

    // Verify key titles and buttons render.
    expect(find.text('EVOQE'), findsOneWidget);
    expect(find.text('A world of style,\ncurated for you.'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
