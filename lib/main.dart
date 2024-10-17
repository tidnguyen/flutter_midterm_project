import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_midterm_project/Service/Auth_Service.dart';
import 'package:flutter_midterm_project/pages/AddToDo.dart';
import 'package:flutter_midterm_project/pages/Home.dart';
import 'package:flutter_midterm_project/pages/SignUp.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb)
  {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBV1UZTTiEB_G43cb2OmX3zLmV-QqZuo3I",
          authDomain: "mid-tern.firebaseapp.com",
          projectId: "mid-tern",
          storageBucket: "mid-tern.appspot.com",
          messagingSenderId: "686598240384",
          appId: "1:686598240384:web:a24989e3953971ccfd4e65",
          measurementId: "G-QHCNEQ52JP"
      )
    );
  }
  else
  {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  Widget currentPage = SignUp();
  AuthService authService = AuthService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  void checkLogin() async
  {
    String token = await authService.getToken();
    if(token != null)
    {
      setState(() {
        currentPage = Home();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: false),
      debugShowCheckedModeBanner: false,
      home: SignUp(),
    );
  }
}