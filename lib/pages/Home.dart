
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midterm_project/Custom/ToDoCard.dart';
import 'package:flutter_midterm_project/Service/Auth_Service.dart';
import 'package:flutter_midterm_project/pages/AddToDo.dart';
import 'package:flutter_midterm_project/pages/SignUp.dart';
import 'package:flutter_midterm_project/pages/view_data.dart';
import 'package:intl/intl.dart';

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
  DateTime? selectedDateTime;
  DateTime currentDate =
      DateTime.now(); // Thêm biến để lưu giá trị DateTime trả về từ AddToDo

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
                    DateFormat('EEEE dd', ).format(currentDate),
                   
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
    currentDate = DateTime.now(); // Update current date after returning
  });

                });// Cập nhật giao diện sau khi nhận DateTime
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
          List<DocumentSnapshot<Object?>> documents = snapshot.data!.docs.cast<DocumentSnapshot<Object?>>();


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

              // Thêm mục vào danh sách lựa chọn nếu chưa có
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