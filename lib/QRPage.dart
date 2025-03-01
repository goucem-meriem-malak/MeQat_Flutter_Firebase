import 'package:flutter/material.dart';
import 'package:meqattest/home.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

import 'package:shared_preferences/shared_preferences.dart';

class QRPage extends StatefulWidget {
  final bool isMember; // true: member, false: leader

  QRPage({required this.isMember});

  @override
  _QRPageState createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  final Color primaryColor = Color(0xFF2D2D2D);
  final Color background = Color(0xFFF8F5F0);
  final qrKey = GlobalKey(debugLabel: 'QR');
  String? qrId;
  QRViewController? qrController;

  bool showCheckmark = false; // Flag for showing the checkmark

  @override
  void initState() {
    super.initState();
    _generateAndSaveQRId();
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("QR Scanner"),
      ),
      body: Center(
        child: showCheckmark
            ? _showCheckmarkScreen() // Show the checkmark when scanned
            : (widget.isMember ? _qrScanner() : _leaderPage()), // Member vs Leader UI
      ),
    );
  }

  // QR Scanner UI (Members)
  Widget _qrScanner() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logo.png', width: 120), // Replace with your image
        SizedBox(height: 20),
        Text("SCAN QR Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        // QR Scanner
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(20), // Adds 20 padding around the button
          child: SizedBox(
            width: double.infinity, // Makes the button full width
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: Colors.black12,
              ),
              onPressed: _pickFromGallery,
              icon: Icon(Icons.qr_code, color: Colors.white),
              label: Text("Pick from Gallery", style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    ); // <-- This should be a closing parenthesis, not a comma
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


  Widget _leaderPage() {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
            children: [
              Image.asset('assets/logo.png', width: 120),
              SizedBox(height: 5),
              Text(
                "All members must scan this!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),
                  QrImageView(
                    data: qrId!,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),


              const SizedBox(height: 5),
              Text(
                "New members:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              Container(
                width: 200,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 120, // Limit height to enable scrolling when needed
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text("Name 1", style: TextStyle(color: primaryColor)),
                        Text("Name 2", style: TextStyle(color: primaryColor)),
                        Text("Name 3", style: TextStyle(color: primaryColor)),
                        Text("Name 4", style: TextStyle(color: primaryColor)),
                        Text("Name 5", style: TextStyle(color: primaryColor)), // Add more to test scrolling
                        Text("Name 6", style: TextStyle(color: primaryColor)),
                        Text("Name 7", style: TextStyle(color: primaryColor)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20), // Adds 20 padding around the button
                child: SizedBox(
                  width: double.infinity, // Makes the button full width
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black12,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    },
                    child: const Text("Done", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Show Checkmark Screen
  Widget _showCheckmarkScreen() {
    return Center(
      child: Icon(Icons.check_circle, size: 100, color: Colors.green),
    );
  }

  // QR Code Scanner Handler
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      qrController = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      _showCheckmark();
    });
  }

  // Pick Image from Gallery
  void _pickFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _showCheckmark();
    }
  }

  // Show Checkmark for 0.5 seconds then go to home
  void _showCheckmark() {
    setState(() {
      showCheckmark = true; // Show checkmark
    });

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        showCheckmark = false; // Hide checkmark
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    });
  }
}
