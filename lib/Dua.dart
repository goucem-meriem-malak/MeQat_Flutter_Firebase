import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:meqattest/Duas.dart';
import 'package:meqattest/Settings.dart';
import 'package:meqattest/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class DuaPage extends StatefulWidget {
  @override
  _DuaPageState createState() => _DuaPageState();
}

class _DuaPageState extends State<DuaPage> {
  final FlutterTts _flutterTts = FlutterTts();
  double speechRate = 1.0; // Default speed
  int currentIndex = 0;
  String userLanguage = "";
  List<Map<String, String>> duas = [
    {
      "arabic": "اللهم إني أسألك...",
      "translation": "O Allah, I ask you..."
    },
    {
      "arabic": "أستغفر الله...",
      "translation": "I seek forgiveness from Allah..."
    },
    {
      "arabic": "الله أكبر...",
      "translation": "Glory be to Allah and praise be to Him..."
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserLanguage();
  }

  Future<void> _loadUserLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userLanguage = prefs.getString('language') ?? "en";
    });
  }

  Future<void> _speak(String text, int index) async {
    await _flutterTts.setLanguage(userLanguage == "ar" ? "ar-SA" : "en-US");
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.speak(text);
    setState(() {
      currentIndex = index; // Change indicator color
    });
  }

  void _changeSpeed() {
    List<double> speeds = [0.25, 0.5, 0.75, 1, 1.5, 2];
    setState(() {
      int index = speeds.indexOf(speechRate);
      speechRate = speeds[(index + 1) % speeds.length];
    });
  }

  void _handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DuasPage(),
        ),
      );
    } else if (details.primaryVelocity! < 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _handleSwipe, // Detect left/right swipe
      child: Scaffold(
        appBar: AppBar(
          title: Text("Dua"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Row(
          children: [
            // Progress indicator (moved slightly to the right)
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(duas.length, (index) {
                  return Column(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: currentIndex == index ? Colors.orange : Colors.grey,
                      ),
                      if (index < duas.length - 1)
                        Container(width: 2, height: 30, color: Colors.grey),
                    ],
                  );
                }),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: duas.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = index; // Highlight selected circle
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.grey[300],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.volume_up),
                                    onPressed: () => _speak(duas[index]["arabic"]!, index),
                                  ),
                                  Text("${speechRate}x"),
                                  IconButton(
                                    icon: Icon(Icons.speed),
                                    onPressed: _changeSpeed,
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight, // Right align Arabic text
                                child: Text(
                                  duas[index]["arabic"]!,
                                  textDirection: TextDirection.rtl, // Ensures proper RTL layout
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                duas[index]["translation"]!,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
      ),
    );
  }
}
