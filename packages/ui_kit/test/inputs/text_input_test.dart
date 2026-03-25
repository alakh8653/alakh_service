import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  group('TextInput', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInput(label: 'Email'),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInput(hint: 'Enter your email'),
          ),
        ),
      );

      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('shows error text when errorText is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInput(
              label: 'Email',
              errorText: 'Invalid email address',
            ),
          ),
        ),
      );

      expect(find.text('Invalid email address'), findsOneWidget);
    });

    testWidgets('calls onChanged when text is entered', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInput(
              label: 'Name',
              onChanged: (v) => changedValue = v,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Alice');
      await tester.pump();

      expect(changedValue, equals('Alice'));
    });

    testWidgets('is read-only when readOnly is true', (tester) async {
      final controller = TextEditingController(text: 'fixed');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInput(
              controller: controller,
              readOnly: true,
            ),
          ),
        ),
      );

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.readOnly, isTrue);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInput(
              label: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.obscureText, isTrue);
    });
  });
}
