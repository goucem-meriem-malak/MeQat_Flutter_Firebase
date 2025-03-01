import 'package:flutter/material.dart';
import 'package:meqattest/login.dart';
import 'package:meqattest/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? language;
  String? madhhab;
  String? country;
  String? transportation;
  bool? isWithDelegation;
  bool? isHajjOrUmrah;
  String? firstName;
  String? lastName;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load the saved preferences from SharedPreferences
  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      language = prefs.getString('language');
      madhhab = prefs.getString('madhhab');
      country = prefs.getString('country');
      transportation = prefs.getString('transportation');
      isWithDelegation = prefs.getBool('isMember');
      isHajjOrUmrah = prefs.getBool('isHajjOrUmrah');
      firstName = prefs.getString('firstName');
      lastName = prefs.getString('lastName');
      imageUrl = prefs.getString('face');
    });
  }

  // Save the preferences to SharedPreferences
  _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('language', language ?? '');
    prefs.setString('madhhab', madhhab ?? '');
    prefs.setString('country', country ?? '');
    prefs.setString('transportation', transportation ?? '');
    prefs.setBool('isMember', isWithDelegation ?? false);
    prefs.setBool('isHajjOrUmrah', isHajjOrUmrah ?? false);
    prefs.setString('firstName', firstName ?? '');
    prefs.setString('lastName', lastName ?? '');
    prefs.setString('face', imageUrl ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Handle logout
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Clear user data
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              ); // Navigate to login page
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Picture and Name
              CircleAvatar(
                radius: 50,
                backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                    ? NetworkImage(imageUrl!)
                    : AssetImage('assets/default_profile.png') as ImageProvider,
              ),
              SizedBox(height: 8),
              Text(
                '${firstName ?? ''} ${lastName ?? ''}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Settings Cart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // You can implement your edit functionality here
                      setState(() {
                        // Enable editing by showing text fields for inputs
                      });
                    },
                  ),
                ],
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSettingRow('Language', language),
                      _buildSettingRow('Madhhab', madhhab),
                      _buildSettingRow('Country', country),
                      _buildSettingRow('Transportation', transportation),
                      _buildSettingRow('With Delegation', isWithDelegation != null ? isWithDelegation.toString() : ''),
                      _buildSettingRow('Hajj/Umrah', isHajjOrUmrah != null ? isHajjOrUmrah.toString() : ''),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
                color: Colors.orange,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _savePreferences();
          // You can navigate to another screen or show a success message
        },
        child: Icon(Icons.save),
      ),
    );
  }

  // Helper method to build setting rows
  Widget _buildSettingRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        Text(value ?? 'Not Set', style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}
