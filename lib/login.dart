import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:meqattest/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures everything is set before starting
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(), // Start with LaunchScreen
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.black, // Black theme
          background: Colors.white, // White background
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _focusNodeUsername = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final LocalAuthentication auth = LocalAuthentication();
  bool _isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNodeUsername.addListener(_handleKeyboardVisibility);
    _focusNodePassword.addListener(_handleKeyboardVisibility);
  }

  void _handleKeyboardVisibility() {
    setState(() {
      _isKeyboardOpen = _focusNodeUsername.hasFocus || _focusNodePassword.hasFocus;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = await auth.authenticate(
      localizedReason: 'Use Face or Fingerprint to Log in',
      options: const AuthenticationOptions(
        biometricOnly: true,
        useErrorDialogs: true,
        stickyAuth: true,
      ),
    );

    if (authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authenticated successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Spacer(flex: 2), // Pushes everything down (fix top issue)

          // Logo (Properly Centered)
          Center(
            child: Image.asset(
              'assets/logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 32), // More space under logo

          // Form Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                _buildTextField(
                  controller: _usernameController,
                  focusNode: _focusNodeUsername,
                  hintText: "Username, email or mobile number",
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  focusNode: _focusNodePassword,
                  hintText: "Password",
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                // Login Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to QRPage with the user type
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "Log in",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Face/Fingerprint Authentication Button
                TextButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint, size: 24, color: Colors.black),
                  label: const Text(
                    "Use Face or Fingerprint",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 16),

                // Forgot Password?
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!_isKeyboardOpen) const Spacer(flex: 1), // Adds space when keyboard is closed

          // "Create New Account" at the Bottom
          if (!_isKeyboardOpen)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: TextStyle(color: Colors.black87)),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Create new account",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),

          // "Meta" Branding (Stays at Bottom)
          if (!_isKeyboardOpen)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "MeQat",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper Method to Build Text Fields
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }
}
