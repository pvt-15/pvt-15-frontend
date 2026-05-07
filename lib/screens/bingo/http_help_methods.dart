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

      debugPrint(response.body);

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

      debugPrint(response.body);

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

  Future<String> getAllChallenges() async {
    try {
      final response = await http.get(
          Uri.parse('https://group-6-15.pvt.dsv.su.se/challenges'),
          headers: {
            'Authorization': 'Bearer $jwtToken',
          }
      );
      return response.body;
    } catch (e) {
      throw Exception('Något gick fel vid inhämtning av fråga $e');
    }
  }

  Future<Map<String, dynamic>> decodeAllChallenges() async {
    String challenges = await getAllChallenges();

  }



}