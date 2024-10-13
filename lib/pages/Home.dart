import 'package:flutter/material.dart';
import 'package:flutter_midterm_project/Service/Auth_Service.dart';
import 'package:flutter_midterm_project/pages/SignUp.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
          onPressed: () async {
            await authService.logout();
             Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (builder) => SignUp()),
              (route) => false
              );
          }, 
            icon: Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}