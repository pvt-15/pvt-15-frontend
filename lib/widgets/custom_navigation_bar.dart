import 'package:Skogsjakten/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import '../screens/home.dart';
import '../screens/home/home_library.dart';
//import '../screens/home/species_profile.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';



class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    int navigationIndex;
    Color? markerColor;
    Widget profileSelectedIcon;

    if (selectedIndex == -1) {
      navigationIndex = 0;
      markerColor = Colors.transparent;
      profileSelectedIcon = Icon(MdiIcons.accountOutline, color: const Color(0xFFB1067E));
    } else {
      navigationIndex = selectedIndex;
      markerColor = null;
      profileSelectedIcon = Icon(MdiIcons.account);
    }

    return NavigationBar(
      selectedIndex: navigationIndex,
      indicatorColor: markerColor,

      onDestinationSelected: (int index) {
        if (index == selectedIndex) return;

        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Profile()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeLibrary()),
          );
        }
      },

      destinations: [
        NavigationDestination(
          icon: Icon(MdiIcons.accountOutline),
          selectedIcon: profileSelectedIcon,
          label: 'Profil',
        ),
        NavigationDestination(
          icon: Icon(MdiIcons.homeOutline),
          selectedIcon: Icon(
            MdiIcons.home
          ),
          label: 'Hem',
        ),
        NavigationDestination(
          icon: Icon(MdiIcons.bookOpenPageVariantOutline),
          selectedIcon: Icon(
            MdiIcons.bookOpenPageVariant
          ),
          label: 'Bibliotek',
        ),
      ],
    );
  }
}
