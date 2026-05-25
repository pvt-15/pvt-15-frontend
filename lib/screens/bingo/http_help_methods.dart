import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;


class HttpHelpMethods {
  final String? jwtToken;

  const HttpHelpMethods({required this.jwtToken});

  Future<Map<String, dynamic>> getStartedQuestion(int challengeId) async {

    try {
      final response = await http.get(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/challenges/$challengeId'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      //debugPrint(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Kunde inte hämta fråga (${response.statusCode})');
      }

    } catch (e) {
      throw Exception('Något gick fel vid inhämtning av fråga $e');
    }
  }

  Future<Map<String, dynamic>> getNewQuestion(String difficulty, String type, String? category) async {

    difficulty = difficulty.toUpperCase();
    type = type.toUpperCase();
    category = category?.toUpperCase();

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
          'challengeCategory': category,
        }),
      );

      //debugPrint(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Kunde inte hämta fråga (${response.statusCode})');
      }

    } catch (e) {
      throw Exception('Något gick fel vid inhämtning av fråga $e');
    }
  }

  Future<Map<String, dynamic>> getQuestionOnId(int id) async {
    try {
      final response = await http.post(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/challenges/$id/start'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      //debugPrint(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Kunde inte hämta fråga (${response.statusCode})');
      }

    } catch (e) {
      throw Exception('Något gick fel vid inhämtning av fråga $e');
    }
  }

  Future<List<dynamic>>  getAllChallenges() async {
    try {
      final response = await http.get(
          Uri.parse('https://group-6-15.pvt.dsv.su.se/challenges'),
          headers: {
            'Authorization': 'Bearer $jwtToken',
          }
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      throw Exception('Något gick fel vid inhämtning av alla utmaningar $e');
    }
  }

  String? mapCategoryToBackendForChallenge(String category) {
    final random = Random();
    
    if (category == 'Träd') {
      return 'TREE';
    }
    
    if (category == 'Växter') {
      // Slumpa mellan PLANT och FLOWER
      List<String> options = ['PLANT', 'FLOWER'];
      return options[random.nextInt(options.length)];
    }
    
    if (category == 'Djur') {
      // Slumpa mellan ANIMAL, INSECT och BIRD
      List<String> options = ['ANIMAL', 'INSECT', 'BIRD'];
      return options[random.nextInt(options.length)];
    }
    
    if (category == 'Blandad') {
      return null;
    }
    
    return null;
  }
  
  String? mapCategoryToBackendForPictureUpload(String category) {
    if (category == 'Träd' || category == 'Växt' || category == 'Blomma') {
      return 'PLANT';
    }
    if (category == 'Djur' || category == 'Insekt' || category == 'Fågel') {
      return 'ANIMAL';
    }
    return null;
  }

  Future<Map<String, dynamic>> getPicturesForChallenge(int id) async {
    try {
      final response = await http.get(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/challenges/$id/pictures'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
        }
      );
      debugPrint(response.body);
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      throw Exception('Något gick fel vid inhämtning av bilder $e');
    }
  }

  Future<List<dynamic>> getPictures() async {
    try {
      final response = await http.get(
          Uri.parse('https://group-6-15.pvt.dsv.su.se/pictures'),
          headers: {
            'Authorization': 'Bearer $jwtToken',
          }
      );
      debugPrint(jwtToken);
      //debugPrint(response.body);
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      throw Exception('Något gick fel vid inhämtning av bilder $e');
    }
  }

  Future<Map<String, dynamic>> endStartedChallenge(int id) async {
    try {
      final response = await http.delete(
          Uri.parse('https://group-6-15.pvt.dsv.su.se/challenges/$id/progress'),
          headers: {
            'Authorization': 'Bearer $jwtToken',
          }
      );
      //debugPrint(response.body);
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      throw Exception('Något gick fel avslutande av utmaning $e');
    }
  }

}
