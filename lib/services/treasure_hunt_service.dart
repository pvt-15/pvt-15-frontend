import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:Skogsjakten/services/session_storage.dart';
import 'package:Skogsjakten/services/upload_picture.dart';

class TreasureHuntService {
  final SessionStorage _sessionStorage = SessionStorage();

  /// Huvudmetod: ladda upp bild och verifiera mot AI
  Future<TreasureHuntResult> verifyTreePicture({
    required File imageFile,
    required String targetTreeName,  // t.ex. "Björk", "Ek"
    required String targetCategory,  // "TREE"
  }) async {
    try {
      final token = await _sessionStorage.getToken();
      if (token == null) {
        return TreasureHuntResult.failure('Ingen inloggning hittades');
      }

      // Steg 1: Ladda upp bild till Google Cloud Storage
      final uploadService = UploadPicture(jwtToken: token);
      final objectKey = await uploadService.sendPictureToGoogleStorage(imageFile);

      if (objectKey == null) {
        return TreasureHuntResult.failure('Kunde inte ladda upp bild');
      }

      debugPrint('Uppladdad bild, objectKey: $objectKey');

      // Steg 2: Skicka till AI för identifiering
      final aiResult = await _identifyWithAI(
        token: token,
        objectKey: objectKey,
      );

      if (aiResult == null) {
        return TreasureHuntResult.failure('AI-identifiering misslyckades');
      }

      debugPrint('=== TREASURE HUNT DEBUG ===');
      debugPrint('Target tree: $targetTreeName');
      debugPrint('AI label: ${aiResult.label}');
      debugPrint('AI confidence: ${aiResult.confidence}');
      debugPrint('Match: $aiResult');
      debugPrint('============================');

      debugPrint('AI resultat: ${aiResult.label}, confidence: ${aiResult.confidence}');

      // Steg 3: Kontrollera om det är rätt träd (med 75% tröskel)
      final isCorrect = _isCorrectTree(
        aiLabel: aiResult.label,
        targetTreeName: targetTreeName,
        confidence: aiResult.confidence,
        threshold: 0.75,
      );

      return TreasureHuntResult(
        success: isCorrect,
        aiLabel: aiResult.label,
        confidence: aiResult.confidence,
        pointsAwarded: aiResult.pointsAwarded,
        errorMessage: isCorrect ? null : 'Bilden känns inte igen som $targetTreeName. Försök igen!',
      );

    } catch (e) {
      debugPrint('TreasureHuntService fel: $e');
      return TreasureHuntResult.failure('Ett fel uppstod: $e');
    }
  }

  /// Skicka bild till AI via backend
  Future<AIResult?> _identifyWithAI({
    required String token,
    required String objectKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/pictures'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'imageObjectKey': objectKey,
          'targetType': 'PLANT',        // Viktigt: sätt till PLANT för träd
          'pictureMode': 'CHALLENGE',  // Använd CHALLENGE-läge
          'challengeId': '254' // TODO: TEMP
        }),
      );

      debugPrint('AI Response status: ${response.statusCode}');
      debugPrint('AI Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        return AIResult(
          label: data['label'] ?? 'Okänd',
          category: data['category'] ?? 'TREE',
          confidence: (data['aiConfidence'] as num?)?.toDouble() ?? 0.0,
          pointsAwarded: data['pointsAwarded'] ?? 0,
          imageUrl: data['imageUrl'] ?? '',
        );
      } else {
        debugPrint('AI identifiering misslyckades: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('AI anrop fel: $e');
      return null;
    }
  }

  /// Kontrollera om AI-resultatet matchar målet (med 75% tröskel)
  bool _isCorrectTree({
    required String aiLabel,
    required String targetTreeName,
    required double confidence,
    required double threshold,
  }) {
    // Normalisera strängar för jämförelse
    final normalizedAILabel = aiLabel.toLowerCase().trim();
    final normalizedTarget = targetTreeName.toLowerCase().trim();

    // Kollar om etiketten matchar (exakt eller innehåller)
    final labelMatches = normalizedAILabel == normalizedTarget ||
        normalizedAILabel.contains(normalizedTarget) ||
        normalizedTarget.contains(normalizedAILabel);

    // Kräver både matchande etikett OCH tillräckligt hög confidence
    return labelMatches && confidence >= threshold;
  }
}

/// Resultat från AI-identifiering
class AIResult {
  final String label;
  final String category;
  final double confidence;
  final int pointsAwarded;
  final String imageUrl;

  AIResult({
    required this.label,
    required this.category,
    required this.confidence,
    required this.pointsAwarded,
    required this.imageUrl,
  });
}

/// Resultat från TreasureHuntService
class TreasureHuntResult {
  final bool success;
  final String? aiLabel;
  final double? confidence;
  final int? pointsAwarded;
  final String? errorMessage;

  TreasureHuntResult({
    required this.success,
    this.aiLabel,
    this.confidence,
    this.pointsAwarded,
    this.errorMessage,
  });

  factory TreasureHuntResult.failure(String message) {
    return TreasureHuntResult(
      success: false,
      errorMessage: message,
    );
  }
}