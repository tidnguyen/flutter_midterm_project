import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_midterm_project/Service/Notification_helper.dart';
import 'package:flutter_midterm_project/pages/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AddToDo extends StatefulWidget {
  const AddToDo({super.key});

  @override
  State<AddToDo> createState() => _AddToDoState();
}

class _AddToDoState extends State<AddToDo> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String type = "";
  String category = "";
  DateTime? selectedDateTime;
  List<File> _selectedFiles = [];
  List<Reference> _uploadedFiles = [];
  final ImagePicker _picker = ImagePicker();
  final Utils utils = Utils();
  String taskID = FirebaseFirestore.instance.collection("Todo").doc().id;

  void initState() {
    super.initState();
    getUploadedFiles();
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff1d1e26),
              Color(0xff252041),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  CupertinoIcons.arrow_left,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create",
                      style: TextStyle(
                          fontSize: 33,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "New Todo",
                      style: TextStyle(
                        fontSize: 33,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    label("Task Title"),
                    SizedBox(
                      height: 12,
                    ),
                    title(),
                    SizedBox(
                      height: 30,
                    ),
                    label("Task Type"),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        taskSelect("Important", 0xff2664fa),
                        SizedBox(
                          width: 20,
                        ),
                        taskSelect("Planned", 0xff2bc8d9),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    label("Descripiton"),
                    SizedBox(
                      height: 12,
                    ),
                    description(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          child: Text("Choose Image"),
                          onPressed: () async {
                            final XFile? selectedImage = await _picker
                                .pickImage(source: ImageSource.gallery);
                            if (selectedImage != null) {
                              File imageFile = File(selectedImage.path);
                              bool success = await utils.uploadFileForUser(
                                  imageFile, taskID);
                              if (success) {
                                getTaskImages(taskID);
                              }
                            }
                          },
                        ),
                        ElevatedButton(
                          child: Text("Choose Files"),
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              allowMultiple: true,
                              type: FileType.any,
                            );
                            if (result != null) {
                              setState(() {
                                _selectedFiles.addAll(result.paths.map((path) => File(path!)).toList(),);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 12,),
                    label("Category"),
                    SizedBox(
                      height: 12,
                    ),
                    Wrap(
                      runSpacing: 10,
                      children: [
                        categorySelect("Food", 0xffff6d6e),
                        SizedBox(
                          width: 20,
                        ),
                        categorySelect("WorkOut", 0xfff29732),
                        SizedBox(
                          width: 20,
                        ),
                        categorySelect("Work", 0xff6557ff),
                        SizedBox(
                          width: 20,
                        ),
                        categorySelect("Design", 0xff234ebd),
                        SizedBox(
                          width: 20,
                        ),
                        categorySelect("Run", 0xff2bc8d9),
                      ],
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    InkWell(
                      onTap: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true, onChanged: (date) {
                          print('change $date');
                        }, onConfirm: (date) {
                          setState(() {
                            selectedDateTime = date;
                          });
                        }, currentTime: DateTime.now(), locale: LocaleType.vi);
                      },
                      child: Chip(
                        label: Text(
                          selectedDateTime != null
                              ? DateFormat('HH:mm').format(selectedDateTime!)
                              : 'Pick Deadline',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    button(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final String? userID = FirebaseAuth.instance.currentUser?.uid;

  Widget button() {
    return InkWell(
      onTap: () async {
        if(userID != null){
        List<String> imageUrls = await Future.wait(_uploadedFiles.map((ref) => ref.getDownloadURL()),);
        List<String> fileUrls = [];
        for (var file in _selectedFiles) {
          String fileName = file.path.split('/').last;
          Reference ref = FirebaseStorage.instance.ref().child("uploads/$taskID/files/$fileName");

          await ref.putFile(file);

          String fileUrl = await ref.getDownloadURL();
          fileUrls.add(fileUrl);
        }

        await FirebaseFirestore.instance.collection("Todo").add({
          "uid": userID,
          "title": _titleController.text,
          "task": type,
          "Category": category,
          "description": _descriptionController.text,
          "deadline": selectedDateTime?.microsecondsSinceEpoch,
          "taskID": taskID,
          "images": imageUrls,
          "files": fileUrls,
        });

        Navigator.pop(context);
      } else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not signed in.")));
      }
  },
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
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
            "Add Todo",
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

  Widget description() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 150,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Color(0xff2a2e3d),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextFormField(
            controller: _descriptionController,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
            maxLines: null,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Task title",
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 17,
              ),
              contentPadding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
            ),
          ),
        ),

        SizedBox(height: 10),

        if (_uploadedFiles.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selected Images:",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _uploadedFiles.length,
                itemBuilder: (context, index) {
                  Reference ref = _uploadedFiles[index];
                  return FutureBuilder(
                    future: ref.getDownloadURL(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () async {
                                  await ref.delete();
                                  setState(() {
                                    _uploadedFiles.removeAt(index);
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.redAccent,
                                  child: Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return Container();
                    },
                  );
                },
              ),
            ],
          ),
        SizedBox(height: 10),

        if (_selectedFiles.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selected Files:",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _selectedFiles.asMap().entries.map((entry) {
                  int index = entry.key;
                  File file = entry.value;
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          file.path.split('/').last,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Positioned(
                        right: -10,
                        top: -10,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedFiles.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
      ],
    );
  }

  void getTaskImages(String taskID) async {
    List<Reference>? result = await utils.getTaskImages(taskID);
    if (result != null) {
      setState(() {
        _uploadedFiles = result;
      });
    }
  }

  void getUploadedFiles() async {
    List<Reference>? result = await utils.getUsersUploadedFiles();
    if (result != null) {
      setState(() {
        _uploadedFiles = result;
      });
    }
  }

  Widget taskSelect(String label, int color) {
    return InkWell(
      onTap: () {
        setState(() {
          type = label;
        });
      },
      child: Chip(
        backgroundColor: type == label ? Colors.white : Color(color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: type == label ? Colors.black : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        labelPadding: EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 3.8,
        ),
      ),
    );
  }

  Widget categorySelect(String label, int color) {
    return InkWell(
      onTap: () {
        setState(() {
          category = label;
        });
      },
      child: Chip(
        backgroundColor: category == label ? Colors.white : Color(color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: category == label ? Colors.black : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        labelPadding: EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 3.8,
        ),
      ),
    );
  }

  Widget title() {
    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Color(0xff2a2e3d),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: _titleController,
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Task Title",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 17,
          ),
          contentPadding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
        ),
      ),
    );
  }

  Widget label(String label) {
    return Text(
      label,
      style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16.5,
          letterSpacing: 0.2),
    );
  }

  Future<void> scheduleNotification(DateTime scheduledDate) async {
    print("Current time: ${DateTime.now()}");
    print("Scheduled time: ${scheduledDate}");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Deadline Reminder',
      'Your task "${_titleController.text}" is due now!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_notifications',
          'General Notifications',
          channelDescription: 'Receive all general notifications from the app.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
