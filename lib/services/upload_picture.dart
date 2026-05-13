import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Skogsjakten/services/session_storage.dart';


class UploadPicture {
  final String? jwtToken;

  const UploadPicture({required this.jwtToken});

  //se till att man innan anropet, skickar token med await

  Future<String?> sendPictureToGoogleStorage(File? imageFile) async {
    try {
      if (imageFile != null) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://group-6-15.pvt.dsv.su.se/uploads/picture'),
        );

      request.headers['Authorization'] = 'Bearer $jwtToken';

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();


      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        return data['objectKey'];  // Returnera objectKey, inte imageUrl
      } else {
        debugPrint('Upload misslyckades: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('GoogleStorage Error $e');
      return null;
    }
  }

  Future<bool> sendPictureToBackend(File? imageFile, String targetType, String pictureMode, int challengeId) async {
    try {
      //Vänta på att bilden laddas upp och få tillbaka URL:en
      final imageObjectKey = await sendPictureToGoogleStorage(imageFile);

      if (imageObjectKey != null) {

      //Skicka URL till backend
      final response = await http.post(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/pictures'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },

        body: jsonEncode({
          'imageObjectKey': imageObjectKey,
          'targetType': targetType,
          'pictureMode': pictureMode,
          "challengeId": challengeId,

        }),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Backend Error: ${response.statusCode}');
        return false;
      }
      }
      return false;
    } catch (e) {
      debugPrint('Skicka bild till backend Error $e');
      return false;
    }
  }




  /// profilbild metoder


// ladda upp bild till google storage
  Future<String> sendPictureByteToGoogleStorage(Uint8List bytes,
      String filename,) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://group-6-15.pvt.dsv.su.se/uploads/picture',
        ),
      );


      // Lägg till token för att tillåtas ladda upp
      request.headers['Authorization'] =
      'Bearer $jwtToken';


      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );


      final response = await request.send();


      final responseBody =
      await response.stream.bytesToString();


      debugPrint(
        'Upload status: ${response.statusCode}',
      );


      debugPrint(
        'Upload response: $responseBody',
      );


      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = jsonDecode(responseBody);


        return data['imageObjectKey'];
      } else {
        throw Exception(
          'Misslyckande ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Misslyckades att ladda upp bild $e',
      );
    }
  }


// spara url från google storage till backend
  Future<void> saveProfileImage(String assetPath,) async {
    try {
      if (jwtToken == null) {
        throw Exception(
          "Ingen aktiv session hittades",
        );
      }


      // Konvertera asset till bytes
      final Uint8List bytes =
      (await rootBundle.load(assetPath))
          .buffer
          .asUint8List();


      // Ladda upp till Google Storage
      final imageObjectKey =
      await sendPictureByteToGoogleStorage(
        bytes,
        assetPath
            .split('/')
            .last,
      );


      debugPrint(
        'imageObjectKey: $imageObjectKey',
      );


      // Spara objectKey i backend
      final response = await http.patch(
        Uri.parse(
          'https://group-6-15.pvt.dsv.su.se/users/me/profile-image',
        ),
        headers: {
          'Authorization':
          'Bearer $jwtToken',
          'Content-Type':
          'application/json',
        },
        body: jsonEncode({
          'profileImageUrl': imageObjectKey,
        }),
      );


      debugPrint(
        'PATCH status: ${response.statusCode}',
      );


      debugPrint(
        'PATCH body: ${response.body}',
      );


      if (response.statusCode != 200 &&
          response.statusCode != 204) {
        throw Exception(
          'Misslyckades att spara profilbild',
        );
      }
    } catch (e) {
      debugPrint(
        "Fel vid sparande: $e",
      );


      rethrow;
    }
  }
}
