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



  Future<http.StreamedResponse?> sendPictureToGoogleStorage(File? imageFile) async {
    try {
      if (imageFile != null) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://group-6-15.pvt.dsv.su.se/uploads/picture'),
        );

        request.headers['Authorization'] = 'Bearer $jwtToken';

        request.files.add(
          await http.MultipartFile.fromPath(
              'file',
              imageFile.path
          ),
        );

        final response = await request.send();

        return response;

      } else {
        debugPrint('Mottagen fil var null');
        return null;
      }
    } catch (e) {
      debugPrint('GoogleStorage Error $e');
      return null;
    }
  }

  Future<bool> sendPictureToBackend(File? imageFile) async {
    try {
      //Vänta på att bilden laddas upp och få tillbaka URL:en
      final objectKey = await sendPictureToGoogleStorage(imageFile);

      //Skicka URL till backend
      final response = await http.post(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/pictures'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': jwtToken,
          //skicka med url till backend som google ger tillbaka
          'objectKey': objectKey,
          'targetType': 'PLANT',
          'PictureMode': 'CHALLENGE',

        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Backend Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Skicka bild till backend Error $e');
      return false;
    }
  }

}



/// profilbild metoder


  // ladda upp bild till google storage
   Future<String> sendPictureToGoogleStorage(
      Uint8List bytes,
      String filename,
      String token,
      ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://group-6-15.pvt.dsv.su.se/upload',
      ),
    );

    // Lägg till token för att tillåtas ladda upp
    request.headers['Authorization'] =
    'Bearer $token';

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

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final data = jsonDecode(responseBody);

      return data['objectKey'];
    } else {
      throw Exception(
        'Misslyckades att ladda upp bild',
      );
    }
  }

  // spara url från google storage till backend
 Future<void> saveProfileImage(
      String assetPath,
      ) async {
    const baseUrl =
        'https://group-6-15.pvt.dsv.su.se';

    try {
      // 1. Hämta sessionen

      final token = await SessionStorage().getToken();

      if (token == null) {
        throw Exception(
          "Ingen aktiv session hittades",
        );
      }

      // 2. Konvertera asset till bytes
      final Uint8List bytes =
      (await rootBundle.load(assetPath))
          .buffer
          .asUint8List();

      // 3. Ladda upp till Google Storage
      final imageUrl =
      await sendPictureToGoogleStorage(
        bytes,
        assetPath.split('/').last,
        token,
      );

      // 4. Spara URL:en i backend
      final response = await http.patch(
        Uri.parse(
          '$baseUrl/users/me/profile-image',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':
          'application/json',
        },
        body: jsonEncode({
          'profileImageUrl': imageUrl,
        }),
      );

      if (response.statusCode != 200) {
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

