import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midterm_project/Custom/ToDoCard.dart';
import 'package:flutter_midterm_project/Service/Auth_Service.dart';
import 'package:flutter_midterm_project/Service/Notification_helper.dart';
import 'package:flutter_midterm_project/pages/AddToDo.dart';
import 'package:flutter_midterm_project/pages/Profile.dart';
import 'package:flutter_midterm_project/pages/SignUp.dart';
import 'package:flutter_midterm_project/pages/view_data.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:timezone/timezone.dart" as tz;
import "package:timezone/data/latest_all.dart" as tz;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthService authService = AuthService();
  Stream<QuerySnapshot> ?_stream;
  //     FirebaseFirestore.instance.collection("Todo").where("uid", isEqualTo: userID).snapshots();
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
      // Initialize the stream with the current user's UID
      _stream = FirebaseFirestore.instance
          .collection("Todo")
          .where("uid", isEqualTo: userID)
          .snapshots();
    } else {
      // Handle case where user is not logged in
      _stream = Stream.empty();  // Empty stream if userID is null
  }
  }

  Future<void> _loadSavedImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedImagePath = prefs.getString('profile_image');
    });
  }

 
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
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
                : AssetImage("assets/OIP.jpeg") as ImageProvider,
          ),
          SizedBox(
            width: 25,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(35),
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
                    style: TextStyle(
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
          BottomNavigationBarItem(
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
                // Điều hướng sang AddToDo và nhận DateTime trả về
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => AddToDo()),
                ).then((_) {
                  // Refresh data when coming back from AddToDo
                  setState(() {
                    currentDate = DateTime.now();
                  });
                }); // Cập nhật giao diện sau khi nhận DateTime
              },
              child: Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    Colors.indigoAccent,
                    Colors.purple,
                  ]),
                ),
                child: Icon(
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
                // Navigate to the Profile page and wait for the result (image path)
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );

                // If a result (new image path) is returned, update the image
                if (result != null && result is String) {
                  setState(() {
                    savedImagePath = result;
                  });
                }
              },
              child: Icon(
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
            return Center(child: CircularProgressIndicator());
          }
          List<DocumentSnapshot<Object?>> documents =
              snapshot.data!.docs.cast<DocumentSnapshot<Object?>>();

          // Loại bỏ các tài liệu đã bị xóa
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

              // Chuyển đổi dữ liệu "Category" thành icon
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
              String formattedTime =
                  deadline != null ? DateFormat('HH:mm').format(deadline) : '';
              
                NotificationHelper.scheduledNotification(
                  "Deadline Reminder",
                  'Your task "${document["title"]}" is due!',
                  deadline!, 
                );
              
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => ViewData(
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
