import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class MangaAppReleaseInfo {
  final String latestVersion;
  final String changelog;
  final String apkDownloadUrl;
  final String ipaDownloadUrl;
  final bool hasUpdate;

  const MangaAppReleaseInfo({
    required this.latestVersion,
    required this.changelog,
    required this.apkDownloadUrl,
    required this.ipaDownloadUrl,
    required this.hasUpdate,
  });
}

class AutoUpdateService {
  static const String currentVersion = '1.0.0';
  static const String githubRepo = 'ZXD44/manga-cinema';
  static const MethodChannel _channel = MethodChannel('com.mangacinema.app/updater');

  /// ตรวจสอบ Release ล่าสุดจาก GitHub
  static Future<MangaAppReleaseInfo?> checkForUpdate() async {
    try {
      final url = Uri.parse('https://api.github.com/repos/$githubRepo/releases/latest');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Manga-Cinema-App',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final String tagName = (data['tag_name'] ?? '').toString().replaceAll('v', '').trim();
        final String body = (data['body'] ?? 'อัปเดตเวอร์ชันใหม่พร้อมฟีเจอร์พากย์เสียงและการทำงานที่เสถียรขึ้น').toString();

        String apkUrl = '';
        String ipaUrl = '';

        final assets = data['assets'] as List?;
        if (assets != null && assets.isNotEmpty) {
          for (var asset in assets) {
            final name = (asset['name'] ?? '').toString();
            if (name.endsWith('.apk')) {
              apkUrl = (asset['browser_download_url'] ?? '').toString();
            } else if (name.endsWith('.ipa')) {
              ipaUrl = (asset['browser_download_url'] ?? '').toString();
            }
          }
        }

        if (apkUrl.isEmpty) {
          apkUrl = 'https://github.com/$githubRepo/releases/latest/download/Manga-Cinema.apk';
        }
        if (ipaUrl.isEmpty) {
          ipaUrl = 'https://github.com/$githubRepo/releases/latest/download/Manga-Cinema.ipa';
        }

        final bool hasNewer = _isVersionNewer(tagName, currentVersion);

        return MangaAppReleaseInfo(
          latestVersion: tagName.isNotEmpty ? tagName : currentVersion,
          changelog: body,
          apkDownloadUrl: apkUrl,
          ipaDownloadUrl: ipaUrl,
          hasUpdate: hasNewer,
        );
      }
    } catch (_) {}
    return null;
  }

  /// ตรวจสอบเวอร์ชัน Semantic Versioning
  static bool _isVersionNewer(String latest, String current) {
    if (latest.isEmpty) return false;
    try {
      final latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < 3; i++) {
        final l = i < latestParts.length ? latestParts[i] : 0;
        final c = i < currentParts.length ? currentParts[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }
    } catch (_) {}
    return false;
  }

  /// ดาวน์โหลด APK พร้อม Progress Callback และเรียกติดตั้งทันที
  static Future<bool> downloadAndInstall({
    required String downloadUrl,
    required Function(double progress, double downloadedMb, double totalMb) onProgress,
  }) async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(downloadUrl));
      request.headers['User-Agent'] = 'Manga-Cinema-App';
      final response = await client.send(request);

      if (response.statusCode != 200 && response.statusCode != 302) {
        return false;
      }

      final totalBytes = response.contentLength ?? (27 * 1024 * 1024);
      final totalMb = totalBytes / (1024 * 1024);

      final tempDir = await getTemporaryDirectory();
      final apkFile = File('${tempDir.path}/Manga-Cinema-update.apk');
      if (await apkFile.exists()) {
        await apkFile.delete();
      }

      final sink = apkFile.openWrite();
      int receivedBytes = 0;

      await for (var chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        final progress = (receivedBytes / totalBytes).clamp(0.0, 1.0);
        final downloadedMb = receivedBytes / (1024 * 1024);
        onProgress(progress, downloadedMb, totalMb);
      }

      await sink.flush();
      await sink.close();

      // สั่ง Native PackageInstaller บน Android
      if (Platform.isAndroid) {
        final bool? success = await _channel.invokeMethod<bool>('installApk', {
          'filePath': apkFile.path,
        });
        return success ?? false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
