import 'package:doctor_appointment/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      // Replace SuccessPage with NavigationBarApp
      Navigator.pushReplacementNamed(context, '/interfaceclient');
    });
    return Scaffold(
       backgroundColor: Colors.white,
      body: SafeArea(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/tick.gif'),
            smallBox,
            Text('Request sent successfully',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
          ],
        ),

      ),

        );


  }
}
