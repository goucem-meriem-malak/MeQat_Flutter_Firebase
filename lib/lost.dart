import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class LostPage extends StatefulWidget {
  @override
  _LostPageState createState() => _LostPageState();
}

class _LostPageState extends State<LostPage> {
  File? capturedImage;
  Interpreter? interpreter;
  bool? isPersonFound; // null = no result yet

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset("assets/facenet.tflite");
    print("✅ Model Loaded!");
  }

  Future<void> captureImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        capturedImage = File(image.path);
        isPersonFound = null; // Reset state before comparison
      });
      compareWithStoredFace();
    }
  }

  Future<void> compareWithStoredFace() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedImagePath = prefs.getString('face_image');

    if (savedImagePath == null) {
      setState(() => isPersonFound = false);
      return;
    }

    File savedImage = File(savedImagePath);

    final faceDetector = FaceDetector(options: FaceDetectorOptions());
    final faces1 = await faceDetector.processImage(InputImage.fromFile(savedImage));
    final faces2 = await faceDetector.processImage(InputImage.fromFile(capturedImage!));

    if (faces1.isEmpty || faces2.isEmpty) {
      setState(() => isPersonFound = false);
      return;
    }

    var embeddings1 = await getFaceEmbedding(savedImage);
    var embeddings2 = await getFaceEmbedding(capturedImage!);

    if (embeddings1 == null || embeddings2 == null) {
      setState(() => isPersonFound = false);
      return;
    }

    double distance = calculateEuclideanDistance(embeddings1, embeddings2);
    setState(() => isPersonFound = distance < 1.0);
  }

  Future<List<double>?> getFaceEmbedding(File image) async {
    var input = preprocessImage(image);
    var output = List<double>.filled(128, 0).reshape([1, 128]);

    interpreter!.run(input, output);
    return output[0];
  }

  List<List<List<List<double>>>> preprocessImage(File image) {
    return List.generate(1, (_) => List.generate(160, (_) => List.generate(160, (_) => List.generate(3, (_) => Random().nextDouble()))));
  }

  double calculateEuclideanDistance(List<double> vec1, List<double> vec2) {
    double sum = 0;
    for (int i = 0; i < vec1.length; i++) {
      sum += pow(vec1[i] - vec2[i], 2);
    }
    return sqrt(sum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Help Someone Lost")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "If you find someone lost, take a photo to check if they are registered.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(Icons.camera_alt, size: 50, color: Colors.black),
              onPressed: captureImage,
            ),
            SizedBox(height: 20),

            if (isPersonFound != null) ...[
              isPersonFound!
                  ? Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 50),
                  SizedBox(height: 8),
                  Text(
                    "✔️ Person Found!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              )
                  : Column(
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 50),
                  SizedBox(height: 8),
                  Text(
                    "❌ Person Not Found",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
