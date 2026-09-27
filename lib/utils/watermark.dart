import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

Future<File> applyWatermarkIfNeeded(File imageFile) async {
  if (!Global.isWatermark) return imageFile;
  try {
    return await applyWatermark(imageFile);
  } catch (e) {
    flogErr(e, {}, 'Watermark', 'applyWatermarkIfNeeded');
    return imageFile;
  }
}

Future<File> applyWatermark(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final originalImage = img.decodeImage(bytes);
  if (originalImage == null) return imageFile;

  if (Global.watermarkMode == 'text') {
    await _applyTextWatermark(originalImage);
  } else {
    await _applyImageWatermark(originalImage);
  }

  final format = imageFile.path.split('.').last.toLowerCase();
  Uint8List outputBytes;
  if (format == 'png') {
    outputBytes = img.encodePng(originalImage);
  } else {
    outputBytes = img.encodeJpg(originalImage, quality: 95);
  }

  final tempDir = await getTemporaryDirectory();
  final outputPath = '${tempDir.path}/watermark_${DateTime.now().millisecondsSinceEpoch}.$format';
  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(outputBytes);
  return outputFile;
}

Future<void> _applyTextWatermark(img.Image image) async {
  final text = Global.watermarkText;
  if (text.isEmpty) return;

  final opacity = (Global.watermarkOpacity * 255).round().clamp(0, 255);
  final color = img.ColorRgba8(255, 255, 255, opacity);

  final img.BitmapFont font = switch (Global.watermarkFontSize) {
    'large' => img.arial48,
    'medium' => img.arial24,
    _ => img.arial14,
  };

  final (x, y) = _calculatePosition(
    image.width,
    image.height,
    _estimateTextWidth(text, font),
    font.size,
  );

  img.drawString(image, text, font: font, x: x, y: y, color: color);
}

int _estimateTextWidth(String text, img.BitmapFont font) {
  int width = 0;
  for (final c in text.codeUnits) {
    if (font.characters.containsKey(c)) {
      width += font.characters[c]!.xAdvance;
    } else {
      width += font.base ~/ 2;
    }
  }
  return width;
}

Future<void> _applyImageWatermark(img.Image image) async {
  final watermarkPath = Global.watermarkImagePath;
  if (watermarkPath.isEmpty) return;

  final watermarkFile = File(watermarkPath);
  if (!await watermarkFile.exists()) return;

  final watermarkBytes = await watermarkFile.readAsBytes();
  final watermarkImage = img.decodeImage(watermarkBytes);
  if (watermarkImage == null) return;

  final scale = Global.watermarkFontSize == 'large'
      ? 0.3
      : Global.watermarkFontSize == 'medium'
          ? 0.2
          : 0.1;

  final targetWidth = (image.width * scale).round();
  final resizedWatermark = img.copyResize(watermarkImage, width: targetWidth);

  final opacity = (Global.watermarkOpacity * 255).round().clamp(0, 255);
  for (final pixel in resizedWatermark) {
    final a = (pixel.a * opacity / 255).round();
    pixel.a = a;
  }

  final (x, y) = _calculatePosition(
    image.width,
    image.height,
    resizedWatermark.width,
    resizedWatermark.height,
  );

  img.compositeImage(image, resizedWatermark, dstX: x, dstY: y);
}

(int, int) _calculatePosition(int imgW, int imgH, int objW, int objH) {
  const margin = 20;
  return switch (Global.watermarkPosition) {
    'topLeft' => (margin, margin),
    'topRight' => (imgW - objW - margin, margin),
    'bottomLeft' => (margin, imgH - objH - margin),
    'bottomRight' => (imgW - objW - margin, imgH - objH - margin),
    'center' => ((imgW - objW) ~/ 2, (imgH - objH) ~/ 2),
    _ => (imgW - objW - margin, imgH - objH - margin),
  };
}
