import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visitorappointment/core/constants/app_constants.dart';
import 'package:visitorappointment/core/theme/app_theme.dart';
import 'package:visitorappointment/features/visitor_management/presentation/widgets/status_chip.dart';

void main() {
  testWidgets('StatusChip renders status and icon properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: StatusChip(status: AppConstants.statusCheckedIn),
        ),
      ),
    );

    expect(find.text(AppConstants.statusCheckedIn), findsOneWidget);
  });
}
