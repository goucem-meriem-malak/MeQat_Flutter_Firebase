import 'package:flutter/material.dart';
import 'package:meqattest/QRPage.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final Color primaryColor = Color(0xFF2D2D2D);
  final Color accentColor = Color(0xFF4A4A4A);
  final Color background = Color(0xFFF8F5F0);

  bool isMember = true; // Default to Member

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, size: 50, color: primaryColor),
                ),
                const SizedBox(height: 20),

                // Toggle Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Leader", style: TextStyle(color: primaryColor)),
                    Switch(
                      value: isMember,
                      onChanged: (value) {
                        setState(() {
                          isMember = value;
                        });
                      },
                      activeColor: primaryColor,
                    ),
                    Text("Member", style: TextStyle(color: primaryColor)),
                  ],
                ),
                const SizedBox(height: 20),

                _buildTextField("First Name"),
                const SizedBox(height: 10),
                _buildTextField("Last Name"),
                const SizedBox(height: 10),
                _buildTextField("Email", icon: Icons.email),
                const SizedBox(height: 10),
                _buildTextField(
                    "Password", icon: Icons.vpn_key, isPassword: true),
                const SizedBox(height: 10),
                _buildTextField(
                    "Confirm Password", icon: Icons.vpn_key, isPassword: true),
                const SizedBox(height: 10),
                _buildTextField("Birth Date", icon: Icons.calendar_today),
                const SizedBox(height: 20),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
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
                      // Navigate to QRPage with the user type
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRPage(isMember: isMember),
                        ),
                      );
                    },
                    child: Text("Sign Up",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint,
      {IconData? icon, bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: accentColor) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );
  }
}