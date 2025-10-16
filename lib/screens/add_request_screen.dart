import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'package:geolocator/geolocator.dart';

class AddRequestScreen extends StatefulWidget {
  @override State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  File? _image;
  bool _loading = false;

  final _picker = ImagePicker();
  final _fs = FirestoreService();
  final _storage = StorageService();

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _submit() async {
    final auth = Provider.of<AuthService>(context, listen:false);
    if (_title.text.trim().isEmpty || _desc.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preencha título e descrição')));
      return;
    }
    setState(()=>_loading=true);
    try {
      final pos = await _determinePosition();
      final data = {
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'userId': auth.currentUser!.uid,
        'userName': auth.currentUser!.displayName ?? auth.currentUser!.email,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'createdAt': DateTime.now(),
      };
      // create doc first to get id
      final id = await _fs.createRequest(data);
      String? photoUrl;
      if (_image != null) {
        photoUrl = await _storage.uploadRequestImage(_image!, id);
        await _fs.updateRequest(id, {'photoUrl': photoUrl});
      }
      Navigator.pop(context); // volta para home
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(()=>_loading=false);
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Nova Solicitação', style: TextStyle(color: Colors.black)),
        leading: BackButton(color: Colors.black),
        actions: [
          TextButton(onPressed: _loading?null:_submit, child: Text('Cadastrar', style: TextStyle(color: Colors.black))),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _title, decoration: InputDecoration(labelText: 'Título')),
            TextField(controller: _desc, decoration: InputDecoration(labelText: 'Descrição'), maxLines: 4),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _takePhoto,
              icon: Text('📷'),
              label: Text('Tirar Foto'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
            ),
            if (_image != null) Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Image.file(_image!, height: 180),
            ),
          ],
        ),
      ),
    );
  }
}
