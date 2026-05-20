import 'dart:io';

import 'package:Skogsjakten/screens/identify_species/species_results.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:Skogsjakten/services/session_storage.dart';
import 'package:Skogsjakten/services/camera_service.dart';
import 'package:http/http.dart' as http;

class IdentifyCamera extends StatefulWidget{
  const IdentifyCamera({super.key});

  @override
  State<StatefulWidget> createState() => _IdentifyCameraState();

}

class _IdentifyCameraState extends State<IdentifyCamera> {
  final sessionStorage = SessionStorage();
  File? selectedImage;
  String? selectedCategory;

  bool isOpeningCamera = true;
  bool isIdentifying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      takePicture();
    });
  }
  
  Future<void> takePicture() async {
    setState(() {
      isOpeningCamera = true;
    });

    final image = await CameraService.takePicture();

    if (!mounted) return;

    setState(() {
      isOpeningCamera = false;
    });

    if (image == null) {
      Navigator.pop(context); // går tillbaka om användaren avbryter kameran
      return;
    }

    setState(() {
      selectedImage = image;
    });

    showCategoryDialog();
  }

    Future<void> showCategoryDialog() async {
      final category = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Vad tog du bild på?"),
            content: const Text("Välj kategori för identifieringen."),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, "PLANT");

                },
                child: const Text("Planta"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, "ANIMAL");
                },
                child: const Text("Djur"),
              ),
            ],
          );
        },
      );


      if (category == null) return;

      setState(() {
        selectedCategory = category;
      });

      await identifySpecies(category);

      print("Vald kategori: $selectedCategory");
    }


  Future<void> identifySpecies(String category) async {
    if (selectedImage == null) return;

    setState(() {
      isIdentifying = true;
    });

    final session = await sessionStorage.getUserAndToken();

    if (session == null) {
      print("Ingen session/token hittades");
      return;
    }

    final token = session.token;

    // 1. Ladda upp bilden
    final uploadRequest = http.MultipartRequest(
      'POST',
      Uri.parse('https://group-6-15.pvt.dsv.su.se/storage-service/uploads/picture'),
    );

    uploadRequest.headers['Authorization'] = 'Bearer $token';

    uploadRequest.files.add(
      await http.MultipartFile.fromPath(
        'file',
        selectedImage!.path,
      ),
    );

    final uploadResponse = await uploadRequest.send();
    final uploadBody = await uploadResponse.stream.bytesToString();

    if (uploadResponse.statusCode != 200) {
      print("Upload misslyckades: $uploadBody");
      return;
    }

    final uploadData = jsonDecode(uploadBody);
    final objectKey = uploadData['objectKey'];

    if (objectKey == null) {
      print("objectKey saknas i upload-response: $uploadBody");
      return;
    }

    // 2. Skapa picture + kör AI-identifiering
    final pictureResponse = await http.post(
      Uri.parse('https://group-6-15.pvt.dsv.su.se/pictures'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'imageObjectKey': objectKey,
        'targetType': category, // "PLANT" eller "ANIMAL"
        'pictureMode': 'COLLECTION',
      }),
    );

    if (pictureResponse.statusCode != 200 &&
        pictureResponse.statusCode != 201) {
      print("Identifiering misslyckades: ${pictureResponse.body}");
      return;
    }

    final result = jsonDecode(pictureResponse.body);

    if (!mounted) return;

    print("PICTURE STATUS: ${pictureResponse.statusCode}");
    print("PICTURE BODY: ${pictureResponse.body}");
    print("RESULT: $result");

    setState(() {
      isIdentifying = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeciesResults(
          image: selectedImage!,
          category: category,
          result: result,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: const Text("Identifiera art"),
        ),
      ),
      body: Center(
        child: isOpeningCamera
            ? const Text("Öppnar kameran...")
            : isIdentifying
            ? const Text("Identifierar art...")
            : const SizedBox(),
        ),
    );
  }

}