import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class UploadPicture {
  final String? jwtToken;

  const UploadPicture({required this.jwtToken});

  //se till att man innan anropet, skickar token med await

  Future<String?> sendPictureToGoogleStorage(File? imageFile) async {
    try {
      if (imageFile != null) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://group-6-15.pvt.dsv.su.se/storage-service/uploads/picture'),
        );

        request.headers['Authorization'] = 'Bearer $jwtToken';

        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();


        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(responseBody);
          return data['objectKey']; // Returnera objectKey, inte imageUrl
        } else {
          debugPrint('Upload misslyckades: ${response.statusCode}');
          return null;
        }
      }
    } catch (e) {
      debugPrint('GoogleStorage Error $e');
      return null;
    }
    return null;
  }

  Future<Map<String, dynamic>?> sendPictureToBackend(File? imageFile, String targetType, String pictureMode, int? challengeId) async {
    try {
      //Vänta på att bilden laddas upp och få tillbaka URL:en
      final imageObjectKey = await sendPictureToGoogleStorage(imageFile);

      targetType = targetType.toUpperCase();
      pictureMode = pictureMode.toUpperCase();

      if (imageObjectKey != null) {
        final Map<String, dynamic> body  = {
          'imageObjectKey': imageObjectKey,
          'targetType': targetType,
          'pictureMode': pictureMode,
        };

        if (challengeId != null) {
          body['challengeId'] = challengeId;
        }

      //Skicka URL till backend
      final response = await http.post(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/pictures'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),

        /*body: jsonEncode({
          'imageObjectKey': imageObjectKey,
          'pictureMode': pictureMode,
          'targetType': targetType,
          'challengeId': challengeId,

        }),*/
      );

      //print(response.statusCode);
      //print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Backend Error: ${response.statusCode}');
        return null;
      }
      }
      return null;
    } catch (e) {
      debugPrint('Skicka bild till backend Error $e');
      return null;
    }
  }

  Future<List<ProfileImageOption>> getProfileImageOptions() async {
    final response = await http.get(
      Uri.parse(
        'https://group-6-15.pvt.dsv.su.se/auth-service/users/profile-images/options',
      ),
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    debugPrint("GET STATUS: ${response.statusCode}");
    debugPrint("GET BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Kunde inte hämta profilbilder');
    }

    final List data = jsonDecode(response.body);

    return data
        .map((item) => ProfileImageOption.fromJson(item))
        .where((option) => option.imageUrl.isNotEmpty)
        .toList();
  }

  Future<void> saveProfileImage(String avatarId) async {
    if (jwtToken == null) {
      throw Exception('Ingen token hittades');
    }

    final response = await http.patch(
      Uri.parse('https://group-6-15.pvt.dsv.su.se/auth-service/users/me/profile-image'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({
        'avatarId': avatarId,
      }),
    );

    debugPrint("SAVE STATUS: ${response.statusCode}");
    debugPrint("SAVE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Kunde inte spara profilbild');
    }
  }

  // TODO Matilda lägg ny metod för upload/picture som faktiskt FUNGERERAR
  // Upload picture, utan AI! Används i daglig utmaning
  Future<Map<String, dynamic>?> uploadPicture(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://group-6-15.pvt.dsv.su.se/storage-service/uploads/picture'),
      );

      request.headers['Authorization'] = 'Bearer $jwtToken';
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        // Returnerar både imageUrl och objectKey
        return {
          //'imageUrl': data['imageUrl'],
          'objectKey': data['objectKey'],
        };
      } else {
        debugPrint('uploadPicture misslyckades: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('uploadPicture Error: $e');
      return null;
    }
  }

}

class ProfileImageOption {
  final String avatarId;
  final String imageUrl;

  ProfileImageOption({
    required this.avatarId,
    required this.imageUrl,
  });

  factory ProfileImageOption.fromJson(Map<String, dynamic> json) {
    return ProfileImageOption(
      avatarId: json['avatarId']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}