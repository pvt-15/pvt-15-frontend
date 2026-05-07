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
              if (selectedImage !=null)
                Image.file(
                  selectedImage!,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: takePicture,
                child: const Text("Ta bild"),
              )
            ],
          )
      )
    );
  }
  
}