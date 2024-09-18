import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

import 'constants.dart';

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({Key? key}) : super(key: key);

  @override
  _PasswordChangePageState createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> changePassword() async {
    final String? newPassword = _passwordController.text;

    if (_formKey.currentState!.validate()) {
      // Update the user's password using Supabase
      final user = client.auth.currentUser;

      if (user != null) {
        final response = await client.auth.updateUser({'password': newPassword} as UserAttributes);

        if (response != null) {
          // Password updated successfully
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ));
        } else {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error changing password: '),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: changePassword,
                style: ElevatedButton.styleFrom(
                  primary: prColor, // Background color
                  onPrimary: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
