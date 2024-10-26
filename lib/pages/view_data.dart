import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_midterm_project/pages/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class ViewData extends StatefulWidget {
  ViewData({Key? key, this.document, this.id}) : super(key: key);
  final Map<String, dynamic>? document;
  final String? id;

  @override
  State<ViewData> createState() => _ViewDataState();
}

class _ViewDataState extends State<ViewData> {
  List<String> _fileUrls = []; // Biến lưu trữ các URL của tệp
  List<Reference> _uploadedFiles = [];
  List<String> _imageUrls = [];
  List<File> _selectedFiles = [];
  TextEditingController? _titleController;
  TextEditingController? _descriptionController;
  String? type;
  String? category;
  DateTime? selectedDateTime;
  final ImagePicker _picker = ImagePicker();
  final Utils utils = Utils();
  bool edit = false;
  String taskID = FirebaseFirestore.instance.collection("Todo").doc().id;

  @override
  void initState() {
    super.initState();
    String title = widget.document?["title"] ?? "Hello";
    _titleController = TextEditingController(text: title);
    _descriptionController =
        TextEditingController(text: widget.document?["description"]);
    type = widget.document?["task"];
    category = widget.document?["Category"];
    int deadlineMicroseconds = widget.document!["deadline"];
    int deadlineMilliseconds = (deadlineMicroseconds / 1000).round();
    selectedDateTime =
        DateTime.fromMillisecondsSinceEpoch(deadlineMilliseconds, isUtc: true)
            .toLocal();
    _imageUrls = List<String>.from(widget.document?["images"] ?? []);
    loadTaskImages();
    print(_imageUrls);
    getUploadedFiles();
  }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            edit = !edit;
                          });
                        },
                        icon: Icon(
                          Icons.edit,
                          color: edit ? Colors.green : Colors.white,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("Todo")
                              .doc(widget.id)
                              .delete()
                              .then((value) => {
                                    Navigator.pop(context),
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
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      edit ? "Editing" : "View",
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
                      "Your Todo",
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
                    if (_imageUrls.isNotEmpty) buildImageGrid(),
                    if (edit)
                      ElevatedButton(
                        onPressed: () async {
                          final XFile? selectedImage = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (selectedImage != null) {
                            File imageFile = File(selectedImage.path);
                            bool success = await utils.uploadFileForUser(
                                imageFile, taskID);
                            if (success) {
                              setState(() {
                                loadTaskImages();
                              });
                            }
                          }
                        },
                        child: Text("Add Image"),
                      ),
                    if (_selectedFiles.isNotEmpty) buildFileGrid(),
                    // if (_selectedFiles.isNotEmpty)
                    //   Wrap(
                    //     spacing: 10,
                    //     runSpacing: 10,
                    //     children: _selectedFiles.map((file) {
                    //       return Container(
                    //         padding: EdgeInsets.all(8),
                    //         decoration: BoxDecoration(
                    //           color: Colors.grey[800],
                    //           borderRadius: BorderRadius.circular(5),
                    //         ),
                    //         child: Column(
                    //           children: [
                    //             // Hiển thị hình ảnh nếu là file hình ảnh
                    //             if (file.path.endsWith('.jpg') ||
                    //                 file.path.endsWith('.png') ||
                    //                 file.path.endsWith('.jpeg'))
                    //               Image.file(
                    //                 file,
                    //                 height: 100,
                    //                 width: 100,
                    //                 fit: BoxFit.cover,
                    //               )
                    //             else
                    //               // Nếu không phải là hình ảnh, hiển thị tên tệp
                    //               Text(
                    //                 file.path.split('/').last,
                    //                 style: TextStyle(color: Colors.white),
                    //               ),
                    //           ],
                    //         ),
                    //       );
                    //     }).toList(),
                    //   ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Button to select files
                        ElevatedButton(
                          child: Text("Choose File"),
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              allowMultiple: true,
                              type: FileType.any,
                            );
                            if (result != null) {
                              setState(() {
                                _selectedFiles = result.paths
                                    .map((path) => File(path!))
                                    .toList();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
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
                      height: 30,
                    ),
                    InkWell(
                      onTap: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            onChanged: (date) {}, onConfirm: (date) {
                          setState(() {
                            selectedDateTime = date;
                          });
                        }, currentTime: DateTime.now(), locale: LocaleType.vi);
                      },
                      child: Chip(
                        label: Text(
                          selectedDateTime != null
                              ? DateFormat('HH:mm')
                                  .format(selectedDateTime!.toLocal())
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
                    edit ? button() : Container(),
                    SizedBox(
                      width: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _imageUrls.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Image.network(_imageUrls[index],
                height: 100, width: 100, fit: BoxFit.cover),
            if (edit)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _imageUrls.removeAt(index);
                    });
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildFileGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _selectedFiles.map((file) {
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              Image.file(
                file,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 5),
              Text(
                path.basename(file.path),
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget button() {
    return InkWell(
      onTap: () async {
        // Xóa ảnh khỏi Firebase Storage nếu ảnh bị xóa trong quá trình chỉnh sửa
        for (var ref in _uploadedFiles) {
          String url = await ref.getDownloadURL();
          if (!_imageUrls.contains(url)) {
            await ref.delete(); // Xóa ảnh không còn trong danh sách
          }
        }

        FirebaseFirestore.instance.collection("Todo").doc(widget.id).update({
          "title": _titleController!.text,
          "task": type,
          "Category": category,
          "description": _descriptionController!.text,
          "deadline": selectedDateTime?.microsecondsSinceEpoch,
          "taskID": taskID,
          "images": await Future.wait(
              _uploadedFiles.map((ref) => ref.getDownloadURL())),
        });
        Navigator.pop(context);
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
            "Update Todo",
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
            enabled: edit,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
            maxLines: null,
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
        ),
        SizedBox(height: 10),

        // Hiển thị các URL hình ảnh

        SizedBox(height: 10),

        if (_selectedFiles.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _selectedFiles.map((file) {
              return Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  file.path.split('/').last,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // Giả sử bạn có taskID

  Future<void> loadTaskImages() async {
    // Lấy danh sách Reference tệp
    List<Reference> fileReferences = await utils.getTaskImages(widget.id!);

    for (Reference ref in fileReferences) {
      String fileName = ref.name; // Lấy tên tệp từ Reference
      String? url = await utils.getDownloadURL(widget.id!, fileName);
      if (url != null) {
        if (!_imageUrls.contains(url)) {
          setState(() {
            _imageUrls.add(url); // Thêm URL vào danh sách
          });
        }
      }
    }
  }

  void getUploadedFiles() async {
    List<Reference>? result = await utils.getUsersUploadedFiles();
    if (result != null && result.isNotEmpty) {
      setState(() {
        _uploadedFiles.addAll(result);
      });
    } else {
      print("No uploaded files found or result is null.");
    }
  }

  Widget taskSelect(String label, int color) {
    return InkWell(
      onTap: edit
          ? () {
              setState(() {
                type = label;
              });
            }
          : null,
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
      onTap: edit
          ? () {
              setState(() {
                category = label;
              });
            }
          : null,
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
        enabled: edit,
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
}
