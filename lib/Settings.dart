import 'package:doctor_appointment/personaldata.dart';
import 'package:doctor_appointment/signIn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 20,),
          Card(
            color: prColor,

            child: ListTile(

              leading: Icon(Icons.help_outline),
              title: Text("Settings",style: TextStyle(fontSize: 25),),

            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.person, color: prColor),
              title: Text('Personal data'),
              subtitle: Text('Check or modify your data'),
              onTap: () {
                // Navigate to PersonalDataPage when the card is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PersonalDataPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: prColor),
              title: Text('Logout'),
              subtitle: Text('Disconnect'),
              onTap: () async {
                await client.auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()), // Replace with your login screen
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.language,color: prColor,),
              title: Text('Language'),
              subtitle: Text('choose the language of the app '),
            ),
          ),
        ],
      ),
    );
  }
}


