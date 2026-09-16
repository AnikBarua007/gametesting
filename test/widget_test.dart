import 'package:flutter_test/flutter_test.dart';
import 'package:design/main.dart';

void main() {
  testWidgets('game home shows discovery content', (tester) async {
    await tester.pumpWidget(const PlayPalApp());

    expect(find.text('Dive into the Action'), findsOneWidget);
    expect(find.text('HIDDEN\nHAND'), findsOneWidget);
    expect(find.text('QUICK JOIN NOW'), findsOneWidget);
  });
}
