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
          apiKey: "AIzaSyCshEiCNgnxVom9aogZY0KaSSJSJTVZIPw",
          authDomain: "flutter-midtern.firebaseapp.com",
          projectId: "flutter-midtern",
          storageBucket: "flutter-midtern.appspot.com",
          messagingSenderId: "821785601438",
          appId: "1:821785601438:web:15770d6e505c8e0968628f",
          measurementId: "G-LX26HHQ4VN"
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
      home: AddToDo(),
    );
  }
}