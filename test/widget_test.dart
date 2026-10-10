import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_cinema_app/main.dart';

void main() {
  testWidgets('Manga Cinema smoke test renders title and controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MangaCinemaApp());
    await tester.pumpAndSettle();

    // Verify title and episode rendered
    expect(find.text('Solo Leveling (AI Motion Demo)'), findsOneWidget);
    expect(find.text('ตอนที่ 01: การตื่นขึ้น'), findsOneWidget);

    // Verify initial playback control icons exist
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.skip_previous), findsOneWidget);
    expect(find.byIcon(Icons.skip_next), findsOneWidget);
  });
}
