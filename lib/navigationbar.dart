

import 'package:flutter/material.dart';
import 'history.dart';
import 'Appointments.dart';
import 'Notifications.dart';
import 'Settings.dart';
import 'interfaceClient.dart';

// Import other necessary files (Appointments.dart, Notifications.dart, Settings.dart, constants.dart, interfaceClient.dart, DoctorHome.dart)

void main() => runApp(const NavigationBarApp());

const Color prColor = Colors.blue; // Assuming prColor is defined in your 'constants.dart' file

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({Key? key}) : super(key: key);

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
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
        destinations: clientDestinations,
      ),
      body: <Widget>[
        InterfaceClient(),
        Appointment(),
        History(),
        Settings(),
      ][pageIndex],
    );
  }
}



const List<NavigationDestination> clientDestinations = <NavigationDestination>[
  NavigationDestination(
    selectedIcon: Icon(Icons.home),
    icon: Icon(Icons.home),
    label: 'Home',
  ),
  NavigationDestination(
    selectedIcon: Icon(Icons.access_alarm),
    icon: Icon(Icons.access_alarm),
    label: 'Appointments',
  ),
  NavigationDestination(
    selectedIcon: Icon(Icons.history),
    icon: Icon(Icons.history_rounded),
    label: 'History',
  ),

  NavigationDestination(
    icon: Badge(
      child: Icon(Icons.settings),
    ),
    label: 'Settings',
  ),
];