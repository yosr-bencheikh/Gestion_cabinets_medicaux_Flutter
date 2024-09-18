import 'package:doctor_appointment/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Image.asset(
                'images/doctor.jpg',
                // Replace with your image path
                // Set the desired height
              ),
            ),

            SizedBox(height: 20.0),

            Text(
              'HealthHub app',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: prColor,
                letterSpacing: 1,
                wordSpacing: 4,
              ),
            ),

            Text(
              'The best doctor for your best healthcare',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),

            SizedBox(height: 20.0),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
              style: ElevatedButton.styleFrom(
                primary: prColor, // Background color
                onPrimary: Colors.white, // Text color
                padding: EdgeInsets.symmetric(horizontal: 45, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Login'),
            ),

            SizedBox(height: 10.0),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                primary:prColor, // Background color
                onPrimary: Colors.white, // Text color
                side: BorderSide(color: prColor), // Border color
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
