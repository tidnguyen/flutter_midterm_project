import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midterm_project/Custom/ToDoCard.dart';
import 'package:flutter_midterm_project/Service/Auth_Service.dart';
import 'package:flutter_midterm_project/pages/AddToDo.dart';
import 'package:flutter_midterm_project/pages/SignUp.dart';
import 'package:flutter_midterm_project/pages/view_data.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthService authService = AuthService();
  final Stream<QuerySnapshot> _stream =
      FirebaseFirestore.instance.collection("Todo").snapshots();
  List<Select> selected = [];
  
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
            backgroundImage: AssetImage("assets/OIP.jpeg"),
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
                    "Monday 21",
                    style: TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
  onPressed: () async {
    var instance = FirebaseFirestore.instance.collection("Todo");
    for (var i = 0; i < selected.length; i++) {
      if (selected[i].checkValue) {
        await instance.doc(selected[i].id).delete().then((_) {
        }).catchError((error) {
        });
      }
    }

    setState(() {
      selected.removeWhere((element) => element.checkValue == true);
    });
  },
  icon: Icon(
    Icons.delete,
    color: Colors.red,
    size: 28,
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => AddToDo()));
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
            icon: Icon(
              Icons.settings,
              size: 32,
              color: Colors.white,
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
          List<DocumentSnapshot> documents = snapshot.data?.docs ?? [];

          // Filter out any documents that were deleted
          documents.removeWhere((doc) =>
              selected.any((sel) => sel.id == doc.id && sel.checkValue));
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              IconData iconData;
              Color iconColor;
              Map<String, dynamic> document =
                  snapshot.data?.docs[index].data() as Map<String, dynamic>;
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
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => ViewData(
                        document: document,
                        id: snapshot.data?.docs[index].id,
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
                  time: "10 AM",
                  index: index,
                  onChange: (bool? value, int? index) {
                    setState(() {
                      selected[index!].checkValue = value!;
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // void onChange(int index) {
  //   setState(() {
  //     selected[index].checkValue = !selected[index].checkValue;
  //   });
  // }
}

class Select {
  String? id;
  bool checkValue;
  Select({this.id, this.checkValue = false});
}
