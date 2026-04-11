import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hush/main.dart';
import 'package:hush/services/app_state.dart';

void main() {
  testWidgets('App smoke test — renders without crashing',
      (WidgetTester tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const HushApp(),
      ),
    );

    // App should render at least the nav bar
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}