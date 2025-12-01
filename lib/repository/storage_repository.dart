import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageRepository {
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  StorageRepository({FirebaseStorage? storage, ImagePicker? picker})
      : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> uploadImage(File file, String userId) async {
    try {
      final fileName = 'item_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref('images/$userId/$fileName');
      
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}