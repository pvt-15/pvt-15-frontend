import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Denna klass hanterar översättning från engelska till svenska
class TranslationService {
  // MyMemory API
  static const String _baseUrl = 'https://api.mymemory.translated.net/get';

  // lista med manuella översättningar
  static final Map<String, String> _manualTranslations = {
    'Daisy': 'Prästkrage',
    'Dog' : 'Hund',
    'Dairy cattle' : 'Ko',
    'Japanese flowering cherry' : 'Körsbärsträd',
    'Ladybird beetle' : 'Nyckelpiga',
    'Gulls' : 'Mås',
    'Common lilac' : 'Syren',
    'Persian lilac' : 'Syren',
    'Garden Pansy' : 'Penséer',
    'Sweet William' : 'Nejlikor',
    'Rowan' : 'Rönn',
  };

  // debugging - skriv ut manuella översättningar
  static void debugPrintManualTranslations() {
    debugPrint('=== MANUAL TRANSLATIONS (${_manualTranslations.length} st) ===');
    for (final entry in _manualTranslations.entries) {
      debugPrint('  "${entry.key}" -> "${entry.value}"');
    }
    debugPrint('===========================================');
  }

  // översätter från engelska till svenska
  static Future<String> translateWord(String englishWord) async {
    if (englishWord.isEmpty) {
      return '';
    }

    debugPrint('=== Translating: "$englishWord" ===');

    // kollar om det finns manuell översättning
    if (_manualTranslations.containsKey(englishWord)) {
      final manualTranslation = _manualTranslations[englishWord]!;
      debugPrint('USING MANUAL TRANSLATION FOR: "$englishWord" -> "$manualTranslation"');
      return manualTranslation;
    }

    debugPrint('No manual translation found for "$englishWord"');
    debugPrint('Available manual keys: ${_manualTranslations.keys.toList()}');

    try {
      // kalla på APIn
      final response = await http.get(
        Uri.parse('$_baseUrl?q=${Uri.encodeComponent(englishWord)}&langpair=en|sv'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // hämta översatta texten
        String translatedText = data['responseData']['translatedText'];

        debugPrint('API response: "$translatedText"');

        // returnerar samma text om översättning inte finns
        // eller skickar error
        if (translatedText.contains('[MESSAGE]') ||
            translatedText == englishWord) {
          debugPrint('API could not translate: $englishWord');
          return englishWord; // returnera engelskt ord om översättning inte finns
        }

        debugPrint('API translated "$englishWord" to "$translatedText"');
        return translatedText;
      } else {
        debugPrint('Translation API error: ${response.statusCode}');
        return englishWord;
      }
    } catch (e) {
      debugPrint('Error during translation: $e');
      return englishWord;
    }
  }

  // möjlighet att översätta flera ord på en gång
  static Future<Map<String, String>> translateMultipleWords(
      List<String> englishWords
      ) async {
    final Map<String, String> translations = {};

    for (final word in englishWords) {
      final translated = await translateWord(word);
      translations[word] = translated;

      // lägg till kort delay mellan översättningarna
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return translations;
  }

  // check så att APIn är tillgänglig
  static Future<bool> checkApiAvailability() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?q=test&langpair=en|sv'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API availability check failed: $e');
      return false;
    }
  }
}