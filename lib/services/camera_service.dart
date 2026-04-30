import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {

  static final ImagePicker picker = ImagePicker();

  static Future<File?> takePicture() async {

    try{
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        //kan justeras beroende på AI api
        maxWidth: 1000,
        imageQuality: 85,
      );

      if (photo != null) {
        return File(photo.path);
      }

      return null;

    } catch (e) {
      debugPrint("Kamera Fel: $e");
      return null;
    }

  }
}
