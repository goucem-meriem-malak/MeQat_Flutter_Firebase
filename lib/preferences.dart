import 'package:flutter/material.dart';
import 'package:meqattest/home.dart';
import 'package:meqattest/login.dart';
import 'package:meqattest/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Color buttonColor = Color(0xFFE5C99F);
final Color textColor = Color(0xC52E2E2E);

class PreferencesPage extends StatefulWidget {
  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {

  String? selectedLanguage = "English";
  String? selectedGoal = "Umrah";
  String? selectedMadhhab;
  String? selectedCountry;
  String? selectedTransportation;
  bool isWithDelegation = false;

  final List<String> languages = ["English", "Arabic"];
  final List<String> goal = ["Hajj", "Umrah"];
  final List<String> madhhabs = ["Shafii", "Hanafi", "Hanbali", "Maliki"];
  final List<String> countries = ["Saudi Arabia", "Egypt", "Pakistan", "Malaysia", "Turkey"];
  final List<String> transportationMethods = ["By Air", "By Sea", "By Vehicle", "By foot"];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('language') ?? "English";
      selectedGoal = goal.contains(prefs.getString('goal')) ? prefs.getString('goal') : goal[0];
      selectedMadhhab = madhhabs.contains(prefs.getString('madhhab')) ? prefs.getString('madhhab') : null;
      selectedCountry = countries.contains(prefs.getString('country')) ? prefs.getString('country') : null;
      selectedTransportation = transportationMethods.contains(prefs.getString('transportation')) ? prefs.getString('transportation') : null;
      isWithDelegation = prefs.getBool('delegation') ?? false;
    });
  }

  _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('language', selectedLanguage ?? "English");
    prefs.setString('goal', selectedGoal ?? "");
    prefs.setString('madhhab', selectedMadhhab ?? "");
    prefs.setString('country', selectedCountry ?? "");
    prefs.setString('transportation', selectedTransportation ?? "");
    prefs.setBool('delegation', isWithDelegation);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          children: [
            SizedBox(height: 40), // For spacing
            Center(
              child: Image.asset("assets/logo.png", width: 100), // Your logo
            ),
            SizedBox(height: 30),

            // Hajj/Umrah Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Hajj", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                Switch(
                  value: selectedGoal == "Umrah",
                  activeColor: textColor,
                  onChanged: (bool value) {
                    setState(() {
                      selectedGoal = value ? "Umrah" : "Hajj";
                    });
                  },
                ),
                Text("Umrah", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
            SizedBox(height: 20),

            // Dropdowns
            _buildDropdown("Choose Madhhab", Icons.school),
            SizedBox(height: 20),
            _buildDropdown("Choose Country", Icons.location_on),
            SizedBox(height: 20),
            _buildDropdown("Choose Transportation", Icons.directions),

            SizedBox(height: 20),

            // Delegation Checkbox
            Row(
              children: [
                Checkbox(
                  value: isWithDelegation,
                  onChanged: (value) {
                    setState(() {
                      isWithDelegation = value!;
                    });
                  },
                  activeColor: buttonColor,
                ),
                Text("Traveling with a Delegation", style: TextStyle(fontSize: 16, color: textColor)),
              ],
            ),

            Spacer(),

            // Guest Button (Clickable Text)
            Align(
              alignment: Alignment.centerRight, // Moves text to the right
              child: GestureDetector(
                onTap: () {}, // Add navigation logic for login
                child: Text(
                  "Log In",
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 10),


            // Continue Button
            _buildStartButton(),

            SizedBox(height: 40),

            Text("MeQat", style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: buttonColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        dropdownColor: Colors.white,
        hint: Text(hint, style: TextStyle(color: Colors.grey)),
        items: [],
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor, // Black button as requested
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(vertical: 14),
          minimumSize: Size(double.infinity, 50), // Full-width button
        ),
        onPressed: _savePreferences,
        child: Text("Start", style: TextStyle(color: textColor, fontSize: 18)),
      ),
    );
  }
}