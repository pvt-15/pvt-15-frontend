import 'package:flutter/material.dart';

class GamificationPopupService {
  static Future<void> showIfNeeded({
    required BuildContext context,
    required bool leveledUp,
    required String? previousLevel,
    required String? currentLevel,
    required List<dynamic> newlyUnlockedBadges,
  }) async {
    if (!context.mounted) return;

    if (leveledUp && currentLevel != null) {
      await _showLevelUpPopup(
        context: context,
        previousLevel: previousLevel,
        currentLevel: currentLevel,
      );
    }

    if (!context.mounted) return;

    if (newlyUnlockedBadges.isNotEmpty) {
      await _showBadgePopup(
        context: context,
        badges: newlyUnlockedBadges,
      );
    }
  }

  static Future<void> _showLevelUpPopup({
    required BuildContext context,
    required String? previousLevel,
    required String currentLevel,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Grattis!', textAlign: TextAlign.center,),
          content: Text('Du har gått upp i nivå till $currentLevel!', textAlign: TextAlign.center,),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  static Future<void> _showBadgePopup({
    required BuildContext context,
    required List<dynamic> badges,
  }) {
    final badgeNames = badges.map((badge) {
      if (badge is Map<String, dynamic>) {
        return badge['name'] ?? 'Ny medalj';
      }

      if (badge is Map) {
        return badge['name'] ?? 'Ny medalj';
      }

      return 'Ny medalj';
    }).join(', ');

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ny medalj!', textAlign: TextAlign.center,),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /*Image.network(
                badges.first['imageUrl'],
                height: 120,
              ),
              Image.network(
                'https://storage.googleapis.com/skogsjakten-images/badge-icons/ANIMAL_GOLD.png',
                height: 120,
              ),*/
              if (badges.first['imageUrl'] != null &&
                  badges.first['imageUrl'].toString().isNotEmpty)
                Image.network(
                  badges.first['imageUrl'],
                  height: 120,
                ),

              const SizedBox(height: 16),

              Text(
                'Du låste upp: $badgeNames',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}