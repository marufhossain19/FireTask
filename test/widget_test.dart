import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FirebaseTaskManagerApp());
    expect(find.text('Firebase Task Manager'), findsWidgets);
  });
}
