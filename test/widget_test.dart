import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/models/task.dart';

void main() {
  setUpAll(() async {
    Hive.init("test_path");
    Hive.registerAdapter(TaskAdapter());
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('My Tasks'), findsOneWidget);

    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  tearDownAll(() async {
    await Hive.close();
  });
}
