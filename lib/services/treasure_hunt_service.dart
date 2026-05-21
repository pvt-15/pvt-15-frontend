// services/treasure_hunt_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/treasure_hunt_models.dart';
import 'upload_picture.dart';

class TreasureHuntService {
  final String baseUrl = 'https://group-6-15.pvt.dsv.su.se';
  final String? jwtToken;
  late final UploadPicture _uploadPicture;

  TreasureHuntService({required this.jwtToken}) {
    _uploadPicture = UploadPicture(jwtToken: jwtToken);
  }

  Future<List<TreasureHuntTask>> getIncompleteTasksByDifficulty(String difficulty) async {
    try {
      final completedTaskIds = await getCompletedTaskIds();
      final allTasks = await getAllTasksByDifficulty(difficulty);

      final incompleteTasks = allTasks.where((task) =>
      !completedTaskIds.contains(task.id)
      ).toList();

      debugPrint('=== getIncompleteTasksByDifficulty($difficulty) ===');
      debugPrint('Totalt antal tasks: ${allTasks.length}');
      debugPrint('Slutförda tasks: ${completedTaskIds.length}');
      debugPrint('Återstående tasks: ${incompleteTasks.length}');

      return incompleteTasks;

    } catch (e) {
      throw Exception('Fel vid hämtning av tasks: $e');
    }
  }

  Future<List<TreasureHuntTask>> getAllTasksByDifficulty(String difficulty) async {
    final response = await http.get(
      Uri.parse('$baseUrl/challenges'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Kunde inte hämta challenges: ${response.statusCode}');
    }

    final List<dynamic> allChallenges = jsonDecode(response.body);
    final List<TreasureHuntTask> allTasks = [];

    debugPrint('=== getAllTasksByDifficulty($difficulty) ===');

    for (var challenge in allChallenges) {
      final challengeId = challenge['id'] as int;
      final challengeType = challenge['type'] as String? ?? '';
      final challengeDifficulty = challenge['difficulty'] as String? ?? '';
      final isActive = challenge['active'] == true || challenge['active'] == 1;

      if (challengeType.toUpperCase() == 'TREASURE_HUNT' &&
          challengeDifficulty == difficulty &&
          isActive) {

        debugPrint('Hittade aktiv TREASURE_HUNT challenge: id=$challengeId');

        final detailsResponse = await http.get(
          Uri.parse('$baseUrl/challenges/$challengeId'),
          headers: {
            'Authorization': 'Bearer $jwtToken',
            'Content-Type': 'application/json',
          },
        );

        if (detailsResponse.statusCode == 200) {
          final challengeDetails = jsonDecode(detailsResponse.body);
          final tasks = challengeDetails['tasks'] as List? ?? [];

          for (var task in tasks) {
            final taskObj = TreasureHuntTask.fromJson(task);
            if (taskObj.challengeId == 0) {
              final correctedTask = TreasureHuntTask(
                id: taskObj.id,
                mustBeUnique: taskObj.mustBeUnique,
                requiredCategory: taskObj.requiredCategory,
                requiredCount: taskObj.requiredCount,
                requiredLabel: taskObj.requiredLabel,
                taskText: taskObj.taskText,
                taskType: taskObj.taskType,
                challengeId: challengeId,
                helpText: taskObj.helpText,
                referenceImageUrl: taskObj.referenceImageUrl,
              );
              allTasks.add(correctedTask);
            } else {
              allTasks.add(taskObj);
            }
          }
        }
      }
    }

    debugPrint('RESULTAT: ${allTasks.length} tasks totalt');
    return allTasks;
  }

  Future<Set<int>> getCompletedTaskIds() async {
    try {
      final myChallenges = await _getMyChallenges();
      final Set<int> completedTaskIds = {};

      for (var challenge in myChallenges) {
        final challengeId = challenge['id'] as int;
        final challengeType = challenge['type'] as String? ?? '';

        if (challengeType.toUpperCase() == 'TREASURE_HUNT') {
          final details = await getChallengeDetails(challengeId);
          final tasks = details['tasks'] as List? ?? [];

          for (var task in tasks) {
            final taskId = task['id'] as int;
            final taskStatus = task['status'] as String? ?? 'NOT_STARTED';

            if (taskStatus == 'COMPLETED') {
              completedTaskIds.add(taskId);
            }
          }
        }
      }

      return completedTaskIds;

    } catch (e) {
      debugPrint('Fel vid hämtning av slutförda tasks: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getChallengeDetails(int challengeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/challenges/$challengeId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Kunde inte hämta challenge-detaljer: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> startChallenge(int challengeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/challenges/$challengeId/start'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Kunde inte starta challenge: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  Future<VerificationResult> takeAndVerifyPicture({
    required File imageFile,
    required String targetType,
    required int challengeId,
  }) async {
    try {
      if (challengeId <= 0) {
        return VerificationResult.failure('Ogiltigt challengeId: $challengeId');
      }

      final objectKey = await _uploadPicture.sendPictureToGoogleStorage(imageFile);

      if (objectKey == null) {
        return VerificationResult.failure('Kunde inte ladda upp bild');
      }

      final result = await _verifyPicture(
        objectKey: objectKey,
        targetType: targetType,
      );

      if (result['accepted'] == true) {
        final picture = result['picture'];
        final label = picture?['label'] as String? ?? '';

        return VerificationResult.success(
          label: label,
          pointsAwarded: picture?['pointsAwarded'] as int? ?? 0,
        );
      } else {
        final message = result['message'] as String? ?? 'Bilden kändes inte igen';
        return VerificationResult.failure(message);
      }
    } catch (e) {
      return VerificationResult.failure('Ett fel uppstod vid verifiering');
    }
  }

  Future<Map<String, dynamic>> _verifyPicture({
    required String objectKey,
    required String targetType,
  }) async {
    final Map<String, dynamic> requestBody = {
      'imageObjectKey': objectKey,
      'targetType': targetType,
      'pictureMode': 'COLLECTION',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/pictures'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Verifiering misslyckades: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> _getMyChallenges() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/challenges/me'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}