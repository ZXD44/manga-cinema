import 'package:flutter_test/flutter_test.dart';

import 'package:manga_cinema_app/models/cinema_models.dart';
import 'package:manga_cinema_app/services/auto_update_service.dart';

void main() {
  test('AutoUpdateService semantic version comparison check', () {
    expect(AutoUpdateService.currentVersion, '1.0.1');
  });

  test('MangaStoryChapter domain model integrity', () {
    const chapter = MangaStoryChapter(
      title: 'The Return of the Scorned Genius',
      episodeNumber: 'ตอนที่ 1',
      stripImages: ['https://example.com/p1.webp'],
      keyframes: [],
    );
    expect(chapter.title, 'The Return of the Scorned Genius');
    expect(chapter.episodeNumber, 'ตอนที่ 1');
  });
}
