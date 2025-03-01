import 'package:flutter/material.dart';
import 'package:meqattest/Duas.dart';
import 'package:meqattest/Settings.dart';
import 'package:meqattest/faceRecognition.dart';
import 'package:meqattest/lost.dart';

import 'home.dart';

class MenuPage extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Dua', 'icon': Icons.book},
    {'title': 'Ihram', 'icon': Icons.checkroom},
    {'title': 'Hajj', 'icon': Icons.mosque},
    {'title': 'Umrah', 'icon': Icons.emoji_people},
    {'title': 'Face Scan', 'icon': Icons.face},
    {'title': 'Lost', 'icon': Icons.location_off},
    {'title': 'Dua', 'icon': Icons.menu_book},
    {'title': 'Dua', 'icon': Icons.library_books},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            itemCount: menuItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DuasPage()),
                    );
                  }
                  if (index == 4) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FaceRecognitionApp()),
                    );
                  }
                  if (index == 5) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LostPage()),
                    );
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(menuItems[index]['icon'], size: 30, color: Colors.black),
                    const SizedBox(height: 8),
                    Text(
                      menuItems[index]['title'],
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: SizedBox(
        height: 56,
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                color: Colors.orange,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MenuPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
