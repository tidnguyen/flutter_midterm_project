import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_midterm_project/Service/utilsService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

@immutable
class ViewDataPage extends StatefulWidget {
  const ViewDataPage({super.key, this.document, this.id});
  final Map<String, dynamic>? document;
  final String? id;

  @override
  State<ViewDataPage> createState() => _ViewDataPageState();
}

class _ViewDataPageState extends State<ViewDataPage> {
  List<String> _fileUrls = [];
  List<String> _imageUrls = [];
  TextEditingController? _titleController;
  TextEditingController? _descriptionController;
  String? type;
  String? category;
  DateTime? selectedDateTime;
  final ImagePicker _picker = ImagePicker();
  final UtilsService utils = UtilsService();
  bool edit = false;

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
    _fileUrls = List<String>.from(widget.document?["files"] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
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
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
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
                        icon: const Icon(
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
                      style: const TextStyle(
                          fontSize: 33,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      "Your Todo",
                      style: TextStyle(
                        fontSize: 33,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    label("Task Title"),
                    const SizedBox(
                      height: 12,
                    ),
                    title(),
                    const SizedBox(
                      height: 30,
                    ),
                    label("Task Type"),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        taskSelect("Important", 0xff2664fa),
                        const SizedBox(
                          width: 20,
                        ),
                        taskSelect("Planned", 0xff2bc8d9),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    label("Descripiton"),
                    const SizedBox(
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
                            try {
                              String fileName = imageFile.path.split('/').last;
                              Reference ref = FirebaseStorage.instance
                                  .ref()
                                  .child('taskImages/$fileName');
                              await ref.putFile(imageFile);

                              String? downloadURL =
                                  await getDownloadURL(fileName);
                              if (downloadURL != null) {
                                setState(() {
                                  _imageUrls.add(downloadURL);
                                });
                              }
                            } catch (e) {
                              return;
                            }
                          }
                        },
                        child: const Text("Add Image"),
                      ),
                    if (_fileUrls.isNotEmpty) buildFileGrid(),
                    if (edit)
                      ElevatedButton(
                        onPressed: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            allowMultiple: true,
                            type: FileType.any,
                          );
                          if (result != null) {
                            PlatformFile file = result.files.first;
                            String fileName = file.name;
                            String filePath = file.path!;

                            File fileToUpload = File(filePath);

                            Reference storageRef = FirebaseStorage.instance
                                .ref()
                                .child('files/$fileName');

                            UploadTask uploadTask =
                                storageRef.putFile(fileToUpload);
                            TaskSnapshot taskSnapshot = await uploadTask;

                            String downloadUrl =
                                await taskSnapshot.ref.getDownloadURL();

                            setState(() {
                              _fileUrls.add(downloadUrl);
                            });
                          }
                        },
                        child: const Text("Add File"),
                      ),
                    const SizedBox(
                      height: 12,
                    ),
                    label("Category"),
                    const SizedBox(
                      height: 12,
                    ),
                    Wrap(
                      runSpacing: 10,
                      children: [
                        categorySelect("Food", 0xffff6d6e),
                        const SizedBox(
                          width: 20,
                        ),
                        categorySelect("WorkOut", 0xfff29732),
                        const SizedBox(
                          width: 20,
                        ),
                        categorySelect("Work", 0xff6557ff),
                        const SizedBox(
                          width: 20,
                        ),
                        categorySelect("Design", 0xff234ebd),
                        const SizedBox(
                          width: 20,
                        ),
                        categorySelect("Run", 0xff2bc8d9),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    InkWell(
                      onTap: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            onChanged: (date) {}, onConfirm: (date) {
                          setState(
                            () {
                              selectedDateTime = date;
                            },
                          );
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
                    const SizedBox(
                      height: 30,
                    ),
                    edit ? button() : Container(),
                    const SizedBox(
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

  Future<String?> getDownloadURL(String fileName) async {
    try {
      Reference ref =
          FirebaseStorage.instance.ref().child('taskImages/$fileName');
      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      return null;
    }
  }

  Widget buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _imageUrls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemBuilder: (context, index) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            if (edit)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
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

  String getFileName(String url) {
    String decodedUrl = Uri.decodeFull(url);

    RegExp regex = RegExp(r'\/([^\/?]+)(?:\?.*)?$');
    Match? match = regex.firstMatch(decodedUrl);

    return match != null ? match.group(1) ?? 'unknown' : 'unknown';
  }

  Widget buildFileGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _fileUrls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        String fileUrl = _fileUrls[index];
        String fileName = getFileName(fileUrl);
        return GestureDetector(
          onTap: () async {
            final Uri url = Uri.parse(fileUrl);
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {}
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(5),
                ),
                width: 120,
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.insert_drive_file,
                      color: Colors.white,
                      size: 50,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      fileName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (edit)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(
                        () {
                          _fileUrls.removeAt(index);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget button() {
    return InkWell(
      onTap: () async {
        FirebaseFirestore.instance.collection("Todo").doc(widget.id).update({
          "title": _titleController!.text,
          "task": type,
          "Category": category,
          "description": _descriptionController!.text,
          "deadline": selectedDateTime?.microsecondsSinceEpoch,
          "images": _imageUrls,
          "files": _fileUrls,
        });
        Navigator.pop(context);
      },
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xff8a32f1),
              Color(0xffad32f9),
            ],
          ),
        ),
        child: const Center(
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
            color: const Color(0xff2a2e3d),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextFormField(
            controller: _descriptionController,
            enabled: edit,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
            maxLines: null,
            decoration: const InputDecoration(
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
        const SizedBox(height: 10),
      ],
    );
  }

  Widget taskSelect(String label, int color) {
    return InkWell(
      onTap: edit
          ? () {
              setState(
                () {
                  type = label;
                },
              );
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
        labelPadding: const EdgeInsets.symmetric(
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
              setState(
                () {
                  category = label;
                },
              );
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
        labelPadding: const EdgeInsets.symmetric(
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
        color: const Color(0xff2a2e3d),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: _titleController,
        enabled: edit,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
        decoration: const InputDecoration(
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
      style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16.5,
          letterSpacing: 0.2),
    );
  }
}
