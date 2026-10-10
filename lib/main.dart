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
    return const MangaStoryChapter(
      title: 'Solo Leveling (AI Motion Demo)',
      episodeNumber: 'ตอนที่ 01: การตื่นขึ้น',
      stripImages: [],
      keyframes: [
        PanelKeyframe(
          panelId: 'P1-01',
          panelRect: Rect.fromLTWH(0.0, 0.0, 1.0, 0.3),
          bubbles: [
            BubbleAnnotation(
              id: 'B1',
              speechText: 'ในโลกที่เต็มไปด้วยดันเจี้ยนและมอนสเตอร์...',
              role: DialogueRole.narrator,
              boundingBox: Rect.fromLTWH(0.1, 0.05, 0.8, 0.1),
              pauseSeconds: 1.2,
            ),
          ],
        ),
        PanelKeyframe(
          panelId: 'P1-02',
          panelRect: Rect.fromLTWH(0.0, 0.3, 1.0, 0.4),
          bubbles: [
            BubbleAnnotation(
              id: 'B2',
              speechText: 'ทำไมฉันถึงอ่อนแอขนาดนี้กันนะ...',
              role: DialogueRole.thought,
              boundingBox: Rect.fromLTWH(0.15, 0.35, 0.7, 0.1),
              pauseSeconds: 1.0,
            ),
            BubbleAnnotation(
              id: 'B3',
              speechText: 'ระวังข้างหลัง! มันกำลังพุ่งเข้ามาแล้ว!',
              role: DialogueRole.hero,
              boundingBox: Rect.fromLTWH(0.2, 0.5, 0.6, 0.1),
              pauseSeconds: 1.5,
            ),
          ],
        ),
        PanelKeyframe(
          panelId: 'P1-03',
          panelRect: Rect.fromLTWH(0.0, 0.7, 1.0, 0.3),
          bubbles: [
            BubbleAnnotation(
              id: 'B4',
              speechText: 'ยอมจำนนซะเถอะ เจ้าฮันเตอร์ระดับ E!',
              role: DialogueRole.villain,
              boundingBox: Rect.fromLTWH(0.1, 0.75, 0.8, 0.1),
              pauseSeconds: 1.5,
            ),
          ],
        ),
      ],
    );
  }
}
