import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders vault shell scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Kylrix Vault')),
        ),
      ),
    );

    expect(find.text('Kylrix Vault'), findsOneWidget);
  });
}
