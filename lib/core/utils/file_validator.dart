import 'dart:io';

class FileValidator {
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB Max limit

  static String? validateImageFile(File file) {
    if (!file.existsSync()) {
      return 'Tập tin hình ảnh không tồn tại.';
    }

    final path = file.path.toLowerCase();
    if (!path.endsWith('.jpg') &&
        !path.endsWith('.jpeg') &&
        !path.endsWith('.png') &&
        !path.endsWith('.webp')) {
      return 'Định dạng hình ảnh không hợp lệ. Chỉ chấp nhận JPG, PNG, WEBP.';
    }

    final int sizeBytes = file.lengthSync();
    if (sizeBytes > maxFileSizeBytes) {
      return 'Dung lượng ảnh vượt quá giới hạn cho phép (Tối đa 5MB).';
    }

    return null;
  }
}