import 'package:doctor_appointment/bookingPage.dart';
import 'package:doctor_appointment/signIn.dart';
import 'package:doctor_appointment/signUp.dart';
import 'package:doctor_appointment/successPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hcaptcha/hcaptcha.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'adminPanel.dart';
import 'change_password_page.dart';
import 'firebase_api.dart';
import 'firebase_options.dart';

import 'package:url_launcher/url_launcher.dart';
import 'Notifications.dart';
import 'Settings.dart';
import 'constants.dart';
import 'home_page.dart';
import 'interfaceClient.dart';
import 'interfaceDoctor.dart';
import 'navigationbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
      url: "https://ncezitmfdhqhkxqfjonv.supabase.co",
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jZXppdG1mZGhxaGt4cWZqb252Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDU1MDMwNTAsImV4cCI6MjAyMTA3OTA1MH0.hJVmYSINCkgHNfmVdmmijghP9soD0WOGOajEBip4yL0'
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
 void initState() {
    super.initState();
    client.auth.onAuthStateChange.listen((event) async {
      try {
        if (event.event == AuthChangeEvent.signedIn) {
          print("User signed in");
          await FirebaseMessaging.instance.requestPermission();
          await FirebaseMessaging.instance.getAPNSToken();
          final fmcToken = await FirebaseMessaging.instance.getToken();
          print("FCM Token: $fmcToken");
          if (fmcToken != null) {
            print("Setting FCM Token...");
            await _setFcmToken(fmcToken);
          }
        }
      } catch (e) {
        print("Error handling auth state change: $e");
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      try {
        print("Token Refreshed: $fcmToken");
        await _setFcmToken(fcmToken);
      } catch (e) {
        print("Error handling token refresh: $e");
      }
    });
    HCaptcha.init(siteKey: '7dcc9377-6468-4671-9b6c-756be0a42802');
  }

  Future<void> _setFcmToken(String fcmToken) async {
    try {
      final userId = client.auth.currentUser!.id;
      if (userId != null) {
        await client.from('notifications').upsert({
          'user_id': userId,
          'fmc_token': fcmToken,
        });
        print("FCM Token set for user $userId");
      }
    } catch (e) {
      print("Error setting FCM token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/interfaceclient': (context) => const NavigationExample(),
        '/notifications': (context) => const Notifications(),
        '/settings': (context) => const Settings(),
        '/bookingPage': (context) => BookingPage(doctorId: ModalRoute.of(context)!.settings.arguments as String),
        '/successPage': (context) => const SuccessPage(),
        '/interfacedoctor': (context) => const DoctorNavigationBarApp(),
        '/adminpanel':(context)=>const AdminPanel(),
        'https://changepassword':(context)=>PasswordChangePage(),
      },

    );
  }
}




