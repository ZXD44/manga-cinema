import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auto_update_service.dart';
import '../theme/cinema_colors.dart';

class CinemaUpdateDialog extends StatefulWidget {
  final MangaAppReleaseInfo releaseInfo;

  const CinemaUpdateDialog({
    super.key,
    required this.releaseInfo,
  });

  static void show(BuildContext context, MangaAppReleaseInfo releaseInfo) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CinemaUpdateDialog(releaseInfo: releaseInfo),
    );
  }

  @override
  State<CinemaUpdateDialog> createState() => _CinemaUpdateDialogState();
}

class _CinemaUpdateDialogState extends State<CinemaUpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  double _downloadedMb = 0.0;
  double _totalMb = 0.0;
  String _statusText = 'พร้อมติดตั้งเวอร์ชันล่าสุด';

  void _startUpdate() async {
    HapticFeedback.selectionClick();
    setState(() {
      _isDownloading = true;
      _statusText = 'กำลังดาวน์โหลดอัปเดต...';
    });

    final success = await AutoUpdateService.downloadAndInstall(
      downloadUrl: widget.releaseInfo.apkDownloadUrl,
      onProgress: (progress, downloadedMb, totalMb) {
        if (mounted) {
          setState(() {
            _progress = progress;
            _downloadedMb = downloadedMb;
            _totalMb = totalMb;
            _statusText = 'กำลังดาวน์โหลด ${(progress * 100).toInt()}%';
          });
        }
      },
    );

    if (mounted) {
      if (success) {
        setState(() {
          _statusText = 'กำลังเปิดหน้าจอยืนยันการติดตั้ง...';
        });
      } else {
        setState(() {
          _isDownloading = false;
          _statusText = 'ดาวน์โหลดไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rel = widget.releaseInfo;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: CinemaColors.bgSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: CinemaColors.brandPrimary.withAlpha(90),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: CinemaColors.brandPrimary.withAlpha(45),
              blurRadius: 36,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CinemaColors.brandPrimary.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: CinemaColors.brandPrimary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ตรวจพบการอัปเดตใหม่',
                        style: TextStyle(
                          color: CinemaColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'v${AutoUpdateService.currentVersion} ➔ v${rel.latestVersion}',
                        style: const TextStyle(
                          color: CinemaColors.statusSyncActive,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Changelog card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CinemaColors.bgPrimary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: CinemaColors.bgBorder),
              ),
              constraints: const BoxConstraints(maxHeight: 160),
              child: SingleChildScrollView(
                child: Text(
                  rel.changelog,
                  style: const TextStyle(
                    color: CinemaColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Progress bar
            if (_isDownloading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress > 0.0 ? _progress : null,
                  backgroundColor: CinemaColors.bgBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    CinemaColors.brandPrimary,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _statusText,
                    style: const TextStyle(
                      color: CinemaColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  if (_totalMb > 0)
                    Text(
                      '${_downloadedMb.toStringAsFixed(1)} / ${_totalMb.toStringAsFixed(1)} MB',
                      style: const TextStyle(
                        color: CinemaColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ] else ...[
              Text(
                _statusText,
                style: const TextStyle(
                  color: CinemaColors.textMuted,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CinemaColors.textSecondary,
                      side: const BorderToBorder(CinemaColors.bgBorder),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isDownloading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('ไว้คราวหน้า'),
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
                      elevation: 4,
                    ),
                    onPressed: _isDownloading ? null : _startUpdate,
                    child: Text(
                      _isDownloading ? 'กำลังโหลด...' : 'อัปเดตทันที (APK)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            if (rel.ipaDownloadUrl.isNotEmpty) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.apple, size: 18, color: CinemaColors.textSecondary),
                  label: const Text(
                    'ดาวน์โหลดไฟล์สำหรับ iOS (Manga-Cinema.ipa)',
                    style: TextStyle(
                      color: CinemaColors.textSecondary,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: rel.ipaDownloadUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('คัดลอกลิงก์ดาวน์โหลด Manga-Cinema.ipa แล้ว'),
                        backgroundColor: CinemaColors.bgSurface,
                      ),
                    );
                  },
                ),
              ),
            ],

          ],
        ),
      ),
    );
  }
}

class BorderToBorder extends BorderSide {
  const BorderToBorder(Color color) : super(color: color, width: 1.2);
}
