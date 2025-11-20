import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/app_icon_generator.dart';

/// 앱 아이콘 미리보기 및 저장 페이지
/// 
/// 이 페이지에서 룰렛 휠 아이콘을 미리보고 스크린샷을 저장할 수 있습니다.
class IconPreviewPage extends StatefulWidget {
  const IconPreviewPage({super.key});

  @override
  State<IconPreviewPage> createState() => _IconPreviewPageState();
}

class _IconPreviewPageState extends State<IconPreviewPage> {
  final GlobalKey _iconKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveIcon() async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      final RenderRepaintBoundary boundary =
          _iconKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('이미지 데이터를 생성할 수 없습니다.');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 임시 디렉토리에 저장
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/app_icon_1024x1024.png');
      await file.writeAsBytes(pngBytes);

      // 공유 기능으로 저장 위치 선택 가능하게 함
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        text: 'RandomFocus 앱 아이콘 (1024x1024)\n\n이 파일을 assets/images/app_icon.png로 복사하세요.',
        subject: 'RandomFocus App Icon',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '✅ 아이콘이 저장되었습니다!\n'
              '공유 메뉴에서 저장 위치를 선택하세요.\n'
              '그 후 assets/images/app_icon.png로 복사하고\n'
              'flutter pub run flutter_launcher_icons를 실행하세요.',
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '확인',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      print('아이콘 저장 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 저장 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 아이콘 미리보기'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveIcon,
              tooltip: '아이콘 저장 및 공유',
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            const Text(
              '아래 아이콘을 스크린샷으로 저장하세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            RepaintBoundary(
              key: _iconKey,
              child: Container(
                width: 1024,
                height: 1024,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const AppIconGenerator(
                  size: 1024,
                  numbers: [5, 10, 10, 15, 20, 25],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    '📱 앱 아이콘 사용 방법:\n'
                    '1. 저장 버튼(💾)을 눌러 아이콘 저장\n'
                    '2. 공유 메뉴에서 저장 위치 선택\n'
                    '3. 저장된 파일을 assets/images/app_icon.png로 복사\n'
                    '4. flutter pub run flutter_launcher_icons 실행\n'
                    '5. 앱을 다시 빌드하고 설치',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: const Text(
                      '💡 팁: 저장 버튼을 누르면 1024x1024 크기의\n'
                      'PNG 파일이 생성되어 공유됩니다.\n'
                      '파일을 다운로드 폴더나 원하는 위치에 저장하세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

