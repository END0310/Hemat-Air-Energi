import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/main.dart';

void main() {
  testWidgets('App smoke test - renders without errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HematAirEnergiApp());
    expect(find.byType(HematAirEnergiApp), findsOneWidget);
  });
}
