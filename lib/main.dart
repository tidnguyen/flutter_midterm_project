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
          apiKey: "AIzaSyBDWES4OBArWtF03KShqfVt2G2abpAiRc4",
          authDomain: "flutter-midtern-75f13.firebaseapp.com",
          projectId: "flutter-midtern-75f13",
          storageBucket: "flutter-midtern-75f13.appspot.com",
          messagingSenderId: "31210369349",
          appId: "1:31210369349:web:d6b599305ddfad80f74e2c",
          measurementId: "G-53XQCHKJ5V"
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
      home: currentPage,
    );
  }
}