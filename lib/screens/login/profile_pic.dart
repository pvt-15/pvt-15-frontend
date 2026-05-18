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
  List<ProfileImageOption> options = [];
  ProfileImageOption? selectedOption;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    try {
      final token = await SessionStorage().getToken();

      if (token == null) return;

      final service = UploadPicture(jwtToken: token);

      final result = await service.getProfileImageOptions();

      setState(() {
        options = result;
        isLoading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveImage() async {
    if (selectedOption == null) return;

    final token = await SessionStorage().getToken();

    if (token == null) return;

    final service = UploadPicture(jwtToken: token);

    await service.saveProfileImage(selectedOption!.avatarId);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Profile()),
    );
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: options.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected =
                    selectedOption?.avatarId == option.avatarId;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOption = option;
                    });
                  },
                  child: Container(
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
                      child: Image.network(
                        option.imageUrl,
                        fit: BoxFit.cover,
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
                  foregroundColor: Colors.black,
                  minimumSize: const Size(220, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed:
                selectedOption == null ? null : saveImage,
                child: Text(
                  'Spara',
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