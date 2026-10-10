import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cinema_models.dart';
import '../services/auto_update_service.dart';
import '../state/cinema_playback_state.dart';
import '../theme/cinema_colors.dart';
import '../widgets/cinema_update_dialog.dart';


class CinemaViewerScreen extends StatelessWidget {
  const CinemaViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<CinemaPlaybackState>();
    final panel = playback.currentPanel;
    final bubble = playback.currentBubble;

    return Scaffold(
      backgroundColor: CinemaColors.bgPrimary,
      body: GestureDetector(
        onTap: () => playback.toggleOverlay(),
        child: Stack(
          children: [
            // Cinema Visual Canvas
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  color: CinemaColors.bgSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CinemaColors.bgBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: CinemaColors.brandPrimary.withAlpha(30),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.92,
                height: MediaQuery.of(context).size.height * 0.72,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Panel Visual Placeholder
                      Container(
                        color: const Color(0xFF181822),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.auto_stories,
                                size: 64,
                                color: CinemaColors.brandSecondary.withAlpha(120),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                panel != null
                                    ? 'Panel ${panel.panelId}'
                                    : 'กำลังโหลดตอน...',
                                style: const TextStyle(
                                  color: CinemaColors.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Speech Bubble Highlight Overlay
                      if (bubble != null)
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: CinemaColors.bgSurfaceGlass,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: CinemaColors.brandPrimary,
                                width: 1.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildRoleIcon(bubble.role),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    bubble.speechText,
                                    style: const TextStyle(
                                      color: CinemaColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Top Status Bar Overlay
            if (playback.showOverlay)
              Positioned(
                top: 48,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playback.chapter?.title ?? 'Manga Cinema',
                          style: const TextStyle(
                            color: CinemaColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          playback.chapter?.episodeNumber ?? 'EP. 1',
                          style: const TextStyle(
                            color: CinemaColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'ตรวจสอบอัปเดตเวอร์ชัน',
                          icon: const Icon(
                            Icons.cloud_download_outlined,
                            color: CinemaColors.textSecondary,
                            size: 22,
                          ),
                          onPressed: () async {
                            final info = await AutoUpdateService.checkForUpdate();
                            if (context.mounted) {
                              if (info != null && info.hasUpdate) {
                                CinemaUpdateDialog.show(context, info);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('คุณกำลังใช้งานเวอร์ชันล่าสุด (v${AutoUpdateService.currentVersion}) อยู่แล้ว'),
                                    backgroundColor: CinemaColors.bgSurface,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: playback.isPlaying
                                ? CinemaColors.statusSyncActive.withAlpha(40)
                                : CinemaColors.bgBorder,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                size: 10,
                                color: playback.isPlaying
                                    ? CinemaColors.statusSyncActive
                                    : CinemaColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                playback.isPlaying ? 'AI DUBBING' : 'PAUSED',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: playback.isPlaying
                                      ? CinemaColors.statusSyncActive
                                      : CinemaColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),

            // Bottom Floating Controls Overlay
            if (playback.showOverlay)
              Positioned(
                bottom: 36,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: CinemaColors.bgSurfaceGlass,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: CinemaColors.bgBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        color: CinemaColors.textSecondary,
                        onPressed: () => playback.previousPanel(),
                      ),
                      FloatingActionButton.small(
                        backgroundColor: CinemaColors.brandPrimary,
                        onPressed: () => playback.togglePlayPause(),
                        child: Icon(
                          playback.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        color: CinemaColors.textSecondary,
                        onPressed: () => playback.nextPanel(),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleIcon(DialogueRole role) {
    IconData iconData;
    Color iconColor;

    switch (role) {
      case DialogueRole.hero:
        iconData = Icons.person;
        iconColor = CinemaColors.brandPrimary;
        break;
      case DialogueRole.heroine:
        iconData = Icons.face;
        iconColor = Colors.pinkAccent;
        break;
      case DialogueRole.villain:
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.deepOrangeAccent;
        break;
      case DialogueRole.thought:
        iconData = Icons.bubble_chart;
        iconColor = CinemaColors.brandSecondary;
        break;
      case DialogueRole.narrator:
        iconData = Icons.record_voice_over;
        iconColor = CinemaColors.accentAmber;
        break;
    }

    return CircleAvatar(
      radius: 16,
      backgroundColor: iconColor.withAlpha(40),
      child: Icon(iconData, size: 18, color: iconColor),
    );
  }
}
