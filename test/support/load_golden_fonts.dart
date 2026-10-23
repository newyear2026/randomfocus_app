import 'dart:io';

import 'package:flutter/services.dart';

/// Use the SDK's bundled fonts for readable new-screen visual regression images.
/// The fallback derives the cache from the running flutter_tester, not a host path.
Future<void> loadGoldenFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  final fonts = root == null
      ? Directory(
          '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts',
        )
      : Directory('$root/bin/cache/artifacts/material_fonts');
  Future<ByteData> read(String name) async =>
      ByteData.sublistView(await File('${fonts.path}/$name').readAsBytes());
  final roboto = FontLoader('Roboto')
    ..addFont(read('Roboto-Regular.ttf'))
    ..addFont(read('Roboto-Medium.ttf'))
    ..addFont(read('Roboto-Bold.ttf'));
  await roboto.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(read('MaterialIcons-Regular.otf'))).load();
}
