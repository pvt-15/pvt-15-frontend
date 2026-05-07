import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:Skogsjakten/services/session_storage.dart';
import 'package:Skogsjakten/services/session.dart';
import 'package:Skogsjakten/screens/home.dart';


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

  // Upload image to Google Storage through backend
  Future<String> sendPictureToGoogleStorage(
      Uint8List bytes,
      String filename,
      ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://group-6-15.pvt.dsv.su.se/upload',
      ),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ),
    );

    final response = await request.send();

    final responseBody =
    await response.stream.bytesToString();

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final data = jsonDecode(responseBody);

      return data['imageUrl'];
    } else {
      throw Exception(
        'Misslyckades att ladda upp bild',
      );
    }
  }

  // Save image URL to backend user
  Future<void> saveProfileImage(String assetPath) async {
    const baseUrl = 'https://group-6-15.pvt.dsv.su.se';

    try {
      // 1. Hämta sessionen
      final session = await SessionStorage().get();
      final token = session?.token;

      if (token == null) throw Exception("Ingen aktiv session hittades");

      // 2. Konvertera asset till bytes
      final Uint8List bytes = (await rootBundle.load(assetPath)).buffer.asUint8List();

      // 3. Ladda upp till Google Storage
      final imageUrl = await sendPictureToGoogleStorage(
        bytes,
        assetPath.split('/').last,
      );

      // 4. Spara URL:en i backend
      final response = await http.patch(
        Uri.parse('$baseUrl/users/me/profile-image'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'profileImageUrl': imageUrl,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Misslyckades att spara profilbild');
      }
    } catch (e) {
      debugPrint("Fel vid sparande: $e");
      rethrow;
    }
  }

  Future<void> handleSave() async {
    if (selectedImagePath == null) return;

    setState(() {
      isSaving = true;
    });

    try {
      await saveProfileImage(selectedImagePath!);

      if (mounted) {
        final session = await SessionStorage().get();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(name: session?.user.username ?? "Användare"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kunde inte spara bilden. Försök igen.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Välj profilbild',
          style: Theme.of(context)
              .textTheme
              .titleLarge,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding:
              const EdgeInsets.all(16),
              itemCount: imagePaths.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder:
                  (context, index) {
                final imagePath =
                imagePaths[index];

                final isSelected =
                    selectedImagePath ==
                        imagePath;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImagePath =
                          imagePath;
                    });
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration:
                    BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(
                            0xFF84C06C)
                            : const Color(
                            0xFFC0008F),
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
            padding:
            const EdgeInsets.all(16),
            child: SizedBox(
              width: 220,
              child: ElevatedButton(
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                      0xFF4CAF50),
                  foregroundColor:
                  const Color(
                      0xFF000000),
                  minimumSize:
                  const Size(220, 60),
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                        18),
                  ),
                ),
                onPressed: (isSaving || selectedImagePath == null)
                    ? null
                    : handleSave,
                child: Text(
                  isSaving
                      ? 'Sparar...'
                      : 'Spara',
                  style:
                  Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final session = await SessionStorage().get();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(
                      name: session?.user.username ?? "Användare",
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Hoppa över för nu',
              style: TextStyle(
                color: Color(0xFF4C290C),
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}