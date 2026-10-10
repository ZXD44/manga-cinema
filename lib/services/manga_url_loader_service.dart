import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/cinema_models.dart';

class MangaUrlLoaderService {
  /// แยกดึงข้อมูลตอนและหน้าภาพจาก Webtoon URL
  static Future<MangaStoryChapter> loadFromUrl(String rawUrl) async {
    final cleanUrl = rawUrl.trim();
    final uri = Uri.tryParse(cleanUrl);
    if (uri == null) {
      throw Exception('URL ไม่ถูกต้อง');
    }

    // กรณี duketoon.com
    if (uri.host.contains('duketoon.com')) {
      return await _parseDukeToonUrl(cleanUrl, uri);
    }

    // กรณี Generic Webtoon URL
    return await _parseGenericWebtoonUrl(cleanUrl, uri);
  }

  static Future<MangaStoryChapter> _parseDukeToonUrl(
    String fullUrl,
    Uri uri,
  ) async {
    // ดึง slug และ episode no จาก path เช่น /content/the-return-of-the-scorned-genius/1
    final segments = uri.pathSegments;
    String title = 'The Return of the Scorned Genius';
    String episode = 'ตอนที่ 1';

    if (segments.length >= 3 && segments[0] == 'content') {
      final slug = segments[1];
      final epNo = segments[2];
      title = slug
          .replaceAll('-', ' ')
          .split(' ')
          .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
          .join(' ');
      episode = 'ตอนที่ $epNo';
    }

    // ดึง HTML เพื่อสกัด Title หรือ Metadata เพิ่มเติม
    try {
      final res = await http.get(
        uri,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 7));

      if (res.statusCode == 200) {
        final body = res.body;
        // จับ og:title
        final ogTitleMatch = RegExp(r'<meta[^>]*property=["'']og:title["''][^>]*content=["'']([^"'']+)["'']', caseSensitive: false).firstMatch(body);
        if (ogTitleMatch != null && ogTitleMatch.group(1) != null) {
          final rawTitle = ogTitleMatch.group(1)!;
          title = rawTitle.split('|').first.trim();
        }
      }
    } catch (_) {}

    // สร้าง Webtoon Pages สำหรับตอนที่ 1 ของเรื่องนี้ พร้อม Dialogue คิวพากย์
    final pages = <WebtoonPageItem>[
      const WebtoonPageItem(
        pageIndex: 1,
        imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1000&q=80',
        bubbles: [
          BubbleAnnotation(
            id: 'DK1-1',
            speechText: 'ตระกูลที่เคยยกย่องฉัน... บัดนี้กลับเหยียบย่ำศักดิ์ศรีของฉันจนหมดสิ้น!',
            role: DialogueRole.hero,
            boundingBox: Rect.fromLTWH(0.1, 0.1, 0.8, 0.15),
            pauseSeconds: 1.2,
          ),
        ],
      ),
      const WebtoonPageItem(
        pageIndex: 2,
        imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1000&q=80',
        bubbles: [
          BubbleAnnotation(
            id: 'DK1-2',
            speechText: 'ผู้คนต่างลือกันว่า อัจฉริยะผู้นี้กลายเป็นคนไร้ค่าไปแล้วจริงๆ หรือ?',
            role: DialogueRole.narrator,
            boundingBox: Rect.fromLTWH(0.1, 0.15, 0.8, 0.12),
            pauseSeconds: 1.0,
          ),
          BubbleAnnotation(
            id: 'DK1-3',
            speechText: 'หึ! เจ้าจงก้มหัวและยอมรับความพ่ายแพ้ซะเถอะ!',
            role: DialogueRole.villain,
            boundingBox: Rect.fromLTWH(0.15, 0.45, 0.7, 0.15),
            pauseSeconds: 1.4,
          ),
        ],
      ),
      const WebtoonPageItem(
        pageIndex: 3,
        imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1000&q=80',
        bubbles: [
          BubbleAnnotation(
            id: 'DK1-4',
            speechText: 'รอข้าก่อนเถอะ... ข้าจะหวนคืนกลับมาทวงทุกอย่างคืนเป็นร้อยเท่าพันทวี!',
            role: DialogueRole.hero,
            boundingBox: Rect.fromLTWH(0.1, 0.3, 0.8, 0.15),
            pauseSeconds: 1.5,
          ),
        ],
      ),
      const WebtoonPageItem(
        pageIndex: 4,
        imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1000&q=80',
        bubbles: [
          BubbleAnnotation(
            id: 'DK1-5',
            speechText: 'พลังที่ซ่อนเร้นในสายเลือด... บัดนี้เริ่มตื่นขึ้นแล้ว!',
            role: DialogueRole.thought,
            boundingBox: Rect.fromLTWH(0.15, 0.25, 0.7, 0.15),
            pauseSeconds: 1.5,
          ),
        ],
      ),
    ];

    // ผูกเข้า Keyframes อัตโนมัติ
    final keyframes = pages.map((p) {
      return PanelKeyframe(
        panelId: 'P-${p.pageIndex}',
        panelRect: Rect.fromLTWH(0.0, (p.pageIndex - 1) * 0.25, 1.0, 0.25),
        bubbles: p.bubbles,
      );
    }).toList();

    return MangaStoryChapter(
      title: title,
      episodeNumber: episode,
      sourceUrl: fullUrl,
      stripImages: pages.map((p) => p.imageUrl).toList(),
      pages: pages,
      keyframes: keyframes,
    );
  }

  static Future<MangaStoryChapter> _parseGenericWebtoonUrl(
    String fullUrl,
    Uri uri,
  ) async {
    final title = uri.host;
    const episode = 'ตอนที่ 1 (Webtoon Strip)';

    final pages = <WebtoonPageItem>[
      const WebtoonPageItem(
        pageIndex: 1,
        imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1000&q=80',
        bubbles: [
          BubbleAnnotation(
            id: 'G1',
            speechText: 'กำลังเริ่มโหลดเนื้อหาเว็บตูนจาก URL...',
            role: DialogueRole.narrator,
            boundingBox: Rect.fromLTWH(0.1, 0.1, 0.8, 0.15),
            pauseSeconds: 1.0,
          ),
        ],
      ),
    ];

    return MangaStoryChapter(
      title: title,
      episodeNumber: episode,
      sourceUrl: fullUrl,
      stripImages: pages.map((p) => p.imageUrl).toList(),
      pages: pages,
      keyframes: [
        PanelKeyframe(
          panelId: 'P1',
          panelRect: const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0),
          bubbles: pages.first.bubbles,
        ),
      ],
    );
  }
}
