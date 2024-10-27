import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midterm_project/Custom/toDoCard.dart';
import 'package:flutter_midterm_project/Service/auth_service.dart';
import 'package:flutter_midterm_project/Service/notification_serivce.dart';
import 'package:flutter_midterm_project/pages/addtodo_page.dart';
import 'package:flutter_midterm_project/pages/profile_page.dart';
import 'package:flutter_midterm_project/pages/viewdata_page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  Stream<QuerySnapshot> ?_stream;
  List<Select> selected = [];
  DateTime? selectedDateTime;
  DateTime currentDate = DateTime.now();
  String? savedImagePath;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
    String? userID = FirebaseAuth.instance.currentUser?.uid;
    if (userID != null) {
      _stream = FirebaseFirestore.instance
        .collection("Todo")
        .where("uid", isEqualTo: userID)
        .snapshots();
    } else {
      _stream = const Stream.empty(); 
  }
  }

  Future<void> _loadSavedImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedImagePath = prefs.getString('profile_image');
    },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          "Today's Schedule",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          CircleAvatar(
            backgroundImage: savedImagePath != null
                ? FileImage(File(savedImagePath!))
                : const AssetImage("assets/OIP.jpeg") as ImageProvider,
          ),
          const SizedBox(
            width: 25,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(35),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat(
                      'EEEE dd',
                    ).format(currentDate),
                    style: const TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black87,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 32,
              color: Colors.white,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => const AddToDoPage()),
                ).then((_) {
                  setState(() {
                    currentDate = DateTime.now();
                  });
                },
                );
              },
              child: Container(
                height: 52,
                width: 52,
                decoration: const  BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    Colors.indigoAccent,
                    Colors.purple,
                  ]),
                ),
                child: const Icon(
                  Icons.add,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
                if (result != null && result is String) {
                  setState(() {
                    savedImagePath = result;
                  });
                }
              },
              child: const Icon(
                Icons.settings,
                size: 32,
                color: Colors.white,
              ),
            ),
            label: "",
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          List<DocumentSnapshot<Object?>> documents =
              snapshot.data!.docs.cast<DocumentSnapshot<Object?>>();
          documents.removeWhere((doc) =>
              selected.any((sel) => sel.id == doc.id && sel.checkValue));
          for (var doc in documents) {
            if (!selected.any((sel) => sel.id == doc.id)) {
              selected.add(Select(id: doc.id, checkValue: false));
            }
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              IconData iconData;
              Color iconColor;
              Map<String, dynamic> document =
                  documents[index].data() as Map<String, dynamic>;

              switch (document["Category"]) {
                case "Food":
                  iconData = Icons.food_bank;
                  iconColor = Colors.red;
                  break;
                case "Work":
                  iconData = Icons.home_work;
                  iconColor = Colors.green;
                  break;
                case "WorkOut":
                  iconData = Icons.sports_gymnastics;
                  iconColor = Colors.blue;
                  break;
                case "Run":
                  iconData = Icons.run_circle;
                  iconColor = Colors.black;
                  break;
                default:
                  iconData = Icons.run_circle_outlined;
                  iconColor = Colors.red;
              }

              if (selected.length <= index ||
                  selected[index].id != snapshot.data?.docs[index].id) {
                selected.add(
                  Select(id: snapshot.data?.docs[index].id, checkValue: false),
                );
              }
              DateTime? deadline = document["deadline"] != null
                  ? DateTime.fromMicrosecondsSinceEpoch(document["deadline"])
                  : null;
              String formattedTime = deadline != null ? DateFormat('HH:mm').format(deadline) : '';
                NotificationService.scheduledNotification(
                  "Deadline Reminder",
                  'Your task "${document["title"]}" is due!',
                  deadline!, 
                );
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => ViewDataPage(
                        document: document,
                        id: documents[index].id,
                      ),
                    ),
                  );
                },
                child: Todocard(
                  title: document["title"] ?? "Hey There",
                  check: selected[index].checkValue,
                  iconBgColor: Colors.white,
                  iconColor: iconColor,
                  iconData: iconData,
                  time: formattedTime,
                  index: index,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Select {
  String? id;
  bool checkValue;
  Select({this.id, this.checkValue = false});
}
