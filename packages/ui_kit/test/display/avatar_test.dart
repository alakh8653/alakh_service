import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  group('Avatar', () {
    testWidgets('shows initials when name is provided and imageUrl is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Avatar(name: 'Alice Wonderland'),
          ),
        ),
      );

      expect(find.text('AW'), findsOneWidget);
    });

    testWidgets('shows single initial for one-word name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Avatar(name: 'Alice'),
          ),
        ),
      );

      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('shows "?" when name is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Avatar(),
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('shows online indicator dot when isOnline is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Avatar(name: 'Bob', isOnline: true),
          ),
        ),
      );

      // The green dot is a Container inside the Stack.
      final containers = tester.widgetList<Container>(find.byType(Container));
      final greenDot = containers.where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == UiKitColors.success;
        }
        return false;
      });

      expect(greenDot.isNotEmpty, isTrue);
    });

    testWidgets('invokes onTap callback when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Avatar(
              name: 'Carol',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Avatar));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders at the requested size', (tester) async {
      const size = 60.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Avatar(name: 'Dave', size: size)),
          ),
        ),
      );

      await tester.pump();

      // The outermost Container in Avatar has explicit width/height == size.
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Avatar),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints, isNull); // width/height set directly
      // Verify via RenderBox instead.
      final renderBox = tester.renderObject<RenderBox>(
        find
            .descendant(
              of: find.byType(Avatar),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(renderBox.size.width, equals(size));
      expect(renderBox.size.height, equals(size));
    });
  });
}
