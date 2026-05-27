// models/treasure_hunt_models.dart
import 'package:flutter/material.dart';

// Data model for treasure hunt task
class TreasureHuntTask {
  final int id;
  final bool mustBeUnique;
  final String? requiredCategory;
  final int requiredCount;
  final String? requiredLabel;
  final String taskText;
  final String taskType;
  final int challengeId;
  final int rewardPoints;
  final String? helpText;
  final String? referenceImageUrl;

  // Frontend progress
  bool isCompleted;
  int completedCount;
  List<String> completedLabels;

  TreasureHuntTask({
    required this.id,
    required this.mustBeUnique,
    this.requiredCategory,
    required this.requiredCount,
    this.requiredLabel,
    required this.taskText,
    required this.taskType,
    required this.challengeId,
    this.rewardPoints = 0,
    this.helpText,
    this.referenceImageUrl,
    this.isCompleted = false,
    this.completedCount = 0,
    this.completedLabels = const [],
  });

  factory TreasureHuntTask.fromJson(Map<String, dynamic> json) {
    return TreasureHuntTask(
      id: json['id'] as int,
      mustBeUnique: json['mustBeUnique'] == 1 || json['mustBeUnique'] == true,
      requiredCategory: json['requiredCategory'] as String?,
      requiredCount: json['requiredCount'] as int? ?? 1,
      requiredLabel: json['requiredLabel'] as String?,
      taskText: json['taskText'] as String? ?? '',
      taskType: json['taskType'] as String? ?? 'CATEGORY',
      challengeId: json['challengeId'] as int? ?? 0,
      rewardPoints: json['rewardPoints'] as int? ?? 0,
      helpText: json['helpText'] as String?,
      referenceImageUrl: json['referenceImageUrl'] as String?,
    );
  }

  String? getFullReferenceImageUrl() {
    if (referenceImageUrl == null) return null;
    if (referenceImageUrl!.startsWith('http')) return referenceImageUrl;
    return 'https://group-6-15.pvt.dsv.su.se/$referenceImageUrl';
  }

  String getDisplayText() {
    if (taskText.isNotEmpty && taskText != 'null') {
      return taskText;
    }

    if (taskType == 'LABEL' && requiredLabel != null) {
      return 'Hitta en ${_getSwedishName(requiredLabel!)}';
    } else if (taskType == 'CATEGORY' && requiredCategory != null) {
      return 'Hitta en ${_getCategorySwedishName(requiredCategory!)}';
    }

    return taskText;
  }

  String _getSwedishName(String englishLabel) {
    final translations = {
      'spruce': 'gran',
      'pine': 'tall',
      'birch': 'björk',
      'oak': 'ek',
      'rowan': 'rönn',
      'wood anemone': 'vitsippa',
      'dandelion': 'maskros',
      'rose': 'ros',
      'snail': 'snigel',
      'lavender': 'lavendel',
      'cherry blossom': 'körsbärsblomma',
      'moss': 'mossa',
      'bumblebee': 'humla',
    };

    final lowerLabel = englishLabel.toLowerCase();
    for (var entry in translations.entries) {
      if (lowerLabel.contains(entry.key)) {
        return entry.value;
      }
    }
    return englishLabel.toLowerCase();
  }

  String _getCategorySwedishName(String category) {
    switch (category) {
      case 'TREE': return 'träd';
      case 'PLANT': return 'växt';
      case 'ANIMAL': return 'djur';
      case 'FLOWER': return 'blomma';
      case 'BIRD': return 'fågel';
      case 'INSECT': return 'insekt';
      default: return category.toLowerCase();
    }
  }

  String getTargetType() {
    if (requiredCategory != null && requiredCategory!.isNotEmpty) {
      return requiredCategory!;
    }

    if (taskType == 'LABEL') return 'PLANT';
    return 'PLANT';
  }

  bool canCompleteWithNewLabel(String label) {
    if (isCompleted) return false;

    if (taskType == 'LABEL' && requiredLabel != null) {
      final normalizedLabel = label.toLowerCase().trim();
      final normalizedRequired = requiredLabel!.toLowerCase().trim();
      final isMatch = normalizedLabel == normalizedRequired ||
          normalizedLabel.contains(normalizedRequired) ||
          normalizedRequired.contains(normalizedLabel);

      if (!isMatch) return false;

      if (mustBeUnique) {
        return !completedLabels.contains(label);
      }
      return true;
    } else if (taskType == 'CATEGORY') {
      if (mustBeUnique) {
        return !completedLabels.contains(label);
      }
      return true;
    }

    return false;
  }

  void addCompletedPicture(String label) {
    if (isCompleted) return;

    completedCount++;
    if (!completedLabels.contains(label)) {
      completedLabels = [...completedLabels, label];
    }

    if (completedCount >= requiredCount) {
      isCompleted = true;
    }
  }
}

// Helper class for verification result
class VerificationResult {
  final bool success;
  final String label;
  final int pointsAwarded;
  final String? errorMessage;

  VerificationResult({
    required this.success,
    this.label = '',
    this.pointsAwarded = 0,
    this.errorMessage,
  });

  factory VerificationResult.success({
    required String label,
    int pointsAwarded = 0,
  }) {
    return VerificationResult(
      success: true,
      label: label,
      pointsAwarded: pointsAwarded,
    );
  }

  factory VerificationResult.failure(String message) {
    return VerificationResult(
      success: false,
      errorMessage: message,
    );
  }
}