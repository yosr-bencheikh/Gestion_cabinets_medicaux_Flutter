import 'package:flutter/material.dart';
import 'package:doctor_appointment/constants.dart';
import 'package:doctor_appointment/patientsPage.dart';
import 'package:doctor_appointment/specialtyPage.dart';

import 'AppointmentsPage.dart';
import 'doctorsPage.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
                color: prColor,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50)
                )
            ),
            child: FutureBuilder<String?>(
              future: fetchUserData('avatar_url', 'profiles'),
              builder: (context, AsyncSnapshot<String?> imageUrlSnapshot) {
                if (imageUrlSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (imageUrlSnapshot.hasError || imageUrlSnapshot.data == null) {
                  // Handle the error condition when fetching image URL
                  return Text('Error fetching image URL');
                } else {
                  return FutureBuilder<String?>(
                    future: fetchUserData('username', 'profiles'),
                    builder: (context, AsyncSnapshot<String?> usernameSnapshot) {
                      if (usernameSnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (usernameSnapshot.hasError || usernameSnapshot.data == null) {
                        // Handle the error condition when fetching username
                        return Text('Error fetching username');
                      } else {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          child: Column(
                            children: <Widget>[
                              smallBox,
                              smallBox,
                              ListTile(
                                leading: Icon(Icons.waving_hand),
                                title: Text("Hello"),
                                subtitle: Text(
                                  usernameSnapshot.data!,
                                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                ),
                                trailing: Container(
                                  width: 60,
                                  height: 60,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(80),
                                    child: Image.network(
                                      imageUrlSnapshot.data!,
                                      fit: BoxFit.cover,
                                      width: 80,height: 80,
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
          SizedBox(width: 20,),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 30,),
              decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100)
              )),
              child: GridView.count(shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 50,
                children: [
                  itemDashboard('Patients', Icons.personal_injury_rounded, Colors.orange,
                          () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => const PatientsPage()));
                      }),
                  itemDashboard('Doctors', Icons.medical_services, Colors.pink, () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => DoctorsPage()));
                  }),
                  itemDashboard('Appointments', Icons.calendar_month, Colors.green, () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => AppointmentsPage()));
                  }),
                  itemDashboard('Specialties', Icons.medical_information, Colors.brown, () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => AdminInterface()));
                  }),

                ],)
          )
        ],
      ),

    );
  }

  Widget itemDashboard(String title, IconData iconData, Color background, VoidCallback onTap) => Container(
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 5),
            color: Colors.grey,
            spreadRadius: 0.5,
            blurRadius: 5,
          )
        ]),
    child: InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey),
          )
        ],
      ),
    ),
  );

  Future<String?> fetchUserData(String col, String table) async {
    try {
      final userData = await client
          .from(table)
          .select(col)
          .eq('id', client.auth.currentUser!.id)
          .single();

      return userData[col] as String?;
    } catch (error) {
      return null;
    }
  }
}
