import 'package:flutter/material.dart';
import 'package:Skogsjakten/screens/home.dart';
import 'package:Skogsjakten/screens/home/home_library.dart';
import 'package:Skogsjakten/screens/home/species_profile.dart';
import 'package:Skogsjakten/screens/profile/profile.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CustomNavigationBar extends StatelessWidget {
  final int? selectedIndex;

  const CustomNavigationBar({
    super.key,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFF84C06C),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(
            context: context,
            index: 0,
            icon: Icons.person_outline,
            page: const Profile(),
          ),
          _navIcon(
            context: context,
            index: 1,
            icon: Icons.home_outlined,
            page: const HomeScreen(name: 'test'),
          ),
          _navIcon(
            context: context,
            index: 2,
            icon: Icons.menu_book_outlined,
            page: const HomeLibrary(),
          ),
        ],
      ),
    );
  }

  Widget _navIcon({
    required BuildContext context,
    required int index,
    required IconData icon,
    required Widget page,
  }) {
    final bool isSelected = selectedIndex == index;

    return IconButton(
      icon: Icon(
        icon,
        color: Colors.black,
        size: isSelected ? 36 : 32,
      ),
      onPressed: () {
        if (isSelected) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}