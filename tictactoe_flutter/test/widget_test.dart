import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_flutter/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());
    expect(find.byType(TicTacToeApp), findsOneWidget);
  });
}
