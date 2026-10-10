import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cinema_models.dart';
import '../services/auto_update_service.dart';
import '../state/cinema_playback_state.dart';
import '../theme/cinema_colors.dart';
import '../widgets/cinema_update_dialog.dart';

class CinemaViewerScreen extends StatefulWidget {
  const CinemaViewerScreen({super.key});

  @override
  State<CinemaViewerScreen> createState() => _CinemaViewerScreenState();
}

class _CinemaViewerScreenState extends State<CinemaViewerScreen> {
  final ScrollController _verticalScrollController = ScrollController();
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _showUrlInputDialog(BuildContext context) {
    _urlController.text =
        'https://duketoon.com/content/the-return-of-the-scorned-genius/1';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: CinemaColors.bgSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: CinemaColors.brandPrimary.withAlpha(90),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: CinemaColors.brandPrimary.withAlpha(50),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CinemaColors.brandPrimary.withAlpha(35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.link_rounded,
                        color: CinemaColors.brandPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'เปิดเว็บตูนจาก Web URL',
                            style: TextStyle(
                              color: CinemaColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'รองรับ DukeToon, MangaPlus, หรือ Webtoon URL',
                            style: TextStyle(
                              color: CinemaColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _urlController,
                  style: const TextStyle(
                    color: CinemaColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'https://duketoon.com/content/.../1',
                    hintStyle: const TextStyle(color: CinemaColors.textMuted),
                    filled: true,
                    fillColor: CinemaColors.bgPrimary,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: CinemaColors.bgBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: CinemaColors.bgBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: CinemaColors.brandPrimary,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CinemaColors.textSecondary,
                          side: const BorderSide(color: CinemaColors.bgBorder),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        child: const Text('ยกเลิก'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CinemaColors.brandPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final targetUrl = _urlController.text.trim();
                          if (targetUrl.isNotEmpty) {
                            final messenger = ScaffoldMessenger.of(context);
                            final playback = context.read<CinemaPlaybackState>();
                            Navigator.of(dialogCtx).pop();
                            final ok = await playback.loadFromWebtoonUrl(targetUrl);
                            if (mounted && ok) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'โหลดสำเร็จ: ${playback.chapter?.title ?? ""}',
                                  ),
                                  backgroundColor: CinemaColors.statusSyncActive,
                                ),
                              );
                            }
                          }
                        },

                        child: const Text(
                          'เริ่มดูภาพยนตร์',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _animateScrollToActivePanel(int panelIndex) {
    if (!_verticalScrollController.hasClients) return;
    final targetOffset = panelIndex * 520.0;
    _verticalScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<CinemaPlaybackState>();
    final chapter = playback.chapter;
    final bubble = playback.currentBubble;

    // เลื่อนกล้องตามช่องที่กำลังเล่นอัตโนมัติ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (playback.isPlaying) {
        _animateScrollToActivePanel(playback.currentPanelIndex);
      }
    });

    return Scaffold(
      backgroundColor: CinemaColors.bgPrimary,
      body: GestureDetector(
        onTap: () => playback.toggleOverlay(),
        child: Stack(
          children: [
            // 1. Vertical Webtoon Strip Canvas with Auto-Scroll & High Quality Images
            if (playback.isLoadingUrl)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: CinemaColors.brandPrimary),
                    SizedBox(height: 16),
                    Text(
                      'กำลังดึงรูปภาพและสังเคราะห์เสียงจาก URL...',
                      style: TextStyle(
                        color: CinemaColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else if (chapter != null && chapter.pages.isNotEmpty)
              ListView.builder(
                controller: _verticalScrollController,
                padding: const EdgeInsets.symmetric(vertical: 90),
                itemCount: chapter.pages.length,
                itemBuilder: (context, index) {
                  final pageItem = chapter.pages[index];
                  final isActivePanel = playback.currentPanelIndex == index;

                  return Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 680),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isActivePanel
                              ? CinemaColors.brandPrimary
                              : CinemaColors.bgBorder,
                          width: isActivePanel ? 2.5 : 1.0,
                        ),
                        boxShadow: isActivePanel
                            ? [
                                BoxShadow(
                                  color: CinemaColors.brandPrimary.withAlpha(60),
                                  blurRadius: 35,
                                  spreadRadius: 3,
                                ),
                              ]
                            : [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.network(
                              pageItem.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 480,
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 480,
                                  color: CinemaColors.bgSurface,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: CinemaColors.brandSecondary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (ctx, error, stackTrace) {
                                return Container(

                                  height: 480,
                                  color: CinemaColors.bgSurface,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      color: CinemaColors.textMuted,
                                      size: 48,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Ambient Dimming เมื่อไม่ใช่ช่องที่กำลังพูด
                            if (!isActivePanel)
                              Container(
                                height: 480,
                                color: Colors.black.withAlpha(120),
                              ),

                            // Badge ลำดับช่อง
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: CinemaColors.bgSurfaceGlass,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isActivePanel
                                        ? CinemaColors.brandPrimary
                                        : CinemaColors.bgBorder,
                                  ),
                                ),
                                child: Text(
                                  'Page ${pageItem.pageIndex}',
                                  style: TextStyle(
                                    color: isActivePanel
                                        ? CinemaColors.brandPrimary
                                        : CinemaColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            else
              const Center(
                child: Text(
                  'กดไอคอนลิงก์ด้านบนเพื่อใส่ Webtoon URL',
                  style: TextStyle(color: CinemaColors.textSecondary),
                ),
              ),

            // 2. Subtitle & Active Speech Bubble Floating Overlay
            if (bubble != null)
              Positioned(
                left: 20,
                right: 20,
                bottom: 110,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 640),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: CinemaColors.bgSurfaceGlass,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: CinemaColors.brandPrimary,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(150),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildRoleIcon(bubble.role),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            bubble.speechText,
                            style: const TextStyle(
                              color: CinemaColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 3. Top Status & Navigation Bar Overlay
            if (playback.showOverlay)
              Positioned(
                top: 48,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: CinemaColors.bgSurfaceGlass,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CinemaColors.bgBorder),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'ใส่ Webtoon URL',
                        icon: const Icon(
                          Icons.add_link_rounded,
                          color: CinemaColors.brandPrimary,
                          size: 26,
                        ),
                        onPressed: () => _showUrlInputDialog(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              chapter?.title ?? 'Manga Cinema',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: CinemaColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              chapter?.episodeNumber ?? 'วาง URL เพื่อเริ่มอ่าน',
                              style: const TextStyle(
                                color: CinemaColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                  content: Text(
                                    'คุณกำลังใช้งานเวอร์ชันล่าสุดอยู่แล้ว',
                                  ),
                                  backgroundColor: CinemaColors.bgSurface,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // 4. Bottom Floating Cinema Controller Overlay
            if (playback.showOverlay)
              Positioned(
                bottom: 30,
                left: 24,
                right: 24,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: CinemaColors.bgSurfaceGlass,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: CinemaColors.bgBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(160),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded),
                          color: CinemaColors.textSecondary,
                          onPressed: () => playback.previousPanel(),
                        ),
                        FloatingActionButton(
                          backgroundColor: CinemaColors.brandPrimary,
                          elevation: 6,
                          onPressed: () => playback.togglePlayPause(),
                          child: Icon(
                            playback.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded),
                          color: CinemaColors.textSecondary,
                          onPressed: () => playback.nextPanel(),
                        ),
                      ],
                    ),
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
      radius: 18,
      backgroundColor: iconColor.withAlpha(45),
      child: Icon(iconData, size: 20, color: iconColor),
    );
  }
}
