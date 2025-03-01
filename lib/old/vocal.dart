import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart'; // Language detection

class VocalPage extends StatefulWidget {
  @override
  _VocalPageState createState() => _VocalPageState();
}

class _VocalPageState extends State<VocalPage> {
  final TextEditingController _textController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  String detectedLanguage = "Unknown";

  Future<void> _speak() async {
    String text = _textController.text.trim();
    if (text.isEmpty) return;

    // 🔍 Detect language using ML Kit
    String langCode = await detectLanguage(text);

    // 🌍 Set TTS to detected language
    await _flutterTts.setLanguage(langCode);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);

    // Update UI
    setState(() {
      detectedLanguage = langCode.toUpperCase();
    });
  }

  Future<String> detectLanguage(String text) async {
    try {
      final langCode = await _languageIdentifier.identifyLanguage(text);
      return _mapLanguageToTTS(langCode);
    } catch (e) {
      return "en-US"; // Default to English if detection fails
    }
  }

  // 🔹 Maps detected language to TTS-supported language codes
  String _mapLanguageToTTS(String langCode) {
    Map<String, String> langMap = {
      "en": "en-US", "fr": "fr-FR", "ar": "ar-SA", "es": "es-ES",
      "de": "de-DE", "it": "it-IT", "ru": "ru-RU", "zh": "zh-CN",
    };
    return langMap[langCode] ?? "en-US"; // Default to English
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Multi-Language TTS")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: "Enter text",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _speak,
              child: Text("🔊 Speak"),
            ),
            SizedBox(height: 20),
            Text(
              "Detected Language: $detectedLanguage",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
