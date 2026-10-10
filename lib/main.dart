import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cinema_models.dart';
import 'screens/cinema_viewer_screen.dart';
import 'state/cinema_playback_state.dart';
import 'theme/cinema_colors.dart';

void main() {
  runApp(const MangaCinemaApp());
}

class MangaCinemaApp extends StatelessWidget {
  const MangaCinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CinemaPlaybackState()..loadChapter(_mockInitialChapter()),
      child: MaterialApp(
        title: 'Manga Cinema',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: CinemaColors.bgPrimary,
          colorScheme: const ColorScheme.dark(
            primary: CinemaColors.brandPrimary,
            surface: CinemaColors.bgSurface,
          ),
        ),
        home: const CinemaViewerScreen(),
      ),
    );
  }

  static MangaStoryChapter _mockInitialChapter() {
    const pages = [
      WebtoonPageItem(
        pageIndex: 1,
        imageUrl:
            'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1000&q=80',
        bubbles: [
          BubbleAnnotation(
            id: 'B1',
            speechText: 'The Return of the Scorned Genius: การหวนคืนของอัจฉริยะผู้ถูกเหยียดหยาม',
            role: DialogueRole.narrator,
            boundingBox: Rect.fromLTWH(0.1, 0.05, 0.8, 0.1),
            pauseSeconds: 1.2,
          ),
        ],
      ),
      WebtoonPageItem(
        pageIndex: 2,
        imageUrl:
            'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1000&q=80',
        bubbles: [
          BubbleAnnotation(
            id: 'B2',
            speechText: 'ทำไมพวกมันถึงกล้าทรยศและเหยียบย่ำศักดิ์ศรีของข้าถึงขนาดนี้...',
            role: DialogueRole.thought,
            boundingBox: Rect.fromLTWH(0.15, 0.35, 0.7, 0.1),
            pauseSeconds: 1.2,
          ),
          BubbleAnnotation(
            id: 'B3',
            speechText: 'ข้าจะทำให้พวกมันทุกคนต้องชดใช้ด้วยชีวิต!',
            role: DialogueRole.hero,
            boundingBox: Rect.fromLTWH(0.2, 0.5, 0.6, 0.1),
            pauseSeconds: 1.5,
          ),
        ],
      ),
      WebtoonPageItem(
        pageIndex: 3,
        imageUrl:
            'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1000&q=80',
        bubbles: [
          BubbleAnnotation(
            id: 'B4',
            speechText: 'ฮ่าๆๆ! เจ้ามันก็แค่เศษสวะที่ไม่มีวันตามพวกเราทันหรอก!',
            role: DialogueRole.villain,
            boundingBox: Rect.fromLTWH(0.1, 0.75, 0.8, 0.1),
            pauseSeconds: 1.5,
          ),
        ],
      ),
    ];

    return MangaStoryChapter(
      title: 'The Return of the Scorned Genius',
      episodeNumber: 'ตอนที่ 1 (DukeToon Edition)',
      sourceUrl:
          'https://duketoon.com/content/the-return-of-the-scorned-genius/1',
      stripImages: pages.map((p) => p.imageUrl).toList(),
      pages: pages,
      keyframes: pages.map((p) {
        return PanelKeyframe(
          panelId: 'P-${p.pageIndex}',
          panelRect: Rect.fromLTWH(0.0, (p.pageIndex - 1) * 0.33, 1.0, 0.33),
          bubbles: p.bubbles,
        );
      }).toList(),
    );
  }
}
