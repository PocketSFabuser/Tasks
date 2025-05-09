import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_tasks/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const TaskManagerApp());

    // Verify that the app title is displayed
    expect(find.text('Менеджер задач'), findsOneWidget);

    // Verify that all main categories are displayed
    expect(find.text('Годовые'), findsOneWidget);
    expect(find.text('Недельные'), findsOneWidget);
    expect(find.text('Ежедневные'), findsOneWidget);

    // Verify the FAB is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Task category navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    // Tap on the 'Годовые' category
    await tester.tap(find.text('Годовые'));
    await tester.pumpAndSettle();

    // Verify we navigated to the tasks screen
    expect(find.text('Годовые'), findsOneWidget);
    expect(find.text('Нет задач. Добавьте первую!'), findsOneWidget);
  });

  testWidgets('Add date-specific task', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    // Tap the FAB to add a new date
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify date picker is shown (simplified check)
    expect(find.byType(Dialog), findsOneWidget);
  });
}