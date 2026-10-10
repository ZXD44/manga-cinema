import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/cinema_models.dart';
import '../services/auto_update_service.dart';
import '../services/manga_url_loader_service.dart';
import '../state/cinema_playback_state.dart';
import '../theme/cinema_colors.dart';
import '../widgets/cinema_update_dialog.dart';

class MangaCatalogItem {
  final String title;
  final String episode;
  final String coverUrl;
  final String targetUrl;
  final String genre;

  const MangaCatalogItem({
    required this.title,
    required this.episode,
    required this.coverUrl,
    required this.targetUrl,
    required this.genre,
  });
}

class CinemaViewerScreen extends StatefulWidget {
  const CinemaViewerScreen({super.key});

  @override
  State<CinemaViewerScreen> createState() => _CinemaViewerScreenState();
}

class _CinemaViewerScreenState extends State<CinemaViewerScreen> {
  final ScrollController _verticalScrollController = ScrollController();
  final TextEditingController _urlController = TextEditingController();
  bool _isFullscreen = false;

  // รายการมังงะแนะนำยอดนิยมให้เลือกกดอ่านและพากย์ได้ทันที
  final List<MangaCatalogItem> _featuredMangaList = const [
    MangaCatalogItem(
      title: 'Return of the Frozen Player',
      episode: 'ตอนที่ 182 (Up-Manga)',
      coverUrl: 'https://www.up-manga.com/wp-content/uploads/2023/09/Return-of-the-Frozen-Player.jpg',
      targetUrl: 'https://www.up-manga.com/return-of-the-frozen-%e0%b8%95%e0%b8%ad%e0%b8%99%e0%b8%97%e0%b8%b5%e0%b9%88-182/',
      genre: 'Action / Fantasy',
    ),
    MangaCatalogItem(
      title: 'The Return of the Scorned Genius',
      episode: 'ตอนที่ 1 (SiamWebtoon)',
      coverUrl: 'https://cdn.siamwebtoon.com/covers/100103fa-e283-4629-98bb-4506a0db441d-1791567336.jpg',
      targetUrl: 'https://siamwebtoon.com/title/the-return-of-the-scorned-genius/%E0%B8%95%E0%B8%AD%E0%B8%99%E0%B8%97%E0%B8%B5%E0%B9%88-1',
      genre: 'Revenge / Genius',
    ),
    MangaCatalogItem(
      title: 'Solo Leveling: Ragnarok',
      episode: 'ตอนที่ 1 (ToonXD)',
      coverUrl: 'https://bunny.toonxd.com/content/cmupy8ow300ia11odpff3sfcx/ad30053a-a80c-44eb-b9ee-b50603ee05fc.webp',
      targetUrl: 'https://toonxd.co/series/the-return-of-the-scorned-genius/1',
      genre: 'Hunter / Action',
    ),
    MangaCatalogItem(
      title: 'The Return of the Scorned Genius',
      episode: 'ตอนที่ 1 (DukeToon)',
      coverUrl: 'https://duketoon.com/og/content/the-return-of-the-scorned-genius/1.webp',
      targetUrl: 'https://duketoon.com/content/the-return-of-the-scorned-genius/1',
      genre: 'Martial Arts',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoUpdateOnStartup();
    });
  }

  Future<void> _checkAutoUpdateOnStartup() async {
    try {
      final info = await AutoUpdateService.checkForUpdate();
      if (mounted && info != null && info.hasUpdate) {
        CinemaUpdateDialog.show(context, info);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🖥️ เข้าสู่โหมดเต็มหน้าจอ (Fullscreen Cinema)'),
          duration: Duration(seconds: 2),
          backgroundColor: CinemaColors.bgSurface,
        ),
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _showUrlInputDialog(BuildContext context) {
    _urlController.clear(); // ล้างกล่องข้อความให้ว่างเปล่าตามที่ขอ

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
                        Icons.add_link_rounded,
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
                            'รองรับ Up-Manga, SiamWebtoon, ToonXD, DukeToon ฯลฯ',
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
                  autofocus: true,
                  style: const TextStyle(
                    color: CinemaColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'วาง URL เช่น https://www.up-manga.com/...',
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

                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('⏳ กำลังดึงภาพและบทพูดจากการ์ตูน...'),
                                duration: Duration(seconds: 2),
                                backgroundColor: CinemaColors.bgSurface,
                              ),
                            );

                            final ok = await playback.loadFromWebtoonUrl(targetUrl);
                            if (mounted && ok) {
                              playback.play(); // เริ่มพากย์และเลื่อนภาพทันที
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('✓ โหลดสำเร็จ: ${playback.chapter?.title ?? ""} (เริ่มพากย์เสียงแล้ว)'),
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

  void _showMangaSelectorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CinemaColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📚 เลือกมังงะ/เว็บตูนยอดนิยม',
                    style: TextStyle(
                      color: CinemaColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: CinemaColors.textSecondary),
                    onPressed: () => Navigator.of(modalCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _featuredMangaList.length,
                  itemBuilder: (ctx, i) {
                    final item = _featuredMangaList[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: CinemaColors.bgPrimary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CinemaColors.bgBorder),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.coverUrl,
                            width: 50,
                            height: 65,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, error, stackTrace) => Container(
                              width: 50,
                              height: 65,
                              color: CinemaColors.bgSurface,
                              child: const Icon(Icons.menu_book, color: CinemaColors.brandPrimary),
                            ),

                          ),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            color: CinemaColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${item.episode} • ${item.genre}',
                          style: const TextStyle(
                            color: CinemaColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CinemaColors.brandPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          label: const Text('ดู & พากย์', style: TextStyle(fontSize: 12)),
                          onPressed: () async {
                            Navigator.of(modalCtx).pop();
                            final playback = context.read<CinemaPlaybackState>();
                            final ok = await playback.loadFromWebtoonUrl(item.targetUrl);
                            if (mounted && ok) {
                              playback.play(); // เริ่มพากย์เสียงทันที
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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
                      'กำลังดึงรูปภาพและเตรียมระบบพากย์เสียงอัตโนมัติ...',
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
                              headers: MangaUrlLoaderService.defaultHeaders,
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 480,
                                  color: CinemaColors.bgSurface,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: CinemaColors.brandPrimary,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (ctx, error, stackTrace) {
                                return Image.network(
                                  'https://picsum.photos/seed/panel_${pageItem.pageIndex}/800/1200',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 480,
                                );
                              },
                            ),

                            // Ambient Dimming
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
                                  'Panel ${pageItem.pageIndex}',
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
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.movie_creation_outlined, size: 64, color: CinemaColors.brandPrimary),
                    const SizedBox(height: 16),
                    const Text('ยังไม่มีการเปิดอ่านมังงะ', style: TextStyle(color: CinemaColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: CinemaColors.brandPrimary, foregroundColor: Colors.white),
                      icon: const Icon(Icons.menu_book),
                      label: const Text('เลือกมังงะแนะนำ'),
                      onPressed: () => _showMangaSelectorModal(context),
                    ),
                  ],
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
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: CinemaColors.bgSurfaceGlass,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CinemaColors.bgBorder),
                  ),
                  child: Row(
                    children: [
                      // ปุ่มเลือกมังงะแนะนำ
                      IconButton(
                        tooltip: 'เลือกมังงะแนะนำ',
                        icon: const Icon(Icons.library_books_rounded, color: CinemaColors.accentAmber, size: 24),
                        onPressed: () => _showMangaSelectorModal(context),
                      ),
                      // ปุ่มเพิ่ม URL
                      IconButton(
                        tooltip: 'ใส่ Webtoon URL',
                        icon: const Icon(
                          Icons.add_link_rounded,
                          color: CinemaColors.brandPrimary,
                          size: 26,
                        ),
                        onPressed: () => _showUrlInputDialog(context),
                      ),
                      const SizedBox(width: 4),
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
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              chapter?.episodeNumber ?? 'เลือกตอนหรือวาง URL',
                              style: const TextStyle(
                                color: CinemaColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ปุ่มสลับเต็มจอ
                      IconButton(
                        tooltip: _isFullscreen ? 'ออกจากเต็มหน้าจอ' : 'เต็มหน้าจอ',
                        icon: Icon(
                          _isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                          color: CinemaColors.textPrimary,
                          size: 26,
                        ),
                        onPressed: _toggleFullscreen,
                      ),
                      // ปุ่มอัปเดตเวอร์ชัน
                      IconButton(
                        tooltip: 'ตรวจสอบอัปเดต',
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
                                  content: Text('✓ คุณกำลังใช้งานเวอร์ชันล่าสุด (v${AutoUpdateService.currentVersion}) แล้ว'),
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
                    constraints: const BoxConstraints(maxWidth: 440),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
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
                        IconButton(
                          tooltip: 'โหมดเต็มหน้าจอ',
                          icon: Icon(
                            _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                            color: CinemaColors.accentAmber,
                          ),
                          onPressed: _toggleFullscreen,
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
