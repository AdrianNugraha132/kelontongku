import 'package:flutter_test/flutter_test.dart';
import 'package:kelontongku/main.dart';

void main() {
  testWidgets('KelontongKu POS and Kasbon smoke test', (
    WidgetTester tester,
  ) async {
    // Build app
    await tester.pumpWidget(const KelontongKuApp());

    // Verify Header and Initial Item
    expect(find.text('KelontongKu'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('Minyak Goreng 1L'), findsOneWidget);
    expect(find.text('Rp 20.500'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Rp 61.500'), findsWidgets);

    // Verify Action Buttons in Bottom Bar
    expect(find.text('Bayar Tunai'), findsOneWidget);
    expect(find.text('Catat Kasbon'), findsOneWidget);

    // Tap Catat Kasbon and navigate to Kasbon Detail Screen
    await tester.tap(find.text('Catat Kasbon'));
    await tester.pumpAndSettle();

    // Verify Kasbon Detail Screen widgets
    expect(find.text('Catat Kasbon'), findsOneWidget);
    expect(find.text('Bu Ratna'), findsOneWidget);
    expect(find.text('Ibu Rumah Tangga'), findsOneWidget);
    expect(find.text('(3 pcs)'), findsOneWidget);
    expect(find.text('Total Kasbon Hari Ini'), findsOneWidget);
    expect(find.text('Kirim Rekap WA'), findsOneWidget);
  });
}
