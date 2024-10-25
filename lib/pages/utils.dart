import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Utils {
  static final ImagePicker _picker = ImagePicker();
  String? downloadURL;

  Future<File?> getImageGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }

  Future<bool> uploadFileForUser(File file, String taskID) async {
    try {
      String fileName = file.path.split('/').last;
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('taskImages/$taskID/$fileName');  // Store by taskID
      await ref.putFile(file);
      return true;
    } catch (e) {
      print("Error uploading file: $e");
      return false;
    }
  }

  Future<List<Reference>?> getUsersUploadedFiles() async {
    final userId = await _getUserId();
    if (userId == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final uploads = await storageRef.child("$userId/uploads").listAll();
      return uploads.items;
    } catch (e) {
      print("Error getting uploaded files: $e");
      return null;
    }
  }

Future<List<Reference>> getTaskImages(String taskID) async {
  try {
    ListResult result = await FirebaseStorage.instance
        .ref('taskImages/$taskID')
        .listAll();
    // Trả về danh sách Reference
    return result.items;
  } catch (e) {
    print("Error getting file references: $e");
    return []; // Trả về danh sách rỗng nếu có lỗi
  }
}


  Future<String?> _getUserId() async {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<String?> getDownloadURL(String taskID, String fileName) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child('taskImages/$taskID/$fileName');
      String downloadURL = await ref.getDownloadURL(); // Lấy URL tải xuống
      return downloadURL; // Trả về URL
    } catch (e) {
      print("Error getting download URL: $e");
      return null; // Nếu có lỗi, trả về null
    }
  }


}
