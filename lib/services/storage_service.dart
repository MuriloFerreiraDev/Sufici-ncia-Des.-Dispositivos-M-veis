import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadRequestImage(File file, String requestId) async {
    final ref = _storage.ref().child('request_photos').child('$requestId.jpg');
    final uploadTask = await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
