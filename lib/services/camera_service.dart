import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> takePicture() async {
    final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera, maxWidth: 1000
    );

    if (photo != null) {
      return File(photo.path);
    }
    return null;
  }
}
