import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();
  XFile? image;
  String? savedImagePath;
  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedImagePath = prefs.getString('profile_image');
    });
  }

  Future<void> _saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: getImage(),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  button(),
                  IconButton(
                      onPressed: () async {
                        image = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (image != null) {
                          await _saveImagePath(image!.path);
                          setState(() {
                            _saveImagePath(image!.path);
                          });
                          ;
                        }
                      },
                      icon: Icon(
                        Icons.add_a_photo,
                        color: Colors.teal,
                        size: 30,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider getImage() {
    if (image != null) {
      return FileImage(File(image!.path));
    } else if (savedImagePath != null) {
      return FileImage(File(savedImagePath!));
    }
    return AssetImage("assets/OIP.jpeg");
  }

  Widget button() {
    return InkWell(
      onTap: () async {
        if (image != null) {
          await _saveImagePath(image!.path);
        }
        Navigator.pop(context, image!.path);
      },
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Color(0xff8a32f1),
              Color(0xffad32f9),
            ],
          ),
        ),
        child: Center(
          child: Text(
            "Up Load",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
