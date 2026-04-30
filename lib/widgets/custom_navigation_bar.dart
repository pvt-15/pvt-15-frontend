import 'package:flutter/material.dart';
import '../screens/home.dart';
import '../screens/home/home_library.dart';
import '../screens/home/species_profile.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(

      onDestinationSelected: (int index) {
        if (index == selectedIndex) return;

        //TODO ändra till profil när screen läggs till

        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SpeciesProfile()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen(name: 'test')),
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
          //selectedIcon: Icon(MdiIcons.account),
          label: 'Profil',
        ),
        NavigationDestination(
          icon: Icon(MdiIcons.homeOutline),
          //selectedIcon: Icon(MdiIcons.home),
          label: 'Hem',
        ),
        NavigationDestination(
          icon: Icon(MdiIcons.bookOpenPageVariantOutline),
          //selectedIcon: Icon(MdiIcons.bookOpenPageVariant),
          label: 'Bibliotek',
        ),
      ],
    );
  }
}
