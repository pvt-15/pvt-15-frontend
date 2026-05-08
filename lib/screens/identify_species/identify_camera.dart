import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:Skogsjakten/services/session_storage.dart';
import 'package:Skogsjakten/services/camera_service.dart';

class IdentifyCamera extends StatefulWidget{
  const IdentifyCamera({super.key});

  @override
  State<StatefulWidget> createState() => _IdentifyCameraState();

}

class _IdentifyCameraState extends State<IdentifyCamera> {
  File? selectedImage;
  String? selectedCategory;


  @override
  void initeState() {
    super.initState();
    takePicture();
  }
  
  Future<void> takePicture() async{
    final image = await CameraService.takePicture();

    if (image == null) {
      return;
    }
    setState(() {
      selectedImage = image;
    });
    final category = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Vad tog du bild på?"),
          content: const Text("Välj kategori för identifieringen."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, "PLANT");
              },
              child: const Text("Planta"),
            ),
            TextButton(
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

    print("Vald kategori: $selectedCategory");
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedCategory != null)
                Text("Kategori: $selectedCategory"),
              const SizedBox(height: 15),
              if (selectedImage !=null)
                SizedBox(
                  width: 350,
                  height: 600,
                  child: Image.file(
                    selectedImage!,
                    width: 300,
                    height: 500,
                    fit: BoxFit.contain,
                  ),
                ),
              const SizedBox(height: 0),

              ElevatedButton(
                onPressed: takePicture,
                child: Text(selectedImage == null ? "Ta bild": "Ta om bild"),
              ),

              if (selectedImage != null)
                ElevatedButton(
                  onPressed: () {
                    print("vidare till art info");
                  },
                  child: Text("Ta reda på art")
                )
            ],
          )
      )
    );
  }
  
}