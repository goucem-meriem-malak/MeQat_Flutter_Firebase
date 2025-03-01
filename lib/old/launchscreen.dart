import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class AnimationScreen extends StatefulWidget {
  @override
  _AnimationScreenState createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> {
  int _currentStep = 0;
  List<bool> _showLetters = [];
  Color _backgroundColor = Color(0xFF2D2D2D); // Dark grey background

  @override
  void initState() {
    super.initState();
    _showLetters = List<bool>.filled("MeQat".length, false);
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    for (int i = 0; i < 4; i++) {
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _currentStep = (i + 1).clamp(0, 4);
      });
    }

    // Start showing letters one by one
    for (int i = 0; i < _showLetters.length; i++) {
      await Future.delayed(Duration(milliseconds: 300));
      setState(() {
        _showLetters[i] = true;
      });
    }

    // Change background color after the animation ends
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _backgroundColor = Color(0xFFF8F8F8); // Soft white background
    });

    // Wait a little before transitioning to the next screen
    await Future.delayed(Duration(seconds: 1));

    // Check if preferences are set
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('language');
    String? madhhab = prefs.getString('madhhab');
    String? transportation = prefs.getString('transportation');

    if (language != null && madhhab != null && transportation != null) {
      // If all preferences are set, navigate to HomePage directly
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // Adjust if needed
      );
    } else {
      // If not all preferences are set, navigate to the preferences page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // Adjust if needed
      );
    }
  }

  Color _getTextColorBasedOnBackground() {
    // Use luminance to determine if the background is light or dark
    double luminance = _backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white; // Return black if light, white if dark
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(seconds: 1),
        color: _backgroundColor,
        child: Stack(
          children: [
            _buildAnimatedImage(
              step: 1,
              image: 'assets/img1.png',
              beginPosition: Offset(0, 1),
              endPosition: Offset(0, 0),
              isSliding: true,
            ),
            _buildAnimatedImage(
              step: 2,
              image: 'assets/img2.png',
              beginPosition: Offset(0, 0),
              endPosition: Offset(0, 0),
              isSliding: false,
            ),
            _buildAnimatedImage(
              step: 3,
              image: 'assets/img3.png',
              beginPosition: Offset(0, 0),
              endPosition: Offset(0, 0),
              isSliding: false,
            ),
            _buildAnimatedImage(
              step: 4,
              image: 'assets/img4.png',
              beginPosition: Offset(0, 0),
              endPosition: Offset(0, 0),
              isSliding: false,
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 140),
                  _buildMiqatraText(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiqatraText() {
    Color textColor = _getTextColorBasedOnBackground();  // Get the dynamic text color

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: "MeQat".split('').asMap().entries.map((entry) {
        int index = entry.key;
        String letter = entry.value;
        return AnimatedOpacity(
          opacity: _showLetters[index] ? 1.0 : 0.0,
          duration: Duration(milliseconds: 200),
          child: Text(
            letter,
            style: TextStyle(
              fontFamily: 'Scheherazade', // Apply the Scheherazade font
              color: textColor, // Apply dynamic text color
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnimatedImage({
    required int step,
    required String image,
    required Offset beginPosition,
    required Offset endPosition,
    required bool isSliding,
  }) {
    return AnimatedPositioned(
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
      top: _currentStep >= step
          ? MediaQuery.of(context).size.height / 2 - 100 // Center the image
          : isSliding
          ? (beginPosition.dy > 0
          ? MediaQuery.of(context).size.height
          : -200) // Start off-screen
          : MediaQuery.of(context).size.height / 2 - 100,
      left: MediaQuery.of(context).size.width / 2 - 100, // Center the image horizontally
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: _currentStep >= step ? 1.0 : 0.0,
        child: Image.asset(
          image,
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}