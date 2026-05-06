import 'dart:convert';
import 'dart:io';

import 'package:Skogsjakten/screens/bingo/json_decode.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../services/token_storage.dart';

class BingoHelpMethods {
  final String? jwtToken;

  const BingoHelpMethods({required this.jwtToken});

  //Future<String?> token = TokenStorage().getToken();

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

  Future<String> getStartedQuestion(int challengeId) async {
    String errorMessage;

    try {
      final response = await http.get(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/challenges/$challengeId'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      debugPrint(response.body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        errorMessage = 'Kunde inte hämta fråga (${response.statusCode})';
        return errorMessage;
      }

    } catch (e) {
      errorMessage = 'Något gick fel vid inhämtning av fråga';
      return errorMessage;
    }
  }

  Future<String> getNewQuestion(String difficulty, String type) async {
    String errorMessage;

    try {
      final response = await http.post(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/challenges/start'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'challengeDifficulty': difficulty,
          'challengeType': type,
        }),
      );

      debugPrint(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return JsonDecode.jsonDecodeDescription(data);
      } else {
        errorMessage = 'Kunde inte hämta fråga (${response.statusCode})';
        return errorMessage;
      }

    } catch (e) {
      errorMessage = 'Något gick fel vid inhämtning av fråga ($e)';
      return errorMessage;
    }
  }

}