import 'package:flutter/material.dart';
import 'package:Skogsjakten/screens/profile/profile.dart';
import 'package:Skogsjakten/services/session_storage.dart';
import 'package:Skogsjakten/services/upload_picture.dart';
import 'package:Skogsjakten/widgets/custom_navigation_bar.dart';

class ProfilePic extends StatefulWidget {
  const ProfilePic({super.key});

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  final List<String> imagePaths = [
    'assets/rav.png',
    'assets/bjorn.png',
    'assets/gravling.png',
    'assets/alg.png',
    'assets/mus.png',
    'assets/orm.png',
  ];

  String? selectedImagePath;
  bool isSaving = false;

  Future<void> handleSave() async {
    if (selectedImagePath == null) return;

    setState(() {
      isSaving = true;
    });

    try {
      final storage = SessionStorage();
      final token = await storage.getToken();
      final uploadService = UploadPicture(jwtToken: token);

      await uploadService.saveProfileImage(selectedImagePath!);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const Profile(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kunde inte spara bilden. Försök igen.',
            style: TextStyle(
              color: Color(0xFF4C290C),
            ),
          ),
          backgroundColor: Colors.white,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        title: Text(
          'Välj profilbild',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: imagePaths.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final imagePath = imagePaths[index];
                final isSelected = selectedImagePath == imagePath;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImagePath = imagePath;
                    });
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF84C06C)
                            : const Color(0xFFC0008F),
                        width: 8,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 220,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: const Color(0xFF000000),
                  minimumSize: const Size(220, 60),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: (isSaving || selectedImagePath == null)
                    ? null
                    : handleSave,
                child: Text(
                  isSaving ? 'Sparar...' : 'Spara',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(
        selectedIndex: 0,
      ),
    );
  }
}