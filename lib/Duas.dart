import 'package:flutter/material.dart';
import 'package:meqattest/Dua.dart';
import 'package:meqattest/Settings.dart';
import 'package:meqattest/menu.dart';

import 'home.dart';

class DuasPage extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Travel', 'icon': Icons.flight_takeoff},
    {'title': 'Ihram', 'icon': Icons.checkroom},
    {'title': 'Tawaf', 'icon': Icons.sync},
    {'title': 'Sa\'ee', 'icon': Icons.directions_walk},
    {'title': 'Hajj', 'icon': Icons.mosque},
    {'title': 'Umrah', 'icon': Icons.emoji_people},
    {'title': 'Worship', 'icon': Icons.handshake},
    {'title': 'Need', 'icon': Icons.favorite},
    {'title': 'Repentance', 'icon': Icons.volunteer_activism},
    {'title': 'Adoration', 'icon': Icons.star},
    {'title': 'Hope', 'icon': Icons.wb_sunny},
    {'title': 'Intercession', 'icon': Icons.group},
    {'title': 'Protection', 'icon': Icons.security},
    {'title': 'Istikhara', 'icon': Icons.lightbulb},
    {'title': 'All', 'icon': Icons.menu_book},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dua', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            // Swipe left to go to HomePage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (details.primaryVelocity! > 0) {
            // Swipe right to go back to MenuPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuPage()),
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
                  if (index == 0 || index == 4) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DuaPage()),
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
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
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
