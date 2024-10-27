import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midterm_project/pages/signUpPage.dart';
import 'package:flutter_midterm_project/Service/notificationSerivce.dart'; 
import "package:timezone/data/latest_all.dart" as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  NotificationService.init();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBV1UZTTiEB_G43cb2OmX3zLmV-QqZuo3I",
        authDomain: "mid-tern.firebaseapp.com",
        projectId: "mid-tern",
        storageBucket: "mid-tern.appspot.com",
        messagingSenderId: "686598240384",
        appId: "1:686598240384:web:a24989e3953971ccfd4e65",
        measurementId: "G-QHCNEQ52JP",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: false),
      debugShowCheckedModeBanner: false,
      home:const SignUpPage(),
    );
  }
}
