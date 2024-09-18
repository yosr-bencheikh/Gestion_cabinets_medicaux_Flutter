
import 'package:doctor_appointment/DoctorHome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Notifications.dart';
import 'Settings.dart';
import 'constants.dart';

class DoctorNavigationBarApp extends StatelessWidget {
  const DoctorNavigationBarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const DoctorNavigationExample(),
    );
  }
}

class DoctorNavigationExample extends StatefulWidget {
  const DoctorNavigationExample({Key? key}) : super(key: key);

  @override
  State<DoctorNavigationExample> createState() => _DoctorNavigationExampleState();
}

class _DoctorNavigationExampleState extends State<DoctorNavigationExample> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            pageIndex = index;
          });
        },
        indicatorColor: prColor,
        selectedIndex: pageIndex,
        destinations: doctorDestinations,
      ),
      body: <Widget>[
        DoctorHome(),
        Notifications(),
        Settings(),
      ][pageIndex],
    );
  }
}


const List<NavigationDestination> doctorDestinations = <NavigationDestination>[
  NavigationDestination(
    selectedIcon: Icon(Icons.home),
    icon: Icon(Icons.home),
    label: 'Home',
  ),

  NavigationDestination(
    selectedIcon: Icon(Icons.calendar_month),
    icon: Icon(Icons.calendar_month),
    label: 'Schedule',
  ),
  NavigationDestination(
    icon: Badge(
      child: Icon(Icons.settings),
    ),
    label: 'Settings',
  ),
];