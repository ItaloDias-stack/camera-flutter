import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

Future<File> compressAndGetFile({
  required File file,
  int minWidth = 1920,
  int minHeight = 1080,
}) async {
  String path = (await getTemporaryDirectory()).path;
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    "$path/${DateTime.now().microsecondsSinceEpoch.toString()}.png",
    format: CompressFormat.png,
    minHeight: minHeight,
    minWidth: minWidth,
  );
  result ??= await compressAndGetFile(
    file: file,
    minHeight: minHeight,
    minWidth: minWidth,
  );
  return result;
}
