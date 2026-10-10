import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_cinema_app/main.dart';

void main() {
  testWidgets('Manga Cinema renders title and controls with URL loader', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MangaCinemaApp());
    await tester.pumpAndSettle();

    // Verify title and episode rendered
    expect(find.text('The Return of the Scorned Genius'), findsOneWidget);
    expect(find.text('ตอนที่ 1 (DukeToon Edition)'), findsOneWidget);

    // Verify playback control and URL add icons exist
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
    expect(find.byIcon(Icons.add_link_rounded), findsOneWidget);
  });
}
