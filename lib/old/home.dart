import 'package:flutter/material.dart';
import 'package:meqattest/old/saying2.dart';
import 'package:meqattest/old/saying3.dart';
import 'package:meqattest/old/saying4.dart';
import 'package:meqattest/old/saying5.dart';
import 'saying1.dart';

class HomePage extends StatelessWidget {
  final Color primaryColor = Color(0xFF2D2D2D); // Dark grey color
  final Color accentColor = Color(0xFF4A4A4A); // Lighter grey accent
  final Color background = Color(0xFFF8F5F0); // Warm off-white background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sacred Sayings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor, primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: Container(
        color: background,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView.separated(
            itemCount: 5,
            separatorBuilder: (context, index) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildSayingCard(context, index + 1);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSayingCard(BuildContext context, int number) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: () => _handleCardTap(context, number),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFE6E6E6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.library_books_rounded,
                  color: primaryColor,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Saying $number',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A2A2A),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              _buildInfoButton(context, number),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoButton(BuildContext context, int number) {
    return IconButton(
      icon: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.info_outline_rounded,
          color: accentColor,
          size: 24,
        ),
      ),
      onPressed: () => _showInfoDialog(context, number),
    );
  }

  void _handleCardTap(BuildContext context, int number) {
    if (number == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => saying1()),
      );
    }
    else if (number == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => saying2()),
      );
    }
    else if (number == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => saying3()),
      );
    }
    else if (number == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => saying4()),
      );
    }
    else if (number == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => saying5()),
      );
    }
  }

  void _showInfoDialog(BuildContext context, int number) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Saying $number',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'It does not fit any madhab',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF444444),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
