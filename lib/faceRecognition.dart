import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Settings.dart';
import 'home.dart';
import 'menu.dart';

class FaceRecognitionApp extends StatefulWidget {
  @override
  _FaceRecognitionAppState createState() => _FaceRecognitionAppState();
}

class _FaceRecognitionAppState extends State<FaceRecognitionApp> {
  File? imageFile;
  bool isFaceScanned = false;

  @override
  void initState() {
    super.initState();
    _checkIfFaceScanned();
  }

  Future<void> _checkIfFaceScanned() async {
    final prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString("face_image");
    if (imagePath != null) {
      setState(() {
        imageFile = File(imagePath);
        isFaceScanned = true;
      });
    }
  }

  Future<void> _captureImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        imageFile = File(image.path);
        isFaceScanned = true;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("face_image", image.path);
    }
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _navigateTo(context, MenuPage()); // Swipe Right → Menu
        } else if (details.primaryVelocity! < 0) {
          _navigateTo(context, HomePage()); // Swipe Left → Home
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Face Scan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ℹ️ Important Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Having your face scan saved is important. If you get lost, someone can help you return.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),

              SizedBox(height: 20), // 🔹 Add space before the camera button

              // 📸 Camera Button (Simple Icon)
              IconButton(
                icon: Icon(Icons.camera_alt, size: 50, color: Colors.black),
                onPressed: _captureImage,
              ),

              // 🖼️ Show Captured Image (if available)
              if (imageFile != null) ...[
                SizedBox(height: 20),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(imageFile!, fit: BoxFit.cover),
                  ),
                ),
              ],

              // ✅ Check icon & confirmation text (Only if scanned)
              if (isFaceScanned) ...[
                SizedBox(height: 20), // 🔹 Add spacing before the check icon
                Icon(Icons.check_circle, color: Colors.green, size: 50),
                SizedBox(height: 8),
                Text(
                  "Face scan saved!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: SizedBox(
          height: 56,
          child: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 6.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: Colors.orange),
                  onPressed: () => _navigateTo(context, MenuPage()),
                ),
                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () => _navigateTo(context, HomePage()),
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () => _navigateTo(context, SettingsPage()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
