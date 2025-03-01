import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'home.dart';

class QRCodePage extends StatefulWidget {
  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  final Color primaryColor = Color(0xFF2D2D2D); // Dark grey color
  final Color accentColor = Color(0xFF4A4A4A); // Lighter grey accent
  final Color background = Color(0xFFF8F5F0);
  String? qrId;

  @override
  void initState() {
    super.initState();
    _generateAndSaveQRId();
  }

  Future<void> _generateAndSaveQRId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString('qr_id');
    if (storedId == null) {
      final newId = const Uuid().v4(); // Generate unique ID
      await prefs.setString('qr_id', newId);
      setState(() {
        qrId = newId;
      });
    } else {
      setState(() {
        qrId = storedId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
        Container(
        height: 110, // Shortened the black header
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50), // Rounded only on the left side
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: qrId == null
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text('QR Code ID:', style: TextStyle(fontSize: 18)),
            SelectableText(qrId!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            QrImageView(
              data: qrId!,
              version: QrVersions.auto,
              size: 200.0,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => HomePage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Done"),
            ),
          ],
        ),
    ),
    ],
    ),
    );
  }
}