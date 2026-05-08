import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

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
      final imageURL = await sendPictureToGoogleStorage(imageFile);

      //Skicka URL till backend
      final response = await http.post(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/pictures'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': jwtToken,
          //skicka med url till backend som google ger tillbaka
          'imageUrl': imageURL,
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