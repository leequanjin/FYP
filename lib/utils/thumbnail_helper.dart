import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ThumbnailHelper {
  static Future<String> createThumb(
      String sourcePath, {
        int width = 320,
        int quality = 75,
      }) async {
    final dir = await getApplicationDocumentsDirectory();
    final baseName = p.basenameWithoutExtension(sourcePath);
    final thumbName = '${baseName}_thumb.jpg';
    final thumbPath = p.join(dir.path, thumbName);

    final result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      thumbPath,
      minWidth: width,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    return result?.path ?? sourcePath;
  }
}