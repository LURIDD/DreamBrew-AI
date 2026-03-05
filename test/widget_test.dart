import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dreambrew_ai/main.dart';

/// DreamBrew AI widget testleri
void main() {
  testWidgets('Uygulama başarıyla başlatılır', (WidgetTester tester) async {
    await tester.pumpWidget(const DreamBrewApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
