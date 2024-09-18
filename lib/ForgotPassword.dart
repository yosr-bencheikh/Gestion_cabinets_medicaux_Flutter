import 'package:doctor_appointment/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'change_password_page.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Set up listener for password recovery event
    client.auth.onAuthStateChange.listen((event) async {
      if (event == AuthChangeEvent.passwordRecovery) {
        // Redirect user to password recovery page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PasswordChangePage()),
        );
      }
    });
  }

  Future<void> passwordReset() async {
    try {
      await client.auth.resetPasswordForEmail(
          _emailController.text.trim(),// Replace with your change password page URL
      );
      // Same URL as redirectTo
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Enter your email to receive password reset link '),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Email',
                fillColor: Colors.grey.shade200,
                filled: true,
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: passwordReset,
            style: ElevatedButton.styleFrom(
              primary: prColor, // Background color
              onPrimary: Colors.white, // Text color
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text('Send Link'),
          ),
        ],
      ),
    );
  }
}
