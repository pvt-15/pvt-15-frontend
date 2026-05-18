import 'dart:convert';
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

  String? mapCategoryToBackend(String category) {
    if (category == 'Träd') return 'TREE';
    if (category == 'Växter') return 'PLANT';
    if (category == 'Djur') return 'ANIMAL';
    return null; // För 'Blandad'
  }

  Future<Map<String, dynamic>> getOrCreateBingoChallenge(String category, String difficulty) async {
    List<dynamic> all = await getAllChallenges();
    String? backendCategory = mapCategoryToBackend(category);

    for (var challenge in all) {
      if (challenge['type'] == 'BINGO' && challenge['category'] == backendCategory && challenge['status'] == 'IN_PROGRESS') {
        return challenge;
      }
    }
    return await getNewQuestion(difficulty, 'BINGO', backendCategory);
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